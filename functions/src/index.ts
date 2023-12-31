/* eslint-disable @typescript-eslint/no-explicit-any */
import {onRequest, Request} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as busboy from "busboy";
import vision from "@google-cloud/vision";
import {getDate} from "./utils";
import {generateQaFromChatGPT} from "./openai";

admin.initializeApp();

const storage = admin.storage();
const bucket = storage.bucket();
const bucketName = "flash-pdf-card.appspot.com";
const firestore = admin.firestore();

export const generateImageToQa = onRequest(
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
    // qaStore.set：Firestoreに生成した質問を保存
    // res.status(200).send(destFile)：Firestoreへのパスを返す
    // generateQaFromChatGPT：テキストをOpenAIのAPIに投げて質問を生成
    // convertTextToQaJson：テキストから質問と回答を抽出してJSON形式に変換
    // saveQa：デバッグ用の中間ファイルとしてqa.jsonを保存
    let qaStore = firestore.collection("aicard").doc("error");
    try {
      const date = getDate();
      const sourcePath = await fileUpload(req, date);
      // dest用pathをsourcePathから生成（upload/0000-text.pdf → destination/0000-text）
      const destFile = sourcePath.split("/")[1].replace(/\.[^/.]+$/, "") + "/";
      const destFolder = "dest/" + destFile;
      const text = await convertImageToText(sourcePath);
      await saveText(destFolder, text, "text.txt");
      qaStore = firestore.collection("aicard").doc(destFile);
      const startTime = Date.now(); // 時間計測開始
      await qaStore.set({done: false, data: {}}); // Firestoreへ初期値保存
      res.status(200).send(destFile);
      const qaText = await generateQaFromChatGPT({input: text, gpt4: true});
      await saveText(destFolder, qaText, "qa.txt");
      const qaJson = convertTextToQaJson(qaText);
      const elapsedTime = Math.floor(Date.now() - startTime) / 1000; // 時間計測終了
      await qaStore.set({done: true, data: qaJson, elapsedTime: elapsedTime});
      await saveQa(destFolder, qaJson);
    } catch (error: any) {
      logger.error(error.message, {structuredData: true});
      await qaStore.set({done: true, data: {}});
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

const convertTextToQaJson = (text: string) => {
  // 改行（\n）と空白を削除
  const noMetaText = text.replace(/\n/g, "").trim();
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

const saveText = async (DestFolder: string, text: string, name: string) => {
  const filePath = `${DestFolder}${name}`;
  const bucketPath = bucket.file(filePath);
  bucketPath.save(text);
};

const saveQa = async (DestFolder: string, qa: any) => {
  const filePath = `${DestFolder}qa.json`;
  const bucketPath = bucket.file(filePath);
  bucketPath.save(JSON.stringify(qa));
};
