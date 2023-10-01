import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/decks_state.dart';

class DeckUpdateDialog extends ConsumerStatefulWidget {
  final int id;
  final String title;
  const DeckUpdateDialog({Key? key, required this.id, required this.title})
      : super(key: key);
  @override
  DeckUpdateDialogState createState() => DeckUpdateDialogState();
}

class DeckUpdateDialogState extends ConsumerState<DeckUpdateDialog> {
  String _deckName = "";

  @override
  void initState() {
    super.initState();
    _deckName = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final decksDatabase = ref.watch(decksDatabaseProvider);

    return AlertDialog(
      title: const Text('デッキを編集', style: TextStyle(fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: TextEditingController(text: _deckName),
            decoration: const InputDecoration(labelText: 'デッキ名'),
            onChanged: (String value) {
              setState(() => _deckName = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('変更', style: TextStyle(color: Colors.blue)),
          onPressed: () async {
            await decksDatabase.updateDeck(widget.id, _deckName);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
