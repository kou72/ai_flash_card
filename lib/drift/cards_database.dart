import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// 以下コマンドでbuildして自動生成
// flutter pub run build_runner build --delete-conflicting-outputs
part 'cards_database.g.dart';

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().nullable()();
  TextColumn get question => text()();
  TextColumn get answer => text()();
  TextColumn get note => text()();
}

@DriftDatabase(tables: [Cards])
class CardsDatabase extends _$CardsDatabase {
  CardsDatabase._(QueryExecutor e) : super(e);

  factory CardsDatabase() => CardsDatabase._(connectOnWeb());

  @override
  int get schemaVersion => 1;

  // ローカルデータベースへアクセスするメソッドを設定
  Future insertCard(int deckId, String question, String answer, String note) {
    return into(cards).insert(CardsCompanion.insert(
      deckId: Value(deckId),
      question: question,
      answer: answer,
      note: note,
    ));
  }

  Future insertCardsFromJson(int deckId, String json) async {
    final List list = await Future.value(jsonDecode(json));
    await Future.forEach(list, (item) async {
      await insertCard(deckId, item["question"], item["answer"], item["note"]);
    });
  }

  Future deleteCard(int id) {
    return (delete(cards)..where((t) => t.id.equals(id))).go();
  }

  Future updateCard(int id, String question, String answer, String note) {
    return (update(cards)..where((t) => t.id.equals(id))).write(CardsCompanion(
        question: Value(question), answer: Value(answer), note: Value(note)));
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
