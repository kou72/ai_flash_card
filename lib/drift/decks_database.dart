import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

// 以下コマンドでbuildして自動生成
// flutter pub run build_runner build --delete-conflicting-outputs
part 'decks_database.g.dart';

class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
}

@DriftDatabase(tables: [Decks])
class DecksDatabase extends _$DecksDatabase {
  DecksDatabase._(QueryExecutor e) : super(e);

  factory DecksDatabase() => DecksDatabase._(connectOnWeb());

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
}

DatabaseConnection connectOnWeb() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'decks_db',
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
