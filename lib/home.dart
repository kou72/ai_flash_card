import 'package:flutter/material.dart';
import 'package:flash_pdf_card/deck.dart';
import 'package:flash_pdf_card/deck_dialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final List<String> decks = [
    'デッキ1',
    'デッキ2',
    'デッキ3',
    // ... (他のデッキデータも追加可能)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI暗記カード (Demo版)'),
      ),
      body: Center(
        child: _objects(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showDeckDialog(context);
        },
        icon: const Icon(Icons.style),
        label: const Text('デッキ作成'),
      ),
    );
  }

  Widget _objects() {
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.style),
          title: Text(decks[index]),
          onTap: () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Deck(
                        deckName: decks[index],
                      )),
            );
          },
        );
      },
    );
  }

  void _showDeckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DeckDialog();
      },
    );
  }
}
