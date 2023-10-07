import 'dart:math';
import 'package:flutter/material.dart';
import '../card_detail_view.dart';

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
  final _cardWidth = 400.0;
  final _cardFontSize = 16.0;
  final _cardIconSize = 20.0;
  final _questionColor = Colors.blueGrey;
  final _answerColor = Colors.blueAccent;
  bool _isFlipped = true;

  // question と answer のテキストの高さを計算
  late TextPainter questionTextPainter = TextPainter(
    text: TextSpan(
      text: widget.question,
      style: TextStyle(fontSize: _cardFontSize),
    ),
    textDirection: TextDirection.ltr,
  )..layout(minWidth: _cardWidth - 100, maxWidth: _cardWidth - 100);

  late TextPainter answerTextPainter = TextPainter(
    text: TextSpan(
      text: widget.answer,
      style: TextStyle(fontSize: _cardFontSize),
    ),
    textDirection: TextDirection.ltr,
  )..layout(minWidth: _cardWidth - 100, maxWidth: _cardWidth - 100);

  late double cardHeight = max(
    questionTextPainter.height,
    answerTextPainter.height,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _cardWidth,
        child: Card(
          margin: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              setState(() => _isFlipped = !_isFlipped);
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: cardHeight,
                  maxHeight: cardHeight,
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
        _flashCardIcon(),
        const SizedBox(width: 10.0),
        Expanded(child: _flashCardText()),
        const SizedBox(width: 10.0),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          color: _questionColor,
          icon: Icon(Icons.edit, size: _cardIconSize),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailView(
                  question: widget.question,
                  answer: widget.answer,
                ),
              ),
            );
          },
        ),
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
        widget.question,
        style: TextStyle(color: _questionColor, fontSize: _cardFontSize),
      );
    } else {
      return Text(
        widget.answer,
        style: TextStyle(color: _answerColor, fontSize: _cardFontSize),
      );
    }
  }
}
