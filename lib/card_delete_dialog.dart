import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CardDeleteDialog extends ConsumerStatefulWidget {
  const CardDeleteDialog({super.key});
  @override
  CardDeleteDialogState createState() => CardDeleteDialogState();
}

class CardDeleteDialogState extends ConsumerState<CardDeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('このカードを削除しますか？', style: TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text('削除', style: TextStyle(color: Colors.red)),
          onPressed: () async => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
