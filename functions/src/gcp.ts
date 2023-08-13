import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
const storage = admin.storage();
type Bucket = ReturnType<typeof storage.bucket>;

export const getFileContents = async (
  bucket: Bucket,
  DestinationFolder: string
) => {
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
