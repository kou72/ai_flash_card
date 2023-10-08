import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeckUpdateDialog extends ConsumerStatefulWidget {
  final String title;
  const DeckUpdateDialog({super.key, required this.title});
  @override
  DeckUpdateDialogState createState() => DeckUpdateDialogState();
}

class DeckUpdateDialogState extends ConsumerState<DeckUpdateDialog> {
  String _deckTitle = "";
  @override
  void initState() {
    super.initState();
    _deckTitle = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    // TextFieldの初期値をセット
    final controller = TextEditingController(text: _deckTitle);
    // TextFieldのカーソルを末尾にするために必要
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return AlertDialog(
      title: const Text('デッキを編集', style: TextStyle(fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(labelText: 'デッキ名'),
            onChanged: (String value) {
              setState(() => _deckTitle = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          child: const Text('変更', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.of(context).pop(_deckTitle),
        ),
      ],
    );
  }
}
