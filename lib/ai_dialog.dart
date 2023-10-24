import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/gradient_container.dart';
import 'components/gradient_circular_spinning_indicator.dart';
import 'components/gradient_circular_progress_indicator.dart';
import 'riverpod/cards_state.dart';

class AiDialog extends ConsumerStatefulWidget {
  final int deckId;
  const AiDialog({super.key, required this.deckId});
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
  bool _isError = false;
  double _progress = 0.0;

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;
    PlatformFile file = result.files.first;

    setState(() {
      _pickedFileName = file.name;
      _pickedFileBytes = file.bytes;
      _pickedFileIcon = Icons.check_circle;
      _errorText = '';
      // ファイル名が長い場合、先頭5文字と拡張子を表示
      String head =
          file.name.length >= 5 ? file.name.substring(0, 5) : file.name;
      String extension = file.name.split(".").last;
      _pickedShowName = "$head...$extension";
    });
  }

  Future<void> _createFlashcards() async {
    if (_pickedFileName == null) {
      setState(() => _errorText = '※画像を選択してください');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.https('generateimagetoqa-vhoidcprtq-uc.a.run.app', '');
      // // デバック用
      // final url = Uri.http(
      //     '127.0.0.1:5001', 'flash-pdf-card/us-central1/generateImageToQa');
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
      final docid = response.body;
      final db = FirebaseFirestore.instance;
      final docRef = db.collection("aicard").doc(docid);

      final listener = docRef.snapshots().listen((doc) {
        final done = (doc.data() as Map<String, dynamic>)['done'];
        if (done == true) setState(() => _progress = 1);
      });

      while (_progress < 1) {
        const max = 90;
        if (_progress < max - 1 / max) setState(() => _progress += 1 / max);
        await Future.delayed(const Duration(seconds: 1));
      }

      listener.cancel();
      final doneDoc = await docRef.get();
      final cardData = (doneDoc.data() as Map<String, dynamic>)['data'];
      final cardJson = jsonEncode(cardData);

      final cardsDatabase = ref.watch(cardsDatabaseProvider);
      await cardsDatabase.insertCardsFromJson(widget.deckId, cardJson);

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
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
          child: buttonText(),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget dialogTitle() {
    if (_isError) return const Text('エラーが発生しました');
    if (_isLoading) return const Text('カードを生成しています');
    return const Text('画像からカード生成します');
  }

  Widget buttonText() {
    if (_isError) return const Text('OK');
    return const Text('キャンセル', style: TextStyle(color: Colors.blue));
  }

  List<Widget> _dialogObject() {
    const errorStyle = TextStyle(color: Colors.redAccent);
    if (_isError) return [const Text('画像の読み取りに失敗しました', style: errorStyle)];
    if (_isLoading) return _loadingIndicator(_progress);
    return _createCardButton();
  }

  List<Widget> _createCardButton() {
    return [
      GradientContainer(
        text: _pickedShowName,
        iconData: _pickedFileIcon,
        width: 200,
        height: 100,
        colors: const [Colors.blue, Colors.purple],
        onTap: () => _pickImages(),
      ),
      const SizedBox(height: 16),
      GradientContainer(
        text: "カードを生成",
        iconData: Icons.history_edu,
        width: 200,
        height: 100,
        colors: const [Colors.blue, Colors.purple],
        onTap: () => _createFlashcards(),
      ),
      const SizedBox(height: 8),
      Text(_errorText, style: const TextStyle(color: Colors.redAccent)),
    ];
  }

  List<Widget> _loadingIndicator(double? progress) {
    if (progress == null || progress == 0) {
      return [
        const SizedBox(height: 16),
        const GradientCircularSpinningIndicator(
          width: 100,
          height: 100,
          colors: [Colors.blue, Colors.purple],
          milliseconds: 1500,
        ),
      ];
    } else {
      return [
        const SizedBox(height: 16),
        GradientCircularProgressIndicator(
          width: 100,
          height: 100,
          colors: const [Colors.blue, Colors.purple],
          progress: progress,
        ),
      ];
    }
  }
}
