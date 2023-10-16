// const http = require("http");
import http from "http";

// オプションを設定
const options = {
  hostname: "127.0.0.1",
  port: 5001, // サーバのポート番号を指定
  path: "/flash-pdf-card/us-central1/test", // サーバのエンドポイントを指定
  method: "GET",
};

// リクエストを作成
const req = http.request(options, (res) => {
  // サーバからのレスポンスを処理
  res.on("data", (chunk) => {
    console.log(`BODY: ${chunk}`); // ストリーミングデータをコンソールに出力
  });

  res.on("end", () => {
    console.log("No more data in response."); // レスポンスの終了をコンソールに出力
  });
});

// エラーハンドリング
req.on("error", (e) => {
  console.error(`Problem with request: ${e.message}`); // エラーをコンソールに出力
});

// リクエストを終了
req.end();
