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
    );
  }
}
