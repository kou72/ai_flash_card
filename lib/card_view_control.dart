import 'package:flutter/material.dart';
import "card_list_view.dart";
import "card_test_view.dart";

// bottomNavigationBarでページを出し分ける用のリスト
const _viewList = [
  CardListView(),
  CardTestView(),
];

class CardViewControl extends StatefulWidget {
  final String deckName;
  const CardViewControl({Key? key, required this.deckName}) : super(key: key);
  @override
  CardViewControlState createState() => CardViewControlState();
}

class CardViewControlState extends State<CardViewControl> {
  int _pageListIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      body: _viewList[_pageListIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'テスト',
          ),
        ],
        onTap: (index) => setState(() => _pageListIndex = index),
      ),
    );
  }
}
