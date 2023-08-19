import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flash_pdf_card/resultscreen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);
  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  String _pickedFileName = '';
  final _maxPageCount = 10;
  Uint8List? _pickedFileBytes;
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;
    PlatformFile file = result.files.first;
    PdfDocument docFromData = await PdfDocument.openData(file.bytes!);

    if (docFromData.pagesCount >= _maxPageCount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$_maxPageCount ページ以下のファイルを選択してください。'),
            backgroundColor: Colors.blueGrey),
      );
      return;
    }
    setState(() {
      _pickedFileName = file.name;
      _pickedFileBytes = file.bytes;
    });
  }

  Future<void> _createFlashcards() async {
    if (_pickedFileName == '') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDFを選択してください。'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final url =
        Uri.https('generateflashcardquestions-vhoidcprtq-uc.a.run.app', '');
    final req = http.MultipartRequest('POST', url);
    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        _pickedFileBytes!,
        filename: _pickedFileName,
      ),
    );

    final streamedResponse = await req.send();
    final response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    print(response.body);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          // builder: (context) => ResultScreen(resultText: response.body)),
          builder: (context) => ResultScreen()),
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
        _samplePDF(),
        const SizedBox(height: 20.0),
        _pdfPickContainer(),
        const SizedBox(height: 16.0),
        _createFlashcardsContainer(),
      ],
    );
  }

  Widget _samplePDF() {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(
          'https://www.soumu.go.jp/johotsusintokei/whitepaper/ja/r01/pdf/01point.pdf')),
      child: const Text(
        'サンプルのダウンロード',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _pdfPickContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      width: 200,
      height: 200,
      child: InkWell(
        onTap: () {
          _pickPDF();
        },
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.upload_file,
          color: Colors.blueGrey,
          size: 64.0,
        ),
        const SizedBox(height: 8.0),
        const Text(
          '1. PDFを選択',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16.0,
          ),
        ),
        Text(
          '※$_maxPageCount ページ以下',
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 12.0,
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      width: 200,
      height: 200,
      child: InkWell(
        onTap: () {
          _createFlashcards();
        },
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
