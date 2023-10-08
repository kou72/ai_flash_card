import axios from "axios";
import * as logger from "firebase-functions/logger";
import {system, userEx1, assistantEx1} from "./prompt";

export const generateQuestionsFromChatGPT = async ({
  input,
  gpt4,
}: {
  input: string;
  gpt4: boolean;
}) => {
  const URL = "https://api.openai.com/v1/chat/completions";
  const model = gpt4 ? "gpt-4" : "gpt-3.5-turbo";
  const temperature = 0;
  const maxTokens = null;
  const messages = [
    {role: "system", content: system},
    {role: "user", content: userEx1},
    {role: "assistant", content: assistantEx1},
    {role: "user", content: input},
  ];

  try {
    const response = await axios.post(
      URL,
      {
        model: model,
        messages: messages,
        temperature: temperature,
        max_tokens: maxTokens,
      },
      {
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`,
        },
      }
    );

    const res = response.data.choices[0].message.content;
    logger.info(res, {structuredData: true});
    return res;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    if (error.message) {
      console.error(error.message);
      logger.error(error.message, {structuredData: true});
    } else if (error.response.data) {
      console.error(error.response.data.error.message);
      logger.error(error.response.data.error.message, {structuredData: true});
    }
  }
};
