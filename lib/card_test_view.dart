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
  final _cardIconSize = 20.0;
  final _questionColor = Colors.blueGrey;
  final _answerColor = Colors.blueAccent;
  bool _isFlipped = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _cardWidth,
        child: Card(
          margin: const EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: 12,
            right: 12,
          ),
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
                child: _flashCardObject(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCardObject() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _flashCardText()),
      ],
    );
  }

  Widget _flashCardIcon() {
    if (_isFlipped) {
      return Icon(
        Icons.sell,
        color: _questionColor,
        size: _cardIconSize,
      );
    } else {
      return Icon(
        Icons.sell_outlined,
        color: _answerColor,
        size: _cardIconSize,
      );
    }
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
