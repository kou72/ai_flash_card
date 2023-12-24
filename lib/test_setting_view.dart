import 'package:flash_pdf_card/drift/cards_database.dart';
import 'package:flash_pdf_card/type/types.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/cards_state.dart';
import 'test_play_view.dart';

class TestSettingView extends ConsumerStatefulWidget {
  final int deckId;
  const TestSettingView({super.key, required this.deckId});
  @override
  TestSettingViewState createState() => TestSettingViewState();
}

class TestSettingViewState extends ConsumerState<TestSettingView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("テスト", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 48),
          _cardStatusSummary(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _correctCount(),
          //     const SizedBox(width: 16),
          //     _pendingCount(),
          //     const SizedBox(width: 16),
          //     _incorrectCount(),
          //   ],
          // ),
          const SizedBox(height: 48),
          _startButton(),
        ],
      ),
    );
  }

  Future _asyncCardStatusSummary() async {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    final correctStatusCount = await cardsDatabase.getCardStatusSummary(
        widget.deckId, CardStatus.correct);
    final pendingStatusCount = await cardsDatabase.getCardStatusSummary(
        widget.deckId, CardStatus.pending);
    final incorrectStatusCount = await cardsDatabase.getCardStatusSummary(
        widget.deckId, CardStatus.incorrect);
    return {
      "correct": correctStatusCount,
      "pending": pendingStatusCount,
      "incorrect": incorrectStatusCount,
    };
  }

  Widget _cardStatusSummary() {
    return FutureBuilder(
      future: _asyncCardStatusSummary(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _correctCount(snapshot.data["correct"]),
              const SizedBox(width: 16),
              _pendingCount(snapshot.data["pending"]),
              const SizedBox(width: 16),
              _incorrectCount(snapshot.data["incorrect"]),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _correctCount(0),
              const SizedBox(width: 16),
              _pendingCount(0),
              const SizedBox(width: 16),
              _incorrectCount(0),
            ],
          );
        }
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
              builder: (context) => TestPlayView(deckId: widget.deckId),
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
