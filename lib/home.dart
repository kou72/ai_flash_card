import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI暗記カード (Demo版)'),
      ),
      body: Center(
        child: _objects(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('デッキ作成');
        },
        icon: const Icon(Icons.style),
        label: const Text('デッキ作成'),
      ),
    );
  }
}

Widget _objects() {
  return Column(
    children: [const Text('テストデッキ')],
  );
}
