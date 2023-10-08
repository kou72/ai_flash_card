import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/cards_state.dart';
import 'card_delete_dialog.dart';

class CardDetailView extends ConsumerStatefulWidget {
  final int id;
  final String question;
  final String answer;
  // final String note;
  const CardDetailView({
    super.key,
    required this.id,
    required this.question,
    required this.answer,
    // required this.note,
  });
  @override
  CardDetailViewState createState() => CardDetailViewState();
}

class CardDetailViewState extends ConsumerState<CardDetailView> {
  String _question = '';
  String _answer = '';
  String _note = '';

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _answer = widget.answer;
    // _note = widget.note;
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
              _saveButton(),
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

  Widget _saveButton() {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        child: const Text('保存'),
        onPressed: () async {
          await cardsDatabase.updateCard(
            widget.id,
            _question,
            _answer,
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存しました！')),
          );
        },
      ),
    );
  }

  Widget _deleteButton() {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return SizedBox(
      width: 200,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 0.5),
        ),
        child: const Text('削除', style: TextStyle(color: Colors.red)),
        onPressed: () async {
          final result = await _showDeleteCardDialog(context, widget.id);
          if (!result) return;
          await cardsDatabase.deleteCard(widget.id);
          if (!context.mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('カードを削除しました')),
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
