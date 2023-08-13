import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import vision from "@google-cloud/vision";
import axios from "axios";

// import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const storage = admin.storage();
const bucket = storage.bucket();

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

const requestChatGPT = async (input: string) => {
  const URL = "https://api.openai.com/v1/chat/completions";
  const model = "gpt-4";
  const temperature = 0;
  const maxTokens = null;
  const messages = [
    {role: "system", content: system},
    {role: "user", content: userEx1},
    {role: "assistant", content: assistantEx1},
    {role: "user", content: userEx2},
    {role: "assistant", content: assistantEx2},
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

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
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

  const texts = await getFileContents(DestinationFolder);
  const res = await requestChatGPT(texts);
  await bucket.deleteFiles({prefix: DestinationFolder});
  response.send(res);
});

const system = `入力されるテキストは資格勉強に使われる参考書からの抜粋文である。
テキスト中暗記するべき専門用語を抽出し、それらが回答となる問題文を作成してください。
問題文は文脈関係なく回答可能なように、前提条件や背景込みで出題すること。`;

const userEx1 = `2.1.2 IntServ モデル
IntServ(integrated service) は、 複数の多様なQoS 要件に適用できる多重サービスモデ
ルです。 このモデルは、 各データフローに QoS を保証、 識別することができ、きめ細か
く差別化されたQoS を提供します。
IntServ モデルでは、データを送信する前にアプリケーション上で、 特定の種類のサービ
スを使用できるようにネットワークへ要求する必要があります。 IntServ の要求は、 RSVP
シグナリングによって行われます。 RSVP は、 送信元から宛先までの装置で動作し、デー
タフローがあらかじめ要求/予約したリソースより多くのリソースを使わないよう、各ア
プリケーションフローをモニタします。
IntServ は装置の高い処理能力が必要となります。 IntServ モデルはネットワークへの大量
のデータトラフィックが、 ストレージデバイスの処理能力に非常に大きな負担がかかりま
す。したがって多くのデータフローが流れるコアインターネット網や何百万のフローが流
れるネットワークなどの大規模のネットワークでは利用されず、 IntServ モデルは中小規
模のネットワークで利用されます。
6-2-1`;

const assistantEx1 = `
問題: この多重サービスモデルは、複数の多様なQoS要件に適用できるもので、きめ細かく差別化されたQoSを提供します。何というモデルでしょうか？
回答: IntServ (integrated service)

問題: 網の品質や性能を示すための指標で、特定のネットワーク上のサービス品質を指定または測定するための能力を指す言葉は何でしょうか？
回答: QoS (Quality of Service)

問題: IntServモデルで、データの送信要求をネットワークへ行う際に使われるシグナリング技術は何という名前ですか？
回答: RSVP シグナリング

問題: ネットワーク上での情報の移動、特に一つの送信元から一つの宛先への情報の流れを何と呼びますか？
回答: データフロー

問題: ネットワーク上で特定のアプリケーションに関連する情報の流れを指す言葉は何でしょうか？
回答: アプリケーションフロー

問題: データを電子的に保存するためのハードウェアデバイスの一般的な名称は何でしょうか？
回答: ストレージデバイス

問題: 多くのデータフローが流れる、インターネットの主要部分を指す言葉は何でしょうか？
回答: コアインターネット網
`;

const userEx2 = `オペレーションマニュアル-セキュリティ QX-S1100G シリーズ Ethernet スイッチ 
1章 AAA 1.1 
概要 AAA は認証(Authentication)、許可(Authorization)、 アカウンティング (Accounting) の3つの
セキュリティ機能の総称です。 実用的なネットワークアクセス管理を行うための フレームワークを提供します。 
それぞれの以下のセキュリティを提供します。 認証 - リモートユーザを特定し、 有効なユーザか否かを判断します。 
許可(認可) 認証に成功したユーザに対して提供する権限を制限します。 アカウンティング (課金) サービスタイプ、 開始/終了の時間、 
トラフィックを 含む、認証に成功したユーザのネットワークサービスの使用情報を取得します。これ により、 アカウンティング機能は、 
時間ベースおよびトラフィックベースで、ネット ワークセキュリティの監視にも使用することができます。 
通常、AAA ではクライアント/サーバモデルを使用します。 クライアントは NAS (Network Access Server) 上で動作し、
サーバで集中的にユーザ情報を管理します。 AAA ネットワ ークにおいて、 図 1-1に示すように、 NAS はユーザのためのサーバですが、 
AAA サーバ のためのクライアントでもあります。 
Remote user Network MAS NAS ROUTER RADIUS server 1 7-1-1 
1章 AAA RADIUS server 2 図 1-1 AAAのネットワーク構成 Internet ユーザが NAS への接続を確立し、ほかのネットワーク、 
またはいくつかのネットワーク リソースにアクセスするための権利を取得しようとする場合、 NAS は、 ユーザ、または 対応する接続を認証します。 
NAS はユーザのAAA情報をサーバ (RADIUS サーバ)に透 過的に通すことができます。その結果 NASはアクセス要求を許可/禁止するか決定します。 
AAA を実現する方法として、最も使用されるものとして RADIUS があります。 
図 1-1に示すように、 RADIUS サーバ1 と RADIUS サーバ 2 があります。 
この場合、 必要 に応じて、認証、許可、 アカウンティングの役割を決めることができます。 たとえば、 RADIUS サーバ2を認証と許可に使用し、 
RADIUS サーバ1をアカウンティングサーバに することができます。`;

const assistantEx2 = `問題: これは、特定のシステムや装置の操作手順や詳細を記述したマニュアルのことを何と言いますか？
回答: オペレーションマニュアル

問題: 認証(Authentication)、許可(Authorization)、アカウンティング(Accounting) の
3つのセキュリティ機能の総称をなんと呼びますか？
回答: AAA

問題: リモートユーザを特定し、有効なユーザか否かを判断するセキュリティ機能は何と呼ばれますか？
回答: 認証

問題: 認証に成功したユーザに対して提供する権限を制限する機能を何と呼びますか？
回答: 許可(認可)

問題: 認証に成功したユーザのネットワークサービスの使用情報を取得するセキュリティ機能は何と呼ばれますか？
回答: アカウンティング

問題: AAAネットワークにおいて、ユーザのためのサーバであり、AAAサーバのためのクライアントでもある装置は何と呼ばれますか？
回答: NAS (Network Access Server)

問題: AAAを実現する方法として、認証、許可、アカウンティングの役割を中心的に担うサーバの一つは何と呼ばれますか？
回答: RADIUS

問題: AAAネットワーク構成図において、ユーザ情報や認証・許可・アカウンティングの情報を集中的に管理するサーバは何と呼ばれますか？
回答: RADIUS サーバ`;

// const input = `オペレーションマニュアルアクセス
// QX-S1100G シリーズ Ethernet スイッチ 13章 L2PT 13.1
// 概要 L2PT(Layer 2 Protocol Tunneling) を使用すると地理的に分散されている
// カスタマネットワークをサービスプロバイダネットワーク経由でレイヤ 2 プロトコルパケットを送信 できます。
// 13.1.1 背景 特定ユーザ向けのレイヤ2ネットワークを構築するため、サービスプロバイダネットワー クで専用線が使用されます。
// その結果、 カスタマネットワークはサービスプロバイダネッ トワークの異なるサイドに存在します。
// 図 13-1に示すように Customer A ネットワークはサービスプロバイダによって接続されて いるネットワーク1とネットワーク2に分割されています。
// Customer A ネットワークで レイヤ2プロトコルの計算を行うため、
// レイヤ2 プロトコルのパケットはサービスプロバ イダネットワークを通過して転送される必要があります。
// PE がレイヤ2 プロトコルパケットを受信した場合､PEはカスタマネットワークから受信 されたパケットなのか
// サービスプロバイダネットワークからのパケットなのか判断する ことができません。 このプロセス処理を行うため、
// CPU にパケットを転送する必要があ ります。この場合、 Customer A ネットワークのレイヤ2 プロトコルの計算は、
// サービス プロバイダネットワークのレイヤ2プロトコルの計算と一緒に行われます。
// カスタマネッ トワークあるいはサービスプロバイダネットワークのどちらも、独立してレイヤ2プロト コルの計算を行うことができません。
// CE 1 Customer A network 1 VLAN 100 PE 1 ISP network
// 13章 L2PT PE2 2-13-1 CE2 Customer A network 2 VLAN 100 図 L2PT アプリケーションシナリオ`;
