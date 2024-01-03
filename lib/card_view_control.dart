import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import file
import "/card_list_view.dart" show CardListView;
import '/test_setting_view.dart' show TestSettingView;

class CardViewControl extends ConsumerStatefulWidget {
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

class CardViewControlState extends ConsumerState<CardViewControl> {
  int _pageListIndex = 0;
  late final _viewList = [
    CardListView(deckId: widget.deckId),
    TestSettingView(deckName: widget.deckName, deckId: widget.deckId),
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
