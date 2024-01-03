// import 'package:hooks_riverpod/hooks_riverpod.dart';
// // import '../drift/decks_database.dart';
// import '../drift/cards_database.dart';

// // CardsDatabaseからDecksを抽出
// final decksDatabaseProvider = Provider((_) => CardsDatabase());

// final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
//   final db = ref.read(decksDatabaseProvider);
//   return db.select(db.decks).watch();
// });
