import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flash_pdf_card/components/gradient_container.dart';

class AiDialog extends StatefulWidget {
  const AiDialog({Key? key}) : super(key: key);
  @override
  AiDialogState createState() => AiDialogState();
}

class AiDialogState extends State<AiDialog> {
  String _pickedFileName = '画像を選択';
  Uint8List? _pickedFileBytes;
  IconData _pickedFileIcon = Icons.upload_file;

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;
    PlatformFile file = result.files.first;

    setState(() {
      String head =
          file.name.length >= 5 ? file.name.substring(0, 5) : file.name;
      String extension = file.name.split(".").last;
      _pickedFileName = "$head...$extension";
      _pickedFileBytes = file.bytes;
      _pickedFileIcon = Icons.check_circle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('画像からカード生成します'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GradientContainer(
            text: _pickedFileName,
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
              print('カードを生成');
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
