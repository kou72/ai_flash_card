import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flash_pdf_card/components/gradient_container.dart';

class AiDialog extends StatefulWidget {
  const AiDialog({Key? key}) : super(key: key);
  @override
  AiDialogState createState() => AiDialogState();
}

class AiDialogState extends State<AiDialog> {
  String? _pickedFileName;
  String _pickedShowName = '画像を選択';
  Uint8List? _pickedFileBytes;
  IconData _pickedFileIcon = Icons.upload_file;
  String _errorText = '';

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;
    PlatformFile file = result.files.first;

    setState(() {
      _pickedFileName = file.name;
      String head =
          file.name.length >= 5 ? file.name.substring(0, 5) : file.name;
      String extension = file.name.split(".").last;
      _pickedShowName = "$head...$extension";
      _pickedFileBytes = file.bytes;
      _pickedFileIcon = Icons.check_circle;
      _errorText = '';
    });
  }

  Future<void> _createFlashcards() async {
    if (_pickedFileName == null) {
      setState(() => _errorText = '※画像を選択してください');
      return;
    }
    // final url =
    //     Uri.https('generateflashcardquestions-vhoidcprtq-uc.a.run.app', '');
    // デバック用
    final url = Uri.http('127.0.0.1:5001',
        'flash-pdf-card/us-central1/generateImageToQuestions');
    final req = http.MultipartRequest('POST', url);
    final encodeFileName = base64Encode(utf8.encode(_pickedFileName!));
    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        _pickedFileBytes!,
        filename: encodeFileName,
      ),
    );
    final streamedResponse = await req.send();
    final response = await http.Response.fromStream(streamedResponse);

    print(response.body);
    print("finish");

    // // ローカルストレージに保存
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('questionsData', response.body);

    // if (!mounted) return;
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => ResultScreen(questionsData: response.body)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('画像からカード生成します'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GradientContainer(
            text: _pickedShowName,
            iconData: _pickedFileIcon,
            width: 200,
            height: 100,
            colors: const [Colors.blue, Colors.purple],
            onTap: () {
              _pickImages();
            },
          ),
          const SizedBox(height: 16),
          GradientContainer(
            text: "カードを生成",
            iconData: Icons.history_edu,
            width: 200,
            height: 100,
            colors: const [Colors.blue, Colors.purple],
            onTap: () {
              _createFlashcards();
            },
          ),
          const SizedBox(height: 8),
          Text(_errorText, style: const TextStyle(color: Colors.redAccent)),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
