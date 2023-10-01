import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
part 'cards_database.g.dart';

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get question => text()();
  TextColumn get answer => text()();
}

@DriftDatabase(tables: [Cards])
class CardsDatabase extends _$CardsDatabase {
  CardsDatabase._(QueryExecutor e) : super(e);

  factory CardsDatabase() => CardsDatabase._(connectOnWeb());

  @override
  int get schemaVersion => 1;

  Future insertDeck(String question, String answer) {
    return into(cards)
        .insert(CardsCompanion.insert(question: question, answer: answer));
  }
}

DatabaseConnection connectOnWeb() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'cards_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      print('Using ${result.chosenImplementation} due to missing browser '
          'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}
