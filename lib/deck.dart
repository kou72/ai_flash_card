import 'package:flutter/material.dart';

class Deck extends StatefulWidget {
  final String deckName;
  const Deck({Key? key, required this.deckName}) : super(key: key);
  @override
  DeckState createState() => DeckState();
}

class DeckState extends State<Deck> {
  // @override
  // void initState() {
  //   super.initState();
  //   flashCardData = createFlashCardDataList(widget.questionsData);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      // body: ListView.builder(
      //   itemCount: flashCardData.length,
      //   itemBuilder: (context, index) {
      //     return _flashCard(index);
      //   },
      // ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "ai",
            icon: const Icon(Icons.smart_toy),
            label: const Text('画像からカード生成'),
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "card",
            icon: const Icon(Icons.edit),
            label: const Text('自分でカードを作成'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
