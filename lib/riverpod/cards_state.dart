import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../drift/cards_database.dart';

final cardsDatabaseProvider = Provider((_) => CardsDatabase());

final cardsStreamProvider = StreamProvider<List<Card>>((ref) {
  final db = ref.read(cardsDatabaseProvider);
  return db.select(db.cards).watch();
});
