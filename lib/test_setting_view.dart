import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _correctCount(),
              const SizedBox(width: 16),
              _almostCount(),
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
}

Widget _correctCount() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.check,
        color: Colors.green,
      ),
      Text("10", style: TextStyle(fontSize: 16)),
    ],
  );
}

Widget _almostCount() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.change_history,
        color: Colors.amber,
      ),
      Text("10", style: TextStyle(fontSize: 16)),
    ],
  );
}

Widget _incorrectCount() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.close,
        color: Colors.red,
      ),
      Text("10", style: TextStyle(fontSize: 16)),
    ],
  );
}
