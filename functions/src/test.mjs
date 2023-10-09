// eslint-disable-next-line quotes, max-len
const text = `<1/3>問題:情報通信白書で取り上げられている、ICTとデジタル経済の進化の先にあるとされる社会の形態は何か？回答:Society 5.0
<2/3>問題:情報通信白書で語られている、ICTの新たな潮流として挙げられている3つの要素は何か？回答:デジタル・プラットフォーマー、AI、サイバーセキュリティ
<3/3>問題:情報通信白書で示されている、ICTがもたらした新たな経済の姿を表す4つの用語は何か？回答:xTech、シェアリングエコノミー、ギグエコノミー、デジタル・プラットフォーマー
<end>`;

const questionsStreamReader = async (questionsStream) => {
  const newReadableStream = new ReadableStream({});
  const reader = questionsStream.getReader();
  const textDecoder = new TextDecoder("utf-8");
  let questionsString = "";
  let isRecordingMeta = false;
  let metaString = "";

  // eslint-disable-next-line no-constant-condition
  while (true) {
    const {done, value} = await reader.read();
    if (done) {
      if (!metaString.includes("<end>")) {
        throw new Error("出力が完了しませんでした。");
      }
      break;
    }

    const text = textDecoder.decode(value);
    questionsString += text;

    if (text === "<") {
      metaString = "";
      isRecordingMeta = true;
    }

    if (isRecordingMeta) metaString += text;

    if (text === ">") {
      isRecordingMeta = false;
      if (metaString.includes("<end>")) {
        console.log("100%");
      } else {
        const regex = /^<(\d+)\/(\d+)>$/; // 正規表現パターン
        const match = metaString.match(regex);
        const count = parseInt(match[1], 10) - 1;
        const total = parseInt(match[2], 10);
        const progress = (count / total) * 100;
        console.log(progress.toFixed(0), "%");
      }
    }
  }

  console.log(questionsString);
  return questionsString;
};

const encoder = new TextEncoder();
const stream = new ReadableStream({
  async start(controller) {
    for (let i = 0; i < text.length; i++) {
      await new Promise((resolve) => setTimeout(resolve, 100));
      controller.enqueue(encoder.encode(text[i]));
    }
    controller.close();
  },
});

questionsStreamReader(stream)
  .pipeTo()
  .then((result) => console.log("Final Result:", result))
  .catch((error) => console.error("Error:", error));
