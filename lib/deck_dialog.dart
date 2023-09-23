import 'package:flutter/material.dart';

class DeckDialog extends StatefulWidget {
  const DeckDialog({Key? key}) : super(key: key);
  @override
  DeckDialogState createState() => DeckDialogState();
}

class DeckDialogState extends State<DeckDialog> {
  String _deckName = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('デッキを作成', style: TextStyle(fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              labelText: 'デッキ名',
            ),
            onChanged: (String value) {
              setState(() {
                _deckName = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('作成', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop(_deckName);
          },
        ),
      ],
    );
  }

  //新規作成Deckをローカルストレージに保存
  void _saveDeck(String deckName) async {}
}
