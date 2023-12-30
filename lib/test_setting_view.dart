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
      // child: _asyncTestPlayMonitor(),
      child: _testSettingContent(),
    );
  }

  Widget _testSettingContent() {
    return Column(
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
    );
  }

  Widget _questionCount() {
    final count = _cards.length;
    return Text("問題数: $count 問", style: const TextStyle(fontSize: 24));
  }

  Widget _startButton() {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 400,
      height: 40,
      child: ElevatedButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestPlayView(
                  deckName: widget.deckName, deckId: widget.deckId),
            ),
          ),
        },
        child: const Text('スタート'),
      ),
    );
  }

  Widget _correctCount() {
    final count =
        _cards.where((card) => card.status == CardStatus.correct).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.circle_outlined,
          color: Colors.green,
        ),
        Text(count.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _pendingCount() {
    final count =
        _cards.where((card) => card.status == CardStatus.pending).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.change_history,
          color: Colors.amber,
        ),
        Text(count.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _incorrectCount() {
    final count =
        _cards.where((card) => card.status == CardStatus.incorrect).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.close,
          color: Colors.red,
        ),
        Text(count.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
