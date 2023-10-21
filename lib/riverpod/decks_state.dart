import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../drift/decks_database.dart';

final decksDatabaseProvider = Provider((_) => DecksDatabase());

final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
  final db = ref.read(decksDatabaseProvider);
  return db.select(db.decks).watch();
});
