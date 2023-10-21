import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeckDeleteDialog extends ConsumerStatefulWidget {
  final String title;
  const DeckDeleteDialog({super.key, required this.title});
  @override
  DeckDeleteDialogState createState() => DeckDeleteDialogState();
}

class DeckDeleteDialogState extends ConsumerState<DeckDeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('このデッキを削除しますか？', style: TextStyle(fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(widget.title)],
      ),
      actions: [
        TextButton(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text('削除', style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
