import OpenAI from "openai";
import {OpenAIStream} from "ai";
import {Request} from "node-fetch";

const openai = new OpenAI({
  apiKey: `${process.env.OPENAI_API_KEY}`,
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

  const stream = new OpenAIStream(response);
  const textDecoder = new TextDecoder("utf-8");

  for await (const chunk of stream) {
    const text = textDecoder.decode(chunk);
    console.log(text);
  }
};

fetchResponse();
