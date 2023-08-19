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
  final String resultText;
  const ResultScreen({Key? key, required this.resultText}) : super(key: key);
  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  final cardWidth = 300.0;
  final cardTextStyle = const TextStyle(color: Colors.blueGrey, fontSize: 16.0);
  final iconTextStyle = const TextStyle(color: Colors.blueGrey, fontSize: 24.0);
  List<FlashCardData> flashCardData = [];

  @override
  void initState() {
    flashCardData = createFlashCardDataList(widget.resultText);
  }

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
      text: TextSpan(text: flashCardData[index].question, style: cardTextStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: cardWidth, maxWidth: cardWidth);

    final answerTextPainter = TextPainter(
      text: TextSpan(text: flashCardData[index].answer, style: cardTextStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: cardWidth, maxWidth: cardWidth);

    final maxHeight = max(
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
                  minHeight: maxHeight,
                  maxHeight: maxHeight,
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
          style: iconTextStyle,
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            flashCardData[index].question,
            style: cardTextStyle,
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
          style: iconTextStyle,
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            flashCardData[index].answer,
            style: cardTextStyle,
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
