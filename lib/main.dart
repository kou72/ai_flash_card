import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'deck_list_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      home: Scaffold(
        appBar: AppBar(
          leadingWidth: 48.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: SvgPicture.asset('assets/icon.svg'),
          ),
          title: const Text('AI暗記カード'),
        ),
        endDrawer: Drawer(child: _drawerList(context)),
        body: const DeckListView(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _drawerList(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: const Text('SQLite Viewer'),
          onTap: () {
            print('SQLite Viewer');
          },
        ),
      ],
    );
  }
}
