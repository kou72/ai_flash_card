/* eslint-disable @typescript-eslint/no-explicit-any */
import * as os from "os";
import * as path from "path";
import * as fs from "fs";
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import vision from "@google-cloud/vision";
import * as admin from "firebase-admin";
import * as busboy from "busboy";
import {getDate} from "./utils";
import {requestChatGPT} from "./openai";

admin.initializeApp();

const storage = admin.storage();
const bucket = storage.bucket();
const bucketName = "flash-pdf-card.appspot.com";
type Bucket = ReturnType<typeof storage.bucket>;

const getFileContents = async (bucket: Bucket, DestinationFolder: string) => {
  try {
    const [files] = await bucket.getFiles({prefix: DestinationFolder});

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const [texts] = files.map(async (file: any) => {
      const json = bucket.file(file.name);
      const contents = await json.download();
      const jsonString = contents.toString();
      const jsonData = JSON.parse(jsonString);
      return jsonData.responses[0].fullTextAnnotation.text;
    });

    return texts;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(error.message, {structuredData: true});
  }
};

export const helloWorld = onRequest({cors: true}, (req, res) => {
  if (req.method !== "POST") {
    res.status(405).end();
    return;
  }

  const bb = busboy({headers: req.headers});
  const tmpdir = os.tmpdir();
  let filename: string;
  let filepath: string;

  bb.on("file", (name, file, info) => {
    filename = info.filename;
    filepath = path.join(tmpdir, filename);
    file.pipe(fs.createWriteStream(filepath));
  });

  bb.on("finish", async () => {
    logger.info("finish");
    try {
      logger.info("filepath: " + filepath);
      const date = getDate();
      const DestinationFolder = "upload";
      bucket.upload(filepath, {
        destination: `${DestinationFolder}/${date}-${filename}`,
        metadata: {
          contentType: "application/pdf",
        },
      });
      res.status(200).send("File processed.");
    } catch (error) {
      console.error("Error processing file:", error);
      res.status(500).send(error);
    }
  });

  bb.end(req.rawBody);
});

export const documentTextDetection = onRequest(
  {
    timeoutSeconds: 300,
    cors: false,
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

    const texts = await getFileContents(bucket, DestinationFolder);
    const chatGptRes = await requestChatGPT(texts);
    // await bucket.deleteFiles({prefix: DestinationFolder}); // ファイルを削除する場合
    res.send(chatGptRes);
  }
);
