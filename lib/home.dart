import 'package:flutter/material.dart';
import 'package:flash_pdf_card/deck_page.dart';
import 'package:flash_pdf_card/deck_dialog.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/decks_state.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksDatabase = ref.watch(decksDatabaseProvider);
    final decks = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI暗記カード (Demo版)'),
      ),
      body: Center(
        // child: _objects(),
        child: _deckList(decks),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await decksDatabase.insertDeck('デッキ');
        },
        icon: const Icon(Icons.style),
        label: const Text('デッキ作成'),
      ),
    );
  }

  Widget _deckList(AsyncValue decks) {
    return decks.when(
      data: (decks) {
        return ListView.builder(
          itemCount: decks.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.style),
              title: Text(decks[index].title),
              onTap: () {},
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('error: $error'),
    );
  }

  // Widget _objects() {
  //   return ListView.builder(
  //     itemCount: decks.length,
  //     itemBuilder: (context, index) {
  //       return ListTile(
  //         leading: const Icon(Icons.style),
  //         title: Text(decks[index]),
  //         onTap: () {
  //           if (!mounted) return;
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => Deck(
  //                       deckName: decks[index],
  //                     )),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showDeckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DeckDialog();
      },
    );
  }
}
