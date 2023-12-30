import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "riverpod/cards_state.dart";
import 'test_play_view.dart';
import 'type/types.dart';
import 'drift/cards_database.dart' show FlashCard;

class TestSettingView extends ConsumerStatefulWidget {
  final String deckName;
  final int deckId;
  const TestSettingView(
      {super.key, required this.deckName, required this.deckId});
  @override
  TestSettingViewState createState() => TestSettingViewState();
}

class TestSettingViewState extends ConsumerState<TestSettingView> {
  List<FlashCard> _cards = [];
  final double _fixedWidth = 128.0;
  bool _playCorrect = false;
  bool _playPending = true;
  bool _playIncorrect = true;
  bool _playNone = true;
  bool _isShuffle = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadCards());
  }

  Future<void> loadCards() async {
    final cardsDB = ref.watch(cardsDatabaseProvider);
    try {
      List<FlashCard> fetchedCards = await cardsDB.getCards(widget.deckId);
      setState(() => _cards = fetchedCards);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _questionCount(),
          const SizedBox(height: 24),
          _itemAndSwitch(_correctCount(), _correctSwitch()),
          _itemAndSwitch(_pendingCount(), _pendingSwitch()),
          _itemAndSwitch(_incorrectCount(), _incorrectSwitch()),
          _itemAndSwitch(_noneCount(), _noneSwitch()),
          _itemAndSwitch(_shuffleText(), _shuffleSwitch()),
          const SizedBox(height: 32),
          _startButton(),
        ],
      ),
    );
  }

  Widget _itemAndSwitch(Widget item, Widget sw) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [item, const SizedBox(width: 8), sw],
    );
  }

  Widget _questionCount() {
    final count = _cards.length;
    return Text("$count 問", style: const TextStyle(fontSize: 24));
  }

  Widget _correctCount() {
    return _statusCount(
        CardStatus.correct, "OK", Icons.circle_outlined, Colors.green);
  }

  Widget _pendingCount() {
    return _statusCount(
        CardStatus.pending, "あとで", Icons.change_history, Colors.amber);
  }

  Widget _incorrectCount() {
    return _statusCount(CardStatus.incorrect, "NG", Icons.close, Colors.red);
  }

  Widget _noneCount() {
    return _statusCount(CardStatus.none, "まだ", Icons.remove, Colors.grey);
  }

  Widget _statusCount(
      CardStatus status, String text, IconData icon, Color color) {
    final count = _cards.where((card) => card.status == status).length;
    return SizedBox(
      width: _fixedWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: 64,
            child: Text(text, style: TextStyle(color: color)),
          ),
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(count.toString(), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _correctSwitch() {
    return Switch(
      value: _playCorrect,
      onChanged: (value) => setState(() => _playCorrect = value),
    );
  }

  Widget _pendingSwitch() {
    return Switch(
      value: _playPending,
      onChanged: (value) => setState(() => _playPending = value),
    );
  }

  Widget _incorrectSwitch() {
    return Switch(
      value: _playIncorrect,
      onChanged: (value) => setState(() => _playIncorrect = value),
    );
  }

  Widget _noneSwitch() {
    return Switch(
      value: _playNone,
      onChanged: (value) => setState(() => _playNone = value),
    );
  }

  Widget _shuffleSwitch() {
    return Switch(
      value: _isShuffle,
      onChanged: (value) => setState(() => _isShuffle = value),
    );
  }

  Widget _shuffleText() {
    return SizedBox(
      width: _fixedWidth,
      child: const Text('シャッフル'),
    );
  }

  Widget _startButton() {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 400,
      height: 40,
      child: ElevatedButton(
        onPressed: () => _startTest(),
        child: const Text('スタート'),
      ),
    );
  }

  void _startTest() async {
    List<FlashCard> playCards = _selectCards();
    if (playCards.isEmpty) {
      _cantTest();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestPlayView(deckName: widget.deckName, cards: playCards),
      ),
    );
    loadCards();
  }

  List<FlashCard> _selectCards() {
    List<FlashCard> cards = [];
    if (_playCorrect) {
      cards.addAll(_cards.where((card) => card.status == CardStatus.correct));
    }
    if (_playPending) {
      cards.addAll(_cards.where((card) => card.status == CardStatus.pending));
    }
    if (_playIncorrect) {
      cards.addAll(_cards.where((card) => card.status == CardStatus.incorrect));
    }
    if (_playNone) {
      cards.addAll(_cards.where((card) => card.status == CardStatus.none));
    }
    if (_isShuffle) {
      cards.shuffle();
    } else {
      cards.sort((a, b) => a.id.compareTo(b.id));
    }
    return cards;
  }

  void _cantTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('問題がありません！'), duration: Duration(seconds: 1)),
    );
  }
}
