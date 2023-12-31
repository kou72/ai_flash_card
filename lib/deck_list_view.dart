import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget, AsyncValue, AsyncValueX;

// import file
import '/riverpod/database_provider.dart'
    show databaseProvider, decksStreamProvider;
import '/card_view_control.dart' show CardViewControl;
import '/deck_dialog/deck_insert_dialog.dart' show DeckInsertDialog;
import '/deck_dialog/deck_update_dialog.dart' show DeckUpdateDialog;
import '/deck_dialog/deck_delete_dialog.dart' show DeckDeleteDialog;

class DeckListView extends ConsumerStatefulWidget {
  const DeckListView({super.key});
  @override
  DeckListViewState createState() => DeckListViewState();
}

class DeckListViewState extends ConsumerState<DeckListView> {
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final decksStream = ref.watch(decksStreamProvider);
    return Scaffold(
      body: Center(
        child: _asyncDeckList(decksStream),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.style),
        label: const Text('デッキ作成'),
        onPressed: () async {
          final result = await _showInsertDeckDialog();
          if (result == null) return;
          await db.insertDeck(result);
        },
      ),
    );
  }

  Widget _asyncDeckList(AsyncValue decksStream) {
    return decksStream.when(
      data: (decks) => decks.isNotEmpty ? _deckList(decks) : _noDecksText(),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('error: $error'),
    );
  }

  Widget _noDecksText() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.style,
          color: Colors.grey,
          size: 64.0,
        ),
        SizedBox(height: 16.0),
        Text(
          '最初のデッキを作成しましょう！',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }

  Widget _deckList(List decks) {
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: Colors.white,
          leading: const Icon(Icons.style),
          title: Text(decks[index].title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardViewControl(
                  deckId: decks[index].id,
                  deckName: decks[index].title,
                ),
              ),
            );
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _updateDeckButton(decks[index].id, decks[index].title),
              _deleteDeckButton(decks[index].id, decks[index].title),
            ],
          ),
        );
      },
    );
  }

  Widget _updateDeckButton(int id, String title) {
    final db = ref.watch(databaseProvider);
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () async {
        final result = await _showUpdateDeckDialog(title);
        if (result == null) return;
        await db.updateDeck(id, result);
      },
    );
  }

  Widget _deleteDeckButton(int id, String title) {
    final db = ref.watch(databaseProvider);
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final result = await _showDeleteDeckDialog(title);
        if (!result) return;
        await db.deleteDeck(id);
      },
    );
  }

  Future<String?> _showInsertDeckDialog() async {
    String? result = await showDialog(
      context: context,
      builder: (BuildContext context) => const DeckInsertDialog(),
    );
    return result;
  }

  Future<String?> _showUpdateDeckDialog(String title) async {
    String? result = await showDialog(
      context: context,
      builder: (BuildContext context) => DeckUpdateDialog(title: title),
    );
    return result;
  }

  Future<bool> _showDeleteDeckDialog(String title) async {
    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) => DeckDeleteDialog(title: title),
    );
    return result;
  }
}
