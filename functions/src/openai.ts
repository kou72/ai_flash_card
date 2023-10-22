import OpenAI from "openai";
import {OpenAIStream} from "ai";
import {ChatCompletionMessageParam} from "openai/resources/chat";
import * as logger from "firebase-functions/logger";
import {system, userEx1, assistantEx1} from "./prompt";

const openai = new OpenAI({
  apiKey: `${process.env.OPENAI_API_KEY}`,
});

export const generateQuestionsFromChatGPT = async ({
  input,
  gpt4,
}: {
  input: string;
  gpt4: boolean; // gpt4を使う場合trueにする
}): Promise<ReadableStream | undefined> => {
  const model = gpt4 ? "gpt-4" : "gpt-3.5-turbo";
  const temperature = 0;
  const messages: ChatCompletionMessageParam[] = [
    {role: "system", content: system},
    {role: "user", content: userEx1},
    {role: "assistant", content: assistantEx1},
    {role: "user", content: input},
  ];

  try {
    const response = await openai.chat.completions.create({
      model: model,
      messages: messages,
      temperature: temperature,
      stream: true,
    });

    const openAIStream = OpenAIStream;
    const stream = openAIStream(response);
    return stream;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    if (error.message) {
      console.error(error.message);
      logger.error(error.message, {structuredData: true});
    } else if (error.response.data) {
      console.error(error.response.data.error.message);
      logger.error(error.response.data.error.message, {structuredData: true});
    }
    throw error;
  }
};
