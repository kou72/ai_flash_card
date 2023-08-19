import 'dart:math';

import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);
  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  final cardWidth = 300.0;
  final cardTextStyle = const TextStyle(color: Colors.blueGrey, fontSize: 16.0);
  final iconTextStyle = const TextStyle(color: Colors.blueGrey, fontSize: 24.0);

  final sampleData = [
    FlashCardData(
        question: '質問1長い文字列でカード幅からはみ出るかどうかを検証しようと思うので、長い文章を書いています。',
        answer: '答え1',
        isFlipped: true),
    FlashCardData(question: '質問2', answer: '答え2', isFlipped: true),
    FlashCardData(question: '質問3', answer: '答え3', isFlipped: true),
    FlashCardData(
        question: '質問1長い文字列でカード幅からはみ出るかどうかを検証しようと思うので、長い文章を書いています。',
        answer: '答え1',
        isFlipped: true),
    FlashCardData(question: '質問2', answer: '答え2', isFlipped: true),
    FlashCardData(question: '質問3', answer: '答え3', isFlipped: true),
    FlashCardData(
        question: '質問1長い文字列でカード幅からはみ出るかどうかを検証しようと思うので、長い文章を書いています。',
        answer: '答え1',
        isFlipped: true),
    FlashCardData(question: '質問2', answer: '答え2', isFlipped: true),
    FlashCardData(question: '質問3', answer: '答え3', isFlipped: true),
    FlashCardData(
        question: '質問1長い文字列でカード幅からはみ出るかどうかを検証しようと思うので、長い文章を書いています。',
        answer: '答え1',
        isFlipped: true),
    FlashCardData(question: '質問2', answer: '答え2', isFlipped: true),
    FlashCardData(question: '質問3', answer: '答え3', isFlipped: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗記カード'),
      ),
      body: ListView.builder(
        itemCount: sampleData.length,
        itemBuilder: (context, index) {
          return _flashCard(index);
        },
      ),
    );
  }

  Widget _flashCard(int index) {
    // question と answer のテキストの高さを計算
    final questionTextPainter = TextPainter(
      text: TextSpan(text: sampleData[index].question, style: cardTextStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: cardWidth, maxWidth: cardWidth);

    final answerTextPainter = TextPainter(
      text: TextSpan(text: sampleData[index].answer, style: cardTextStyle),
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
                sampleData[index].isFlipped = !sampleData[index].isFlipped;
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
    if (sampleData[index].isFlipped) {
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
            sampleData[index].question,
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
            sampleData[index].answer,
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
