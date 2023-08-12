import vision from "@google-cloud/vision";
import {Storage} from "@google-cloud/storage";

const credentialPath = "./flash-pdf-card-vision-api-54cb40473726.json";
process.env.GOOGLE_APPLICATION_CREDENTIALS = credentialPath;

const client = new vision.ImageAnnotatorClient();

// 実行時間のyyyyMMddhhmmssを取得
const date = new Date();
const formattedDate = `${date.getFullYear()}${String(
  date.getMonth() + 1
).padStart(2, "0")}${String(date.getDate()).padStart(2, "0")}${String(
  date.getHours()
).padStart(2, "0")}${String(date.getMinutes()).padStart(2, "0")}${String(
  date.getSeconds()
).padStart(2, "0")}`;

const bucketName = "flash-pdf-card-bucket";
const fileName = "test.pdf";
const gcsSourceUri = `gs://${bucketName}/${fileName}`;

const baseFileName = fileName.replace(".pdf", "");
const folderName = `${baseFileName}${formattedDate}/`;
const gcsDestinationUri = `gs://${bucketName}/${folderName}`;

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
const request = {
  requests: [
    {
      inputConfig: inputConfig,
      features: features,
      outputConfig: outputConfig,
    },
  ],
};

const getFileContents = async () => {
  const storage = new Storage();
  const bucket = storage.bucket(bucketName);
  const [files] = await bucket.getFiles({prefix: folderName});

  const [texts] = files.map(async (file) => {
    const json = bucket.file(file.name);
    const contents = await json.download();
    const jsonString = contents.toString("utf-8");
    const jsonData = JSON.parse(jsonString);
    return jsonData.responses[0].fullTextAnnotation.text;
  });

  return texts;
};

const [operation] = await client.asyncBatchAnnotateFiles(request);
await operation.promise();
const texts = await getFileContents();
console.log("texts: ", texts);
