import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'deck_list_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/decks_state.dart';
import 'riverpod/cards_state.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.logEvent(name: 'page_view');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI暗記カード',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48.0,
        leading: _icon(),
        title: const Text('AI暗記カード'),
      ),
      endDrawer: Drawer(
        child: _drawList(),
      ),
      body: const DeckListView(),
    );
  }

  Widget _icon() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: SvgPicture.asset('assets/icon.svg'),
    );
  }

  Widget _drawList() {
    // final decksDb = ref.watch(decksDatabaseProvider);
    final cardsDb = ref.watch(cardsDatabaseProvider);
    return ListView(
      children: <Widget>[
        // デバッグ中のみ表示
        // kDebugMode
        //     ? ListTile(
        //         title: const Text('Decks DriftDbViewer'),
        //         onTap: () {
        //           Navigator.of(context).push(MaterialPageRoute(
        //               builder: (context) => DriftDbViewer(decksDb)));
        //         },
        //       )
        //     : const SizedBox(),

        // デバッグ中のみ表示
        kDebugMode
            ? ListTile(
                title: const Text('Cards DriftDbViewer'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DriftDbViewer(cardsDb)));
                },
              )
            : const SizedBox(),
      ],
    );
  }
}
