import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "riverpod/cards_state.dart";
import "card_list_view.dart";
import 'test_setting_view.dart';

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
  dynamic _cards = [];
  // bottomNavigationBarでページを出し分ける用のリスト
  late final _viewList = [
    CardListView(deckId: widget.deckId),
    TestSettingView(deckName: widget.deckName, cards: _cards),
  ];

  @override
  Widget build(BuildContext context) {
    final cardsStream = ref.watch(cardsStreamProvider(widget.deckId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      // body: _viewList[_pageListIndex],
      body: _asyncViewList(cardsStream),
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

  Widget _asyncViewList(AsyncValue cardsStream) {
    return cardsStream.when(
      data: (cards) {
        _cards = cards;
        return _viewList[_pageListIndex];
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('error: $error'),
    );
  }
}
