import 'package:flutter/material.dart';
import 'package:flash_pdf_card/startscreen.dart';

void main() => runApp(const MyApp());

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
