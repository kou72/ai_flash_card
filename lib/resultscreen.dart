import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';

List<FlashCardData> createFlashCardDataList(String jsonText) {
  final parsed = json.decode(jsonText) as List;
  final flashCardData = parsed
      .map((item) => FlashCardData(
          question: item['question'], answer: item['answer'], isFlipped: true))
      .toList();
  return flashCardData;
}

class ResultScreen extends StatefulWidget {
  final String questionsData;
  const ResultScreen({super.key, required this.questionsData});
  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  final cardWidth = 300.0;
  final cardFontSize = 16.0;
  final cardIconSize = 24.0;
  final questionColor = Colors.blueGrey;
  final answerColor = Colors.blueAccent;
  List<FlashCardData> flashCardData = [];

  @override
  void initState() {
    super.initState();
    flashCardData = createFlashCardDataList(widget.questionsData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗記カード'),
      ),
      body: ListView.builder(
        itemCount: flashCardData.length,
        itemBuilder: (context, index) {
          return _flashCard(index);
        },
      ),
    );
  }

  Widget _flashCard(int index) {
    // question と answer のテキストの高さを計算
    final questionTextPainter = TextPainter(
      text: TextSpan(
        text: flashCardData[index].question,
        style: TextStyle(fontSize: cardFontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: cardWidth - 100, maxWidth: cardWidth - 100);

    final answerTextPainter = TextPainter(
      text: TextSpan(
        text: flashCardData[index].answer,
        style: TextStyle(fontSize: cardFontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: cardWidth - 100, maxWidth: cardWidth - 100);

    final cardHeight = max(
      questionTextPainter.height,
      answerTextPainter.height,
    );

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          margin: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              setState(() {
                flashCardData[index].isFlipped =
                    !flashCardData[index].isFlipped;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: cardHeight,
                  maxHeight: cardHeight,
                ),
                child: _flashCardText(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCardText(int index) {
    if (flashCardData[index].isFlipped) {
      return _questionText(index);
    } else {
      return _answerText(index);
    }
  }

  Widget _questionText(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q',
          style: TextStyle(color: questionColor, fontSize: cardIconSize),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            flashCardData[index].question,
            style: TextStyle(color: questionColor, fontSize: cardFontSize),
          ),
        ),
      ],
    );
  }

  Widget _answerText(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A',
          style: TextStyle(color: answerColor, fontSize: cardIconSize),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            flashCardData[index].answer,
            style: TextStyle(color: answerColor, fontSize: cardFontSize),
          ),
        ),
      ],
    );
  }
}

class FlashCardData {
  final String question;
  final String answer;
  bool isFlipped;

  FlashCardData({
    required this.question,
    required this.answer,
    this.isFlipped = true,
  });
}
