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
    // generateQuestionsFromChatGPT：テキストをOpenAIのAPIに投げて質問を生成
    // progressStreamReader：返ってきたStreamを進捗率に変換、処理完了後に全出力を返す
    // convertTextToQaJson：テキストから質問と回答を抽出してJSON形式に変換
    // saveQuestions：デバッグ用の中間ファイルとしてquestions.jsonを保存
    try {
      const date = getDate();
      const sourcePath = await fileUpload(req, date);
      // dest用pathをsourcePathから生成（upload/0000-text.pdf → destination/0000-text）
      const destFolder =
        "dest/" + sourcePath.split("/")[1].replace(/\.[^/.]+$/, "") + "/";

      const text = await convertImageToText(sourcePath);
      await saveText(destFolder, text);

      let questionsString;
      try {
        const questionsStream = await generateQuestionsFromChatGPT({
          input: text,
          gpt4: false,
        });
        if (!questionsStream) return;
        const progressStream = await progressStreamReader(questionsStream);
        const reader = progressStream.getReader();
        // eslint-disable-next-line no-constant-condition
        while (true) {
          const {done, value} = await reader.read();
          if (done) break;
          questionsString = value;
        }
      } catch (error: any) {
        logger.error(error.message, {structuredData: true});
        const questionsStream = await generateQuestionsFromChatGPT({
          input: text,
          gpt4: true,
        });
        if (!questionsStream) return;
        const progressStream = await progressStreamReader(questionsStream);
        const reader = progressStream.getReader();
        // eslint-disable-next-line no-constant-condition
        while (true) {
          const {done, value} = await reader.read();
          if (done) break;
          questionsString = value;
        }
      }
      const questions = convertTextToQaJson(questionsString);
      await saveQuestions(destFolder, questions);

      res.status(200).send(questions);
    } catch (error: any) {
      logger.error(error.message, {structuredData: true});
      res.status(500).send(error.message);
    }
  }
);

// export const generateFlashCardQuestions = onRequest(
//   {timeoutSeconds: 300, cors: true},
//   async (req, res) => {
//     // POST以外のリクエストは405を返す
//     if (req.method !== "POST") {
//       res.status(405).end();
//       return;
//     }

//     // メインの処理
//     // fileUpload：PDFをCloud Storageにアップロードし、保存先のpathを取得
//     // convertPdfToTextJson：SourceBucktのPDFをテキストに変換したJSONファイルをDestBucketに保存
//     // extractTextFromJson：JSONからテキストを抽出、テキストはPDF1ページごと1つの塊で取り出され配列状で格納
//     // generateQuestionsFromChatGPT：テキストをOpenAIのAPIに投げて質問を生成、テキスト1要素ごとにリクエスト
//     // saveQuestions：デバッグ用の中間ファイルとしてquestions.jsonを保存
//     try {
//       const date = getDate();
//       const sourcePath = await fileUpload(req, date);
//     // dest用pathをsourcePathから生成（upload/0000-text.pdf → destination/0000-text）
//       const destFolder =
//         "dest/" + sourcePath.split("/")[1].replace(/\.[^/.]+$/, "") + "/";
//       await convertPdfToTextJson(sourcePath, destFolder);
//       const textList = await extractTextFromJson(destFolder);
//       const questionsList = await Promise.all(
//         textList.map(async (text) => {
//           const questionsString = await generateQuestionsFromChatGPT({
//             input: text,
//             gpt4: false,
//           });
//           return JSON.parse(questionsString);
//         })
//       );
//       // 返ってきた質問を1つにまとめる
//       const questions = questionsList.reduce((acc, cur) => acc.concat(cur));
//       await saveQuestions(destFolder, questions);
//       res.status(200).send(questions);
//     } catch (error: any) {
//       res.status(500).send(error.message);
//     }
//   }
// );

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
  const progressStream = new ReadableStream({
    async start(controller) {
      const reader = questionsStream.getReader();
      const textDecoder = new TextDecoder("utf-8");
      let questionsString = "";
      let isRecordingMeta = false;
      let metaString = "";
      let loop = true;

      while (loop) {
        const {done, value} = await reader.read();
        if (done) {
          loop = false;
          // <end> が検知できなかったら途中で切れてると判断する
          if (!metaString.includes("<end>")) {
            throw new Error("出力が完了しませんでした。");
          }
          break;
        }

        const text = textDecoder.decode(value);
        questionsString += text;
        console.log(text);

        // メタ情報（<1/22>, <end>）を検知して、進捗率を計算する
        if (text === "<") {
          metaString = "";
          isRecordingMeta = true;
        }
        if (isRecordingMeta) metaString += text;
        if (text === ">") {
          isRecordingMeta = false;
          if (metaString.includes("<end>")) {
            // 文字列最後の<end>を検知したら100%を返す
            controller.enqueue(100);
          } else {
            // <1/22> から 1 と 22 を取り出して、進捗率を計算して返す
            const regex = /^<(\d+)\/(\d+)>$/;
            const match = metaString.match(regex);
            if (!match) return;
            const count = parseInt(match[1], 10) - 1;
            const total = parseInt(match[2], 10);
            const progress = (count / total) * 100;
            controller.enqueue(progress.toFixed(0));
          }
        }
      }
      console.log("close");
      // 取得した文字列をまとめて返す
      controller.enqueue(questionsString);
      controller.close();
    },
  });

  return progressStream;
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

// const convertPdfToTextJson =
// async (sourcePath: string, destFolder: string) => {
//   const client = new vision.ImageAnnotatorClient();
//   const gcsSourceUri = `gs://${bucketName}/${sourcePath}`;
//   const gcsDestinationUri = `gs://${bucketName}/${destFolder}`;

//   const inputConfig = {
//     mimeType: "application/pdf",
//     gcsSource: {
//       uri: gcsSourceUri,
//     },
//   };
//   const outputConfig = {
//     gcsDestination: {
//       uri: gcsDestinationUri,
//     },
//   };
//   const features = [{type: "DOCUMENT_TEXT_DETECTION"}];
//   const config = {
//     requests: [
//       {
//         inputConfig: inputConfig,
//         outputConfig: outputConfig,
//         features: features,
//       },
//     ],
//   };

//   const [operation] = await client.asyncBatchAnnotateFiles(config as any);
//   await operation.promise();
// };

// const extractTextFromJson = async (DestinationFolder: string) => {
//   try {
//     const [files] = await bucket.getFiles({prefix: DestinationFolder});
//     const jsonFile = await Promise.all(
//       files.map(async (file: any) => {
//         const json = bucket.file(file.name);
//         const contents = await json.download();
//         const jsonString = contents.toString();
//         const jsonData = JSON.parse(jsonString);
//         return jsonData;
//       })
//     );
//     const textList: any[] = [];
//     jsonFile.map((data: any) => {
//       data.responses.map(
//         // (res: any) => (text = text + res.fullTextAnnotation.text)
//         (res: any) => textList.push(res.fullTextAnnotation.text)
//       );
//     });

//     // デバック用の中間ファイルとしてtext.txtを作成
//     textList.map(async (text: any, index: number) => {
//       const filePath = `${DestinationFolder}text${index.toString()}.txt`;
//       const bucketPath = bucket.file(filePath);
//       bucketPath.save(await text);
//     });

//     return textList;
//   } catch (error: any) {
//     logger.error(error.message, {structuredData: true});
//     throw new Error(error.message);
//   }
// };

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
