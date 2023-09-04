import 'package:flutter/material.dart';
import 'package:flash_pdf_card/startscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAnalytics.instance.logEvent(name: 'page_view');
  runApp(const MyApp());
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
      home: const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
