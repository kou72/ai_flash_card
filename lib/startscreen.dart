import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);
  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  String? _pickedFileName = '';
  // int? _pickedFileSize;
  Uint8List? _pickedFileBytes;
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;
    PlatformFile file = result.files.first;
    setState(() {
      _pickedFileName = file.name;
      // _pickedFileSize = file.size;
      _pickedFileBytes = file.bytes;
    });
  }

  Future<void> _testreq() async {
    print("testreq");

    // final url = Uri.https('documenttextdetection-vhoidcprtq-uc.a.run.app', '');
    // final url = Uri.https('helloworld-vhoidcprtq-uc.a.run.app');
    final url =
        Uri.http('127.0.0.1:5001', '/flash-pdf-card/us-central1/helloWorld');

    final req = http.MultipartRequest('POST', url);

    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        _pickedFileBytes!,
        filename: _pickedFileName!,
      ),
    );

    final streamedResponse = await req.send();
    final response = await http.Response.fromStream(streamedResponse);
    print(response.body);
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
        child: _objects(),
      ),
    );
  }

  Widget _objects() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'PDFの内容を読み取り暗記カードを作成します',
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _pickPDF,
          child: const Text('PDFを選択'),
        ),
        const SizedBox(height: 20.0),
        Text('選択されたファイル: $_pickedFileName'),
        const SizedBox(height: 20.0),
        _createFlashcardsButton(),
      ],
    );
  }

  Widget _createFlashcardsButton() {
    if (_isLoading == true) {
      return const CircularProgressIndicator();
    } else {
      return ElevatedButton(
        // onPressed: _createFlashcards,
        onPressed: _testreq,
        child: const Text('暗記カードを作成'),
      );
    }
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
