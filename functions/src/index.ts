/* eslint-disable @typescript-eslint/no-explicit-any */
// import * as os from "os";
// import * as path from "path";
// import * as fs from "fs";
import {onRequest, Request} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import vision from "@google-cloud/vision";
import * as admin from "firebase-admin";
import * as busboy from "busboy";
import {getDate} from "./utils";
import {generateQuestionsFromChatGPT} from "./openai";

admin.initializeApp();

const storage = admin.storage();
const bucket = storage.bucket();
const bucketName = "flash-pdf-card.appspot.com";

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
    const [texts] = files.map(async (file: any) => {
      const json = bucket.file(file.name);
      const contents = await json.download();
      const jsonString = contents.toString();
      const jsonData = JSON.parse(jsonString);
      return jsonData.responses[0].fullTextAnnotation.text;
    });

    return texts;
  } catch (error: any) {
    logger.error(error.message, {structuredData: true});
  }
};

export const helloWorld = onRequest(
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
      const texts = await extractTextFromJson(destFolder);
      const questions = await generateQuestionsFromChatGPT(texts);
      res.status(200).send(questions);
    } catch (error: any) {
      res.status(500).send(error.message);
    }
  }
);

export const documentTextDetection = onRequest(
  {
    timeoutSeconds: 300,
    cors: true,
  },
  async (req, res) => {
    // CORS
    if (req.method === "OPTIONS") {
      res.header("Access-Control-Allow-Origin", "*");
      res.header("Access-Control-Allow-Headers", "Content-Type");
      res.header("Access-Control-Allow-Methods", "POST");
      res.status(200).end();
      return;
    }

    // POST以外の場合は405エラー
    if (req.method !== "POST") {
      res.status(405).end();
      return;
    }

    logger.info("req.body: " + req.body);
    logger.info("req.body.filename: " + req.body.filename);

    const bb = busboy({headers: req.headers});

    bb.on(
      "file",
      (
        fieldname: any,
        file: any,
        filename: any,
        encoding: any,
        mimetype: any
      ) => {
        logger.info("fieldname: " + fieldname);
        logger.info("file: " + file);
        logger.info("filename: " + filename);
        logger.info("encoding: " + encoding);
        logger.info("mimetype: " + mimetype);
      }
    );

    // const tmpdir = os.tmpdir();

    const client = new vision.ImageAnnotatorClient();

    // const fileName = "test.pdf";
    const fileName = "l2pt.pdf";
    const gcsSourceUri = `gs://${bucketName}/${fileName}`;

    const baseFileName = fileName.replace(".pdf", "");
    const date = getDate();
    const DestinationFolder = `${baseFileName}${date}/`;
    const gcsDestinationUri = `gs://${bucketName}/${DestinationFolder}`;

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
          features: features,
          outputConfig: outputConfig,
        },
      ],
    };

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const [operation]: any = await client.asyncBatchAnnotateFiles(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      config as any
    );
    await operation.promise();

    // const texts = await getFileContents(bucket, DestinationFolder);
    // const chatGptRes = await requestChatGPT(texts);
    // await bucket.deleteFiles({prefix: DestinationFolder}); // ファイルを削除する場合
    // res.send(chatGptRes);
  }
);
