import 'package:hooks_riverpod/hooks_riverpod.dart'
    show Provider, StreamProvider;
import '/drift/database.dart' show Database, Deck, FlashCard;

final databaseProvider = Provider((_) => Database());

final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
  final db = ref.read(databaseProvider);
  return db.select(db.decks).watch();
});

final cardsStreamProvider =
    StreamProvider.family<List<FlashCard>, int>((ref, deckId) {
  final db = ref.read(databaseProvider);
  final cardsStream = db.select(db.flashCards)
    ..where((card) => card.deckId.equals(deckId));
  return cardsStream.watch();
});
