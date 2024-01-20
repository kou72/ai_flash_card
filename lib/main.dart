import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ProviderScope, ConsumerStatefulWidget, ConsumerState;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_analytics/firebase_analytics.dart'
    show FirebaseAnalytics;
import 'package:drift_db_viewer/drift_db_viewer.dart' show DriftDbViewer;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:url_launcher/url_launcher_string.dart' show launchUrlString;

// import file
import '/firebase/firebase_options.dart' show DefaultFirebaseOptions;
import '/riverpod/database_provider.dart' show databaseProvider;
import '/deck_list_view.dart' show DeckListView;

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
      title: 'Ai暗記カード',
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
        title: const Text('Ai暗記カード'),
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
      child: Image.asset('assets/icon.png'),
    );
  }

  Widget _drawList() {
    return ListView(
      children: <Widget>[
        // デバッグ中のみ表示
        kDebugMode ? _driftDbViewer() : const SizedBox(),
        _homepageLink(),
        _termsLink(),
        _privacyLink(),
      ],
    );
  }

  Widget _driftDbViewer() {
    final db = ref.watch(databaseProvider);
    return ListTile(
      title: const Text('DriftDbViewer'),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriftDbViewer(db),
          ),
        );
      },
    );
  }

  Widget _homepageLink() {
    return ListTile(
      title: const Text('ホームページ'),
      onTap: () => launchUrlString('https://ankidoc.site/'),
      leading: const Icon(Icons.open_in_new),
    );
  }

  Widget _termsLink() {
    return ListTile(
      title: const Text('利用規約'),
      onTap: () => launchUrlString('https://ankidoc.site/terms'),
      leading: const Icon(Icons.open_in_new),
    );
  }

  Widget _privacyLink() {
    return ListTile(
      title: const Text('プライバシーポリシー'),
      onTap: () => launchUrlString('https://ankidoc.site/privacy'),
      leading: const Icon(Icons.open_in_new),
    );
  }
}
