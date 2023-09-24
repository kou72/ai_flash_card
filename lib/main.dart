import 'package:flutter/material.dart';
import 'package:flash_pdf_card/startscreen.dart';
import 'package:flash_pdf_card/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flash_pdf_card/drift/filename.dart';

final databaseProvider = Provider((_) => MyWebDatabase());

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.read(databaseProvider);
  return db.select(db.categories).watch();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAnalytics.instance.logEvent(name: 'page_view');

  // final database = MyWebDatabase();
  // // Simple insert:
  // await database
  //     .into(database.categories)
  //     .insert(CategoriesCompanion.insert(description: 'my first category'));

  // // Simple select:
  // final allCategories = await database.select(database.categories).get();
  // print('Categories in database: $allCategories');

  // runApp(const MyApp());
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash PDF Card (Demo)',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      // home: const StartScreen(),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// class MyApp extends HookConsumerWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final helloWorld = ref.watch(helloWorldProvider);

//     return MaterialApp(
//       title: 'Flash PDF Card (Demo)',
//       theme: ThemeData(
//         primarySwatch: Colors.blueGrey,
//       ),
//       // home: const StartScreen(),
//       // home: const Home(),
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Example')),
//         body: Center(
//           child: Text(helloWorld.schemaVersion.toString()),
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
