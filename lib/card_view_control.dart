import 'package:flutter/material.dart';
import "card_list_view.dart";
import 'test_setting_view.dart';

class CardViewControl extends StatefulWidget {
  final int deckId;
  final String deckName;
  const CardViewControl({
    super.key,
    required this.deckId,
    required this.deckName,
  });
  @override
  CardViewControlState createState() => CardViewControlState();
}

class CardViewControlState extends State<CardViewControl> {
  int _pageListIndex = 0;
// bottomNavigationBarでページを出し分ける用のリスト
  late final _viewList = [
    CardListView(deckId: widget.deckId),
    TestSettingView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      body: _viewList[_pageListIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageListIndex,
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
