import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'test_play_view.dart';

class TestSettingView extends ConsumerStatefulWidget {
  final String deckName;
  final dynamic cards;
  const TestSettingView(
      {super.key, required this.deckName, required this.cards});
  @override
  TestSettingViewState createState() => TestSettingViewState();
}

class TestSettingViewState extends ConsumerState<TestSettingView> {
  @override
  Widget build(BuildContext context) {
    widget.cards[0].id;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("テスト", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _correctCount(10),
              const SizedBox(width: 16),
              _pendingCount(10),
              const SizedBox(width: 16),
              _incorrectCount(10),
            ],
          ),
          const SizedBox(height: 48),
          _startButton(),
        ],
      ),
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
              builder: (context) =>
                  TestPlayView(deckName: widget.deckName, cards: widget.cards),
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
