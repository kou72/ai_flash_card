import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import vision from "@google-cloud/vision";

// import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const storage = admin.storage();

// 実行時間のyyyyMMddhhmmssを取得
const getDate = () => {
  const date = new Date();
  const formattedDate = `${date.getFullYear()}${String(
    date.getMonth() + 1
  ).padStart(2, "0")}${String(date.getDate()).padStart(2, "0")}${String(
    date.getHours()
  ).padStart(2, "0")}${String(date.getMinutes()).padStart(2, "0")}${String(
    date.getSeconds()
  ).padStart(2, "0")}`;
  return formattedDate;
};

const getFileContents = async (DestinationFolder: string) => {
  const bucket = storage.bucket();
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
};

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

export const documentTextDetection = onRequest(async (request, response) => {
  const client = new vision.ImageAnnotatorClient();

  const bucketName = "flash-pdf-card.appspot.com";
  const fileName = "test.pdf";
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
  const [operation]: any = await client.asyncBatchAnnotateFiles(config as any);
  await operation.promise();

  const texts = await getFileContents(DestinationFolder);
  response.send(texts);

  const bucket = storage.bucket();
  const [files] = await bucket.getFiles();
  logger.info("Files:" + files[0].name, {structuredData: true});

  response.send("Document Text Detection");
});
