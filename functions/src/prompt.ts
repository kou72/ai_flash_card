/* eslint-disable quotes */
/* eslint-disable max-len */
export const system = `入力されるテキストは資格勉強に使われる参考書からの抜粋文である。テキスト中暗記するべき専門用語を抽出し、それらが回答となる問題文を作成してください。問題文は文脈関係なく回答可能なように、前提条件や背景込みで出題すること。`;

export const userEx1 = `2.1.2 IntServ モデル
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

export const assistantEx1 = `
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

export const userEx2 = `オペレーションマニュアル-セキュリティ QX-S1100G シリーズ Ethernet スイッチ 
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

export const assistantEx2 = `問題: これは、特定のシステムや装置の操作手順や詳細を記述したマニュアルのことを何と言いますか？
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
