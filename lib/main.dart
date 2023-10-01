import 'package:flutter/material.dart';
// import 'package:flash_pdf_card/startscreen.dart';
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
      title: 'Flash PDF Card (Demo)',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      // home: const StartScreen(),
      home: const DeckListView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
