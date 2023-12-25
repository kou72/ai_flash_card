import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "riverpod/cards_state.dart";
import 'test_play_view.dart';
import 'type/types.dart';

class TestSettingView extends ConsumerStatefulWidget {
  final String deckName;
  final int deckId;
  const TestSettingView(
      {super.key, required this.deckName, required this.deckId});
  @override
  TestSettingViewState createState() => TestSettingViewState();
}

class TestSettingViewState extends ConsumerState<TestSettingView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _asyncTestPlayMonitor(),
    );
  }

  Widget _asyncTestPlayMonitor() {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return FutureBuilder(
      future: Future.wait([
        cardsDatabase.getCardStatusSummary(widget.deckId, CardStatus.correct),
        cardsDatabase.getCardStatusSummary(widget.deckId, CardStatus.pending),
        cardsDatabase.getCardStatusSummary(widget.deckId, CardStatus.incorrect),
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        if (!snapshot.hasData) const CircularProgressIndicator();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("テスト", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _correctCount(snapshot.data![0]),
                const SizedBox(width: 16),
                _pendingCount(snapshot.data![1]),
                const SizedBox(width: 16),
                _incorrectCount(snapshot.data![2]),
              ],
            ),
            const SizedBox(height: 48),
            _startButton(),
          ],
        );
      },
    );
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

  Widget _correctCount(int count) {
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

  Widget _pendingCount(int count) {
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

  Widget _incorrectCount(int count) {
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
