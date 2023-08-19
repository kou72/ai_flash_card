import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);
  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  final sampleData = [
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
    return GestureDetector(
      onTap: () {
        setState(() {
          sampleData[index].isFlipped = !sampleData[index].isFlipped;
        });
      },
      child: Center(
        child: SizedBox(
          width: 300.0,
          child: Card(
            margin: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: _flashCardText(index),
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
      children: [
        const Text(
          'Q',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 24.0,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            sampleData[index].question,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _answerText(int index) {
    return Row(
      children: [
        const Text(
          'A',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 24.0,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            sampleData[index].answer,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
            ),
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
