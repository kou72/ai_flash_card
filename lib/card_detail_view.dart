import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/database_provider.dart';
import 'card_dialog/card_delete_dialog.dart';

class CardDetailView extends ConsumerStatefulWidget {
  final int id;
  final int deckId;
  final String question;
  final String answer;
  final String note;
  // 新規でカードを作成するときはtrueにする
  final bool? isnew;
  const CardDetailView({
    super.key,
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.note,
    this.isnew,
  });
  @override
  CardDetailViewState createState() => CardDetailViewState();
}

class CardDetailViewState extends ConsumerState<CardDetailView> {
  bool _isnew = false;
  int _id = 0;
  String _question = '';
  String _answer = '';
  String _note = '';

  @override
  void initState() {
    super.initState();
    _isnew = widget.isnew ?? false;
    _id = widget.id;
    _question = widget.question;
    _answer = widget.answer;
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カード詳細'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('問題'),
              _textFieldCard(
                _question,
                (value) => setState(() => _question = value),
              ),
              const SizedBox(height: 24),
              const Text('答え'),
              _textFieldCard(
                _answer,
                (value) => setState(() => _answer = value),
              ),
              const SizedBox(height: 24),
              const Text('ノート'),
              _textFieldCard(
                _note,
                (value) => setState(() => _note = value),
              ),
              const SizedBox(height: 24),
              _saveButtonController(),
              const SizedBox(height: 12),
              _deleteButton(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldCard(String text, Function(String) onChanged) {
    // TextFieldの初期値をセット
    final controller = TextEditingController(text: text);
    // TextFieldのカーソルを末尾にするために必要
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    const cardWidth = 400.0;
    const cardHeight = 200.0;
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 24.0,
            right: 24.0,
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _saveButtonController() {
    // 新規作成の時はinsert、既存のカードの時はupdate
    if (_isnew) return _insertButton();
    return _updateButton();
  }

  Widget _insertButton() {
    final db = ref.watch(databaseProvider);
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        child: const Text('作成'),
        onPressed: () async {
          final id = await db.insertCard(
            widget.deckId,
            _question,
            _answer,
            _note,
          );
          setState(() {
            _id = id;
            _isnew = false;
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('新規作成しました！'),
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _updateButton() {
    final db = ref.watch(databaseProvider);
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        child: const Text('保存'),
        onPressed: () async {
          await db.updateCard(
            _id,
            _question,
            _answer,
            _note,
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存しました！'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _deleteButton() {
    final db = ref.watch(databaseProvider);
    return SizedBox(
      width: 200,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 0.5),
        ),
        child: const Text('削除', style: TextStyle(color: Colors.red)),
        onPressed: () async {
          final result = await _showDeleteCardDialog(context, _id);
          if (!result) return;
          await db.deleteCard(_id);
          if (!context.mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('カードを削除しました'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}

Future<bool> _showDeleteCardDialog(
  BuildContext context,
  int id,
) async {
  bool result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CardDeleteDialog();
    },
  );
  return result;
}
