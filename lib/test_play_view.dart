import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod/decks_state.dart';

class TestPlayView extends ConsumerStatefulWidget {
  final int deckId;
  const TestPlayView({super.key, required this.deckId});
  @override
  TestPlayViewState createState() => TestPlayViewState();
}

class TestPlayViewState extends ConsumerState<TestPlayView> {
  final _cardWidth = 400.0;
  final _cardHeight = 200.0;
  final _cardFontSize = 16.0;
  final _questionColor = Colors.blueGrey;
  final _answerColor = Colors.blueAccent;
  bool _isFlipped = true;
  bool _onNote = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _asyncDeckName(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _flashCard(),
            const SizedBox(height: 8),
            _noteButton(),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _correctButton(),
                _almostButton(),
                _incorrectButton(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _asyncDeckName() {
    final decksDatabase = ref.watch(decksDatabaseProvider);
    return FutureBuilder(
      future: decksDatabase.getDeckName(widget.deckId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data);
        } else {
          return const Text("");
        }
      },
    );
  }

  Widget _noteButton() {
    var buttonStyle = _onNote
        ? ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[700]),
            foregroundColor: MaterialStateProperty.all(Colors.grey),
          )
        : null;

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 400,
      height: 40,
      child: ElevatedButton(
        onPressed: () => setState(() => _onNote = !_onNote),
        style: buttonStyle,
        child: const Text('ノート'),
      ),
    );
  }

  Widget _correctButton() {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: () => {},
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.green),
        ),
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _almostButton() {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: () => {},
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.amber),
        ),
        child: const Icon(Icons.change_history),
      ),
    );
  }

  Widget _incorrectButton() {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: () => {},
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.red),
        ),
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget _flashCard() {
    return SizedBox(
      width: _cardWidth,
      child: Card(
        child: InkWell(
          onTap: () {
            setState(() => _isFlipped = !_isFlipped);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _cardHeight,
                maxHeight: _cardHeight,
              ),
              child: _flashCardText(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCardText() {
    if (_isFlipped) {
      return Text(
        "widget.question",
        style: TextStyle(color: _questionColor, fontSize: _cardFontSize),
      );
    } else {
      return Text(
        "widget.answer",
        style: TextStyle(color: _answerColor, fontSize: _cardFontSize),
      );
    }
  }
}
