import 'package:flutter/material.dart';

class CardDetailView extends StatefulWidget {
  const CardDetailView({super.key});
  @override
  CardDetailViewState createState() => CardDetailViewState();
}

class CardDetailViewState extends State<CardDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text('問題'),
          _textFildCard(),
          const SizedBox(height: 24),
          const Text('答え'),
          _textFildCard(),
        ],
      ),
    );
  }

  Widget _textFildCard() {
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
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (String value) {
              // setState(() => _deckName = value);
            },
          ),
        ),
      ),
    );
  }
}
