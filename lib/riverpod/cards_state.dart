import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../drift/cards_database.dart';

final cardsDatabaseProvider = Provider((_) => CardsDatabase());

// final cardsStreamProvider = StreamProvider<List<Card>>((ref) {
//   final db = ref.read(cardsDatabaseProvider);
//   return db.select(db.cards).watch();
// });

final cardsStreamProvider =
    StreamProvider.family<List<FlashCard>, int>((ref, deckId) {
  final db = ref.read(cardsDatabaseProvider);
  final cardsStream = db.select(db.flashCards)
    ..where((card) => card.deckId.equals(deckId));
  return cardsStream.watch();
  // return (db.select(db.cards)..where((card) => card.deckId.equals(deckId)))
  //     .watch();
});
