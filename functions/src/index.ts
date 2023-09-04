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

export const generateFlashCardQuestions = onRequest(
  {timeoutSeconds: 300, cors: true},
  async (req, res) => {
    // POST以外のリクエストは405を返す
    if (req.method !== "POST") {
      res.status(405).end();
      return;
    }

    // メインの処理
    // fileUpload：PDFをCloud Storageにアップロードし、保存先のpathを取得
    // convertPdfToTextJson：SourceBucktのPDFをテキストに変換したJSONファイルをDestBucketに保存
    // extractTextFromJson：JSONからテキストを抽出、テキストはPDF1ページごと1つの塊で取り出され配列状で格納
    // generateQuestionsFromChatGPT：テキストをOpenAIのAPIに投げて質問を生成、テキスト1要素ごとにリクエスト
    // saveQuestions：デバッグ用の中間ファイルとしてquestions.jsonを保存
    try {
      const date = getDate();
      const sourcePath = await fileUpload(req, date);
      // dest用pathをsourcePathから生成（upload/0000-text.pdf → destination/0000-text）
      const destFolder =
        "dest/" + sourcePath.split("/")[1].replace(/\.[^/.]+$/, "") + "/";
      await convertPdfToTextJson(sourcePath, destFolder);
      const textList = await extractTextFromJson(destFolder);
      const questionsList = await Promise.all(
        textList.map(async (text) => {
          const questionsString = await generateQuestionsFromChatGPT(text);
          return JSON.parse(questionsString);
        })
      );
      // 返ってきた質問を1つにまとめる
      const questions = questionsList.reduce((acc, cur) => acc.concat(cur));
      await saveQuestions(destFolder, questions);
      res.status(200).send(questions);
    } catch (error: any) {
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
      const decodedFileName = decoder.decode(
        new Uint8Array(decodedBytes.split("").map((char) => char.charCodeAt(0)))
      );

      const folder = "upload";
      const filePath = `${folder}/${date}-${decodedFileName}`;
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

const convertPdfToTextJson = async (sourcePath: string, destFolder: string) => {
  const client = new vision.ImageAnnotatorClient();
  const gcsSourceUri = `gs://${bucketName}/${sourcePath}`;
  const gcsDestinationUri = `gs://${bucketName}/${destFolder}`;

  const inputConfig = {
    mimeType: "application/pdf",
    gcsSource: {
      uri: gcsSourceUri,
    },
  };
  const outputConfig = {
    gcsDestination: {
      uri: gcsDestinationUri,
    },
  };
  const features = [{type: "DOCUMENT_TEXT_DETECTION"}];
  const config = {
    requests: [
      {
        inputConfig: inputConfig,
        outputConfig: outputConfig,
        features: features,
      },
    ],
  };

  const [operation] = await client.asyncBatchAnnotateFiles(config as any);
  await operation.promise();
};

const extractTextFromJson = async (DestinationFolder: string) => {
  try {
    const [files] = await bucket.getFiles({prefix: DestinationFolder});
    const jsonFile = await Promise.all(
      files.map(async (file: any) => {
        const json = bucket.file(file.name);
        const contents = await json.download();
        const jsonString = contents.toString();
        const jsonData = JSON.parse(jsonString);
        return jsonData;
      })
    );
    const textList: any[] = [];
    jsonFile.map((data: any) => {
      data.responses.map(
        // (res: any) => (text = text + res.fullTextAnnotation.text)
        (res: any) => textList.push(res.fullTextAnnotation.text)
      );
    });

    // デバック用の中間ファイルとしてtext.txtを作成
    textList.map(async (text: any, index: number) => {
      const filePath = `${DestinationFolder}text${index.toString()}.txt`;
      const bucketPath = bucket.file(filePath);
      bucketPath.save(await text);
    });

    return textList;
  } catch (error: any) {
    logger.error(error.message, {structuredData: true});
    throw new Error(error.message);
  }
};

const saveQuestions = async (DestinationFolder: string, questions: any) => {
  const filePath = `${DestinationFolder}questions.json`;
  const bucketPath = bucket.file(filePath);
  bucketPath.save(JSON.stringify(questions));
};
