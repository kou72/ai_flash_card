import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'components/gradient_container.dart';
import 'components/gradient_circular_progress_indicator.dart';
import 'riverpod/cards_state.dart';

class AiDialog extends ConsumerStatefulWidget {
  const AiDialog({Key? key}) : super(key: key);
  @override
  AiDialogState createState() => AiDialogState();
}

class AiDialogState extends ConsumerState<AiDialog> {
  String? _pickedFileName;
  String _pickedShowName = '画像を選択';
  Uint8List? _pickedFileBytes;
  IconData _pickedFileIcon = Icons.upload_file;
  String _errorText = '';
  bool _isLoading = false;

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
    setState(() => _isLoading = true);
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

    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    await cardsDatabase.insertCardsFromJson(response.body);

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: dialogTitle(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _dialogObject(),
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

  Widget dialogTitle() {
    if (_isLoading) {
      return const Text('カードを生成しています');
    } else {
      return const Text('画像からカード生成します');
    }
  }

  List<Widget> _dialogObject() {
    if (_isLoading) {
      return _loadingIndicator();
    } else {
      return _createCardButton();
    }
  }

  List<Widget> _createCardButton() {
    return [
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
    ];
  }

  List<Widget> _loadingIndicator() {
    return [
      const SizedBox(height: 16),
      const GradientCircularProgressIndicator(
        width: 100,
        height: 100,
        colors: [Colors.blue, Colors.purple],
        milliseconds: 1500,
      ),
    ];
  }
}
