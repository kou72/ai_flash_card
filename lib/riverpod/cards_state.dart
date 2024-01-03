import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../drift/cards_database.dart';

final cardsDatabaseProvider = Provider((_) => CardsDatabase());

final cardsStreamProvider =
    StreamProvider.family<List<FlashCard>, int>((ref, deckId) {
  final db = ref.read(cardsDatabaseProvider);
  final cardsStream = db.select(db.flashCards)
    ..where((card) => card.deckId.equals(deckId));
  return cardsStream.watch();
});

final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
  final db = ref.read(cardsDatabaseProvider);
  return db.select(db.decks).watch();
});
