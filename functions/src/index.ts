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
    if (req.method !== "POST") {
      res.status(405).end();
      return;
    }

    try {
      const date = getDate();
      const sourcePath = await fileUpload(req, date);
      // dest用pathをsourcePathから生成（upload/0000-text.pdf → destination/0000-text）
      const destFolder =
        "dest/" + sourcePath.split("/")[1].replace(/\.[^/.]+$/, "") + "/";
      await convertPdfToTextJson(sourcePath, destFolder);
      const text = await extractTextFromJson(destFolder);
      const questions = await generateQuestionsFromChatGPT(text);
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
      const folder = "upload";
      const filePath = `${folder}/${date}-${info.filename}`;
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
    const texts: any[] = [];
    jsonFile.map((data: any) => {
      data.responses.map(
        // (res: any) => (text = text + res.fullTextAnnotation.text)
        (res: any) => texts.push(res.fullTextAnnotation.text)
      );
    });

    // デバック用の中間ファイルとしてtext.txtを作成
    texts.map(async (text: any, index: number) => {
      const filePath = `${DestinationFolder}text${index.toString()}.txt`;
      const bucketPath = bucket.file(filePath);
      bucketPath.save(await text);
    });

    return texts[0];
  } catch (error: any) {
    logger.error(error.message, {structuredData: true});
    throw new Error(error.message);
  }
};
