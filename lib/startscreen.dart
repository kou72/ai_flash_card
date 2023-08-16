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
  String _pickedFileName = '';
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
          'PDFを読み取り暗記カードを作成します',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 12.0),
        _pdfPickContainer(),
        _createFlashcardsContainer(),
        // const SizedBox(height: 20.0),
        // ElevatedButton(
        //   onPressed: _pickPDF,
        //   child: const Text('PDFを選択'),
        // ),
        // const SizedBox(height: 20.0),
        // Text('選択されたファイル: $_pickedFileName'),
        // const SizedBox(height: 20.0),
        // _createFlashcardsButton(),
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

  Widget _pdfPickContainer() {
    return GestureDetector(
      onTap: _pickPDF,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blueGrey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        width: 200,
        height: 200,
        child: _pdfIconSwitcher(),
      ),
    );
  }

  Widget _pdfIconSwitcher() {
    if (_pickedFileName == '') {
      return Center(child: _pdfPickerIcon());
    } else {
      return Center(child: _pdfPickedIcon());
    }
  }

  Widget _pdfPickerIcon() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.upload_file,
          color: Colors.blueGrey,
          size: 64.0,
        ),
        SizedBox(height: 8.0),
        Text(
          '1. PDFを選択',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _pdfPickedIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.check_circle,
          color: Colors.blueGrey,
          size: 64.0,
        ),
        const SizedBox(height: 8.0),
        Text(
          _pickedFileName,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _createFlashcardsContainer() {
    return GestureDetector(
      onTap: _createFlashcards,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blueGrey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        width: 200,
        height: 200,
        child: _createFlashcardsIconSwitcher(),
      ),
    );
  }

  Widget _createFlashcardsIconSwitcher() {
    if (_isLoading == false) {
      return Center(child: _createFlashcardsIcon());
    } else {
      return Center(child: _loadingIcon());
    }
  }

  Widget _createFlashcardsIcon() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.create,
          color: Colors.blueGrey,
          size: 64.0,
        ),
        SizedBox(height: 8.0),
        Text(
          '2. 暗記カードを作成',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _loadingIcon() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 64.0,
          height: 64.0,
          child: CircularProgressIndicator(),
        ),
        SizedBox(height: 16.0),
        Text(
          '暗記カードを作成中',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
          ),
        ),
        Text(
          '※5分程かかる場合があります',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 12.0,
          ),
        ),
      ],
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
