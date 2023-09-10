import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final List<String> decks = [
    'デッキ1',
    'デッキ2',
    'デッキ3',
    // ... (他のデッキデータも追加可能)
  ];

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

  Widget _objects() {
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.style),
          title: Text(decks[index]),
          onTap: () {
            // タップされたときの処理（例：そのデッキの詳細を表示）
          },
        );
      },
    );
  }
}
