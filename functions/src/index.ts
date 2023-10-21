/* eslint-disable @typescript-eslint/no-explicit-any */
import {onRequest, Request} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as busboy from "busboy";
import vision from "@google-cloud/vision";
import {getDate} from "./utils";
import {generateQuestionsFromChatGPT} from "./openai";

admin.initializeApp();

const storage = admin.storage();
const bucket = storage.bucket();
const bucketName = "flash-pdf-card.appspot.com";
const firestore = admin.firestore();

export const generateImageToQuestions = onRequest(
  {timeoutSeconds: 300, cors: true},
  async (req, res) => {
    // POST以外のリクエストは405を返す
    if (req.method !== "POST") {
      res.status(405).end();
      return;
    }

    // メインの処理
    // fileUpload：画像をCloud Storageにアップロードし、保存先のpathを取得
    // convertImageToText：SourceBucktの画像をテキストに変換
    // saveText：デバッグ用の中間ファイルとしてtext.txtを保存
    // streamingQuestionsProgressToFirestore：問題文生成の進捗をFirestoreに保存、処理完了後に全出力を返す
    //  - generateQuestionsFromChatGPT：テキストをOpenAIのAPIに投げて質問を生成、ストリームで返答する
    //  - progressStreamReader：返ってきたStreamを進捗率に変換、処理完了後に全出力を返す
    // convertTextToQaJson：テキストから質問と回答を抽出してJSON形式に変換
    // saveQuestions：デバッグ用の中間ファイルとしてquestions.jsonを保存
    try {
      const date = getDate();
      const sourcePath = await fileUpload(req, date);
      // dest用pathをsourcePathから生成（upload/0000-text.pdf → destination/0000-text）
      const destFile = sourcePath.split("/")[1].replace(/\.[^/.]+$/, "") + "/";
      const destFolder = "dest/" + destFile;

      const text = await convertImageToText(sourcePath);
      await saveText(destFolder, text);

      const questionStore = firestore.collection("aicard").doc(destFile);
      await questionStore.set({progress: 0, data: {}});
      res.status(200).send(destFile);

      let questionsText;
      try {
        questionsText = await streamingQuestionsProgressToFirestore({
          text: text,
          gpt4: false,
          store: questionStore,
        });
      } catch (error: any) {
        logger.error(error.message, {structuredData: true});
        questionsText = await streamingQuestionsProgressToFirestore({
          text: text,
          gpt4: true,
          store: questionStore,
        });
      }
      const questions = convertTextToQaJson(questionsText);
      await questionStore.set({progress: 100, data: questions});
      await saveQuestions(destFolder, questions);
    } catch (error: any) {
      logger.error(error.message, {structuredData: true});
      res.status(500).send(error.message);
    }
  }
);

const fileUpload = (req: Request, date: string): Promise<string> =>
  new Promise((resolve, reject) => {
    const bb = busboy({headers: req.headers});
    bb.on("file", (name, stream, info) => {
      // 日本語不備のため、ファイル名をbase64&utf-8でエンコードしているためデコードする
      const decodedBytes = atob(info.filename);
      const decoder = new TextDecoder("utf-8");
      const fileName = decoder.decode(
        new Uint8Array(decodedBytes.split("").map((char) => char.charCodeAt(0)))
      );

      const folder = "upload";
      const filePath = `${folder}/${date}-${fileName}`;
      const bucketPath = bucket.file(filePath);
      stream.pipe(bucketPath.createWriteStream()).on("finish", () => {
        resolve(filePath);
      });
    });

    bb.on("error", (err) => {
      logger.error("Busboy error:", err);
      reject(new Error("File upload failed."));
    });

    bb.end(req.rawBody);
  });

const convertImageToText = async (sourcePath: string) => {
  const client = new vision.ImageAnnotatorClient();
  const gcsSourceUri = `gs://${bucketName}/${sourcePath}`;

  const [result] = await client.textDetection(gcsSourceUri);
  if (!result) throw new Error("No text found");
  const text = result.fullTextAnnotation?.text ?? "empty";

  return text;
};

const progressStreamReader = async (questionsStream: ReadableStream) => {
  // 以下フォーマットのStreamを解析して進捗率を計算する
  // --- ここからフォーマット ---
  // <1/3>問題:テキスト回答:テキスト
  // <2/3>問題:テキスト回答:テキスト
  // <3/3>問題:テキスト回答:テキスト
  // <end>
  // --- ここまで ---
  const progressStream = new ReadableStream({
    async start(controller) {
      const reader = questionsStream.getReader();
      const textDecoder = new TextDecoder("utf-8");
      let questionsText = "";
      let isRecordingMeta = false;
      let metaString = "";

      // eslint-disable-next-line no-constant-condition
      while (true) {
        const {done, value} = await reader.read();
        if (done) {
          // <end> が検知できなかったら途中で切れてると判断する
          const errorText = "出力が完了しませんでした。";
          if (!metaString.includes("<end>")) throw new Error(errorText);
          break;
        }

        // valueに一文字ずつ入るのでデコードしたあとtextに入れて解析する
        const text = textDecoder.decode(value);
        questionsText += text;

        // メタ情報（<1/3>, <end>）を検知して、進捗率を計算する
        if (text === "<") {
          metaString = "";
          isRecordingMeta = true;
        }
        if (isRecordingMeta) metaString += text;
        if (text === ">") {
          isRecordingMeta = false;

          // <end>を検知したら進捗率の計算をスキップする
          if (metaString.includes("<end>")) continue;

          // <1/3> から 1 と 3 を取り出して、進捗率を計算してjsonで返す
          const regex = /^<(\d+)\/(\d+)>$/;
          const match = metaString.match(regex);
          if (!match) return;
          const count = parseInt(match[1], 10) - 1;
          const total = parseInt(match[2], 10);
          const progress = Math.trunc((count / total) * 100); // 整数%の進捗率
          const json = {progress: progress, questionsText: ""};
          controller.enqueue(JSON.stringify(json));
        }
      }
      // 取得した文字列をまとめて返す
      const json = {progress: 100, questionsText: questionsText};
      controller.enqueue(JSON.stringify(json));
      controller.close();
    },
  });
  return progressStream;
};

const streamingQuestionsProgressToFirestore = async ({
  text,
  gpt4,
  store,
}: {
  text: string;
  gpt4: boolean;
  store: any;
}) => {
  let questionsText;
  const questionsStream = await generateQuestionsFromChatGPT({
    input: text,
    gpt4: gpt4,
  });
  if (!questionsStream) return;
  const progressStream = await progressStreamReader(questionsStream);
  const reader = progressStream.getReader();
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const {done, value} = await reader.read();
    if (done) break;
    const json = JSON.parse(value);
    questionsText = json.questionsText;
    await store.set({progress: json.progress, data: {}});
  }
  return questionsText;
};

const convertTextToQaJson = (text: string) => {
  // メタ情報（<1/22>, <end>, \n）を削除
  const noMetaText = text
    .replace(/<\d+\/\d+>|<end>/g, "")
    .replace(/\n/g, "")
    .trim();
  // テキストから問題と回答を抽出してJSON形式に変換する
  const regex = /問題:(.*?)回答:(.*?)(?=問題:|回答:|$)/g;
  const result = [];
  let match;
  while ((match = regex.exec(noMetaText)) !== null) {
    result.push({
      question: match[1].trim(),
      answer: match[2].trim(),
      note: "",
    });
  }
  return JSON.parse(JSON.stringify(result));
};

const saveText = async (DestinationFolder: string, text: string) => {
  const filePath = `${DestinationFolder}text.txt`;
  const bucketPath = bucket.file(filePath);
  bucketPath.save(text);
};

const saveQuestions = async (DestinationFolder: string, questions: any) => {
  const filePath = `${DestinationFolder}questions.json`;
  const bucketPath = bucket.file(filePath);
  bucketPath.save(JSON.stringify(questions));
};
