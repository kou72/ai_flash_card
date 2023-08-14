import {onRequest} from "firebase-functions/v2/https";
import vision from "@google-cloud/vision";

import {getDate} from "./utils";
import {getFileContents} from "./gcp";
import {requestChatGPT} from "./openai";

// import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const storage = admin.storage();
const bucket = storage.bucket();

export const helloWorld = onRequest((request, response) => {
  // res.set("Access-Control-Allow-Origin", "*");
  response.send("Hello from Firebase!");
});

export const documentTextDetection = onRequest(async (request, response) => {
  const client = new vision.ImageAnnotatorClient();

  const bucketName = "flash-pdf-card.appspot.com";
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
  const [operation]: any = await client.asyncBatchAnnotateFiles(config as any);
  await operation.promise();

  const texts = await getFileContents(bucket, DestinationFolder);
  const res = await requestChatGPT(texts);
  // await bucket.deleteFiles({prefix: DestinationFolder}); // ファイルを削除する場合
  response.send(res);
});
