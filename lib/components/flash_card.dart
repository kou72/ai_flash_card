import 'dart:math';
import 'package:flutter/material.dart';

class FlashCard extends StatefulWidget {
  final String question;
  final String answer;
  const FlashCard({
    super.key,
    required this.question,
    required this.answer,
  });
  @override
  FlashCardState createState() => FlashCardState();
}

class FlashCardState extends State<FlashCard> {
  final cardWidth = 300.0;
  final cardFontSize = 16.0;
  final cardIconSize = 24.0;
  final questionColor = Colors.blueGrey;
  final answerColor = Colors.blueAccent;
  bool _isFlipped = true;

  // question と answer のテキストの高さを計算
  late TextPainter questionTextPainter = TextPainter(
    text: TextSpan(
      text: widget.question,
      style: TextStyle(fontSize: cardFontSize),
    ),
    textDirection: TextDirection.ltr,
  )..layout(minWidth: cardWidth - 100, maxWidth: cardWidth - 100);

  late TextPainter answerTextPainter = TextPainter(
    text: TextSpan(
      text: widget.answer,
      style: TextStyle(fontSize: cardFontSize),
    ),
    textDirection: TextDirection.ltr,
  )..layout(minWidth: cardWidth - 100, maxWidth: cardWidth - 100);

  late double cardHeight = max(
    questionTextPainter.height,
    answerTextPainter.height,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              setState(() => _isFlipped = !_isFlipped);
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: cardHeight,
                  maxHeight: cardHeight,
                ),
                child: _flashCardText(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCardText() {
    if (_isFlipped) {
      return _questionText();
    } else {
      return _answerText();
    }
  }

  Widget _questionText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.sell, color: questionColor),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            widget.question,
            style: TextStyle(color: questionColor, fontSize: cardFontSize),
          ),
        ),
      ],
    );
  }

  Widget _answerText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.sell_outlined, color: answerColor),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            widget.answer,
            style: TextStyle(color: answerColor, fontSize: cardFontSize),
          ),
        ),
      ],
    );
  }
}
