import OpenAI from "openai";
import {OpenAIStream, StreamingTextResponse} from "ai";
import {Request} from "node-fetch";

const openai = new OpenAI({
  apiKey: "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",
});

const messages = [
  {
    role: "user",
    content: "こんにちは",
  },
];

const req = new Request("http://example.com/api/chat", {
  method: "POST",
  body: JSON.stringify({messages}),
  headers: {"Content-Type": "application/json"},
});

const fetchResponse = async () => {
  const {messages} = await req.json();

  const response = await openai.chat.completions.create({
    model: "gpt-3.5-turbo",
    stream: true,
    messages,
  });

  const openAIStream = OpenAIStream;
  const stream = openAIStream(response);
  // const textstream = new StreamingTextResponse(stream);
  // const body = await textstream.body;

  // console.log(res);

  const textDecoder = new TextDecoder("utf-8");

  // for await (const chunk of stream) {
  //   const text = textDecoder.decode(chunk);
  //   console.log(text);
  // }

  // for await (const chunk of body) {
  //   const text = textDecoder.decode(chunk);
  //   console.log(text);
  // }

  // eslint-disable-next-line no-constant-condition

  const reader = stream.getReader();

  // eslint-disable-next-line no-constant-condition
  while (true) {
    const {done, value} = await reader.read();
    if (done) {
      break;
    }
    const text = textDecoder.decode(value);
    console.log(text);
  }
};

fetchResponse();
