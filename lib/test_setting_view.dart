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
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _correctCount(),
              const SizedBox(width: 16),
              _pendingCount(),
              const SizedBox(width: 16),
              _incorrectCount(),
            ],
          ),
          const SizedBox(height: 48),
          _startButton(),
        ],
      ),
    );
  }

  Widget _questionCount() {
    final count = _cards.length;
    return Text("問題数: $count 問", style: const TextStyle(fontSize: 24));
  }

  Widget _correctCount() {
    return _statusCountWidget(
        CardStatus.correct, Icons.circle_outlined, Colors.green);
  }

  Widget _pendingCount() {
    return _statusCountWidget(
        CardStatus.pending, Icons.change_history, Colors.amber);
  }

  Widget _incorrectCount() {
    return _statusCountWidget(CardStatus.incorrect, Icons.close, Colors.red);
  }

  Widget _statusCountWidget(CardStatus status, IconData icon, Color color) {
    final count = _cards.where((card) => card.status == status).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Text(count.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _startButton() {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 400,
      height: 40,
      child: ElevatedButton(
        onPressed: _cards.isEmpty ? () => _cantTest() : () => _startTest(),
        child: const Text('スタート'),
      ),
    );
  }

  void _startTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestPlayView(deckName: widget.deckName, cards: _cards),
      ),
    );
  }

  void _cantTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('問題がありません！')),
    );
  }
}
