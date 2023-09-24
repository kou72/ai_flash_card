import 'package:flutter/material.dart';
import 'package:flash_pdf_card/deck_page.dart';
import 'package:flash_pdf_card/deck_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/decks_state.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksStream = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI暗記カード (Demo版)'),
      ),
      body: Center(
        child: _asyncDeckList(decksStream),
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
}

Widget _asyncDeckList(AsyncValue decksStream) {
  return decksStream.when(
    data: (decks) => _deckList(decks),
    loading: () => const CircularProgressIndicator(),
    error: (error, stackTrace) => Text('error: $error'),
  );
}

Widget _deckList(List decks) {
  return ListView.builder(
    itemCount: decks.length,
    itemBuilder: (context, index) {
      return ListTile(
        leading: const Icon(Icons.style),
        title: Text(decks[index].title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeckPage(
                deckName: decks[index].title,
              ),
            ),
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
