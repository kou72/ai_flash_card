import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash PDF Card',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);
  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  String? _pickedFileName = '';
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _pickedFileName = file.name;
      });
      // ここでファイルをアップロードするロジックを実装する
    } else {
      // ユーザーがファイル選択をキャンセルした場合の処理
    }
  }

  Future<void> _createFlashcards() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

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
              onPressed: _pickPDF,
              child: const Text('PDFをアップロード'),
            ),
            const SizedBox(height: 20.0),
            Text('選択されたファイル: $_pickedFileName'),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _createFlashcards,
                    child: const Text('暗記カードを作成'),
                  ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗記カードの結果'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('ダミーの質問1'),
            subtitle: Text('ダミーの答え1'),
          ),
          ListTile(
            title: Text('ダミーの質問2'),
            subtitle: Text('ダミーの答え2'),
          ),
        ],
      ),
    );
  }
}
