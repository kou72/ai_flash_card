import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import '../type/types.dart';

// 以下コマンドでbuildして自動生成
// flutter pub run build_runner build --delete-conflicting-outputs
part 'database.g.dart';

class FlashCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().nullable().references(Decks, #id)();
  TextColumn get question => text()();
  TextColumn get answer => text()();
  TextColumn get note => text()();
  IntColumn get status => intEnum<CardStatus>()();
}

@DataClassName("Deck")
class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
}

@DriftDatabase(tables: [FlashCards, Decks])
class Database extends _$Database {
  Database._(QueryExecutor e) : super(e);

  factory Database() => Database._(connectOnWeb());

  @override
  int get schemaVersion => 1;

  // ローカルデータベースへアクセスするメソッドを設定
  Future insertDeck(String title) {
    return into(decks).insert(DecksCompanion.insert(title: title));
  }

  Future deleteDeck(int id) {
    return (delete(decks)..where((deck) => deck.id.equals(id))).go();
  }

  Future updateDeck(int id, String title) {
    return (update(decks)..where((deck) => deck.id.equals(id)))
        .write(DecksCompanion(title: Value(title)));
  }

  Future insertCard(int deckId, String question, String answer, String note) {
    return into(flashCards).insert(FlashCardsCompanion.insert(
      deckId: Value(deckId),
      question: question,
      answer: answer,
      note: note,
      status: CardStatus.none,
    ));
  }

  Future insertCardsFromJson(int deckId, String json) async {
    final List list = await Future.value(jsonDecode(json));
    await Future.forEach(list, (item) async {
      await insertCard(deckId, item["question"], item["answer"], item["note"]);
    });
  }

  Future deleteCard(int id) {
    return (delete(flashCards)..where((t) => t.id.equals(id))).go();
  }

  Future updateCard(int id, String question, String answer, String note) {
    return (update(flashCards)..where((t) => t.id.equals(id))).write(
        FlashCardsCompanion(
            question: Value(question),
            answer: Value(answer),
            note: Value(note)));
  }

  Future<List<FlashCard>> getCards(int deckId) {
    return (select(flashCards)..where((t) => t.deckId.equals(deckId))).get();
  }

  Future updateCardStatus(int id, CardStatus status) {
    return (update(flashCards)..where((t) => t.id.equals(id)))
        .write(FlashCardsCompanion(status: Value(status)));
  }
}

DatabaseConnection connectOnWeb() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'cards_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}
