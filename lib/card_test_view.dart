import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CardTestView extends ConsumerStatefulWidget {
  @override
  CardTestViewState createState() => CardTestViewState();
}

class CardTestViewState extends ConsumerState<CardTestView> {
  final _cardWidth = 400.0;
  final _cardHeight = 200.0;
  final _cardFontSize = 16.0;
  final _questionColor = Colors.blueGrey;
  final _answerColor = Colors.blueAccent;
  bool _isFlipped = true;
  bool _onNote = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _flashCard(),
          const SizedBox(height: 8),
          _noteButton(),
          const SizedBox(height: 24),
        ],
      ),
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
      padding: const EdgeInsets.only(left: 2, right: 2),
      width: 300,
      height: 40,
      child: ElevatedButton(
        onPressed: () => setState(() => _onNote = !_onNote),
        style: buttonStyle,
        child: const Text('ノート'),
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
              child: Expanded(child: _flashCardText()),
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
