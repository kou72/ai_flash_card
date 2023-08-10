import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash PDF Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);
  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash PDF Card'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'PDFの内容を読み取り暗記カードを作成します',
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadAndProcessScreen()),
                );
              },
              child: const Text('PDFをアップロード'),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadAndProcessScreen extends StatefulWidget {
  const UploadAndProcessScreen({Key? key}) : super(key: key);
  @override
  UploadAndProcessScreenState createState() => UploadAndProcessScreenState();
}

class UploadAndProcessScreenState extends State<UploadAndProcessScreen> {
  bool _isUploading = false;
  double _progressValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アップロード&処理'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // PDFアップロードのロジックをここに実装
                // 例: uploadPDF();
              },
              child: const Text('PDFをアップロード'),
            ),
            const SizedBox(height: 20),
            if (_isUploading) ...[
              const Text('処理中...'),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _progressValue),
            ],
          ],
        ),
      ),
    );
  }

  // この関数はPDFのアップロードとテキスト抽出のロジックを示すダミーです。
  // 実際のロジックを実装する際には、適切な方法で更新する必要があります。
  Future<void> uploadPDF() async {
    setState(() {
      _isUploading = true;
      _progressValue = 0.1;
    });

    // PDFのアップロードとテキスト抽出のロジックをここに実装

    setState(() {
      _progressValue = 1.0;
      _isUploading = false;
    });
  }
}
