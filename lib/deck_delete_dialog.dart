import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/decks_state.dart';

class DeckDeleteDialog extends ConsumerStatefulWidget {
  final int id;
  final String title;
  const DeckDeleteDialog({super.key, required this.id, required this.title});

  @override
  DeckDeleteDialogState createState() => DeckDeleteDialogState();
}

class DeckDeleteDialogState extends ConsumerState<DeckDeleteDialog> {
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
      title: const Text('このデッキを削除しますか？', style: TextStyle(fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_deckName),
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
          child: const Text('削除', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            await decksDatabase.deleteDeck(widget.id);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
