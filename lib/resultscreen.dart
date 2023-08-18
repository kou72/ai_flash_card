import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String resultText;
  const ResultScreen({Key? key, required this.resultText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗記カードの結果'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('質問: ${resultText}'), // 例として、ここでresultTextを表示しています
            // subtitle: Text('答え: ${resultText}'),
          ),
        ],
      ),
    );
  }
}
