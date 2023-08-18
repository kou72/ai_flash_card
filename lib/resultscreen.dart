import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);
  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  final cardsData = [
    FlashCard(question: '質問1', answer: '答え1', isFlipped: true),
    FlashCard(question: '質問2', answer: '答え2', isFlipped: true),
    FlashCard(question: '質問3', answer: '答え3', isFlipped: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗記カード'),
      ),
      body: ListView.builder(
        itemCount: cardsData.length,
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
          cardsData[index].isFlipped = !cardsData[index].isFlipped;
        });
      },
      child: Card(
        child: Center(
          child: cardsData[index].isFlipped
              ? Text(cardsData[index].question)
              : Text(cardsData[index].answer),
        ),
      ),
    );
  }
}

class FlashCard {
  final String question;
  final String answer;
  bool isFlipped;

  FlashCard(
      {required this.question, required this.answer, this.isFlipped = true});
}

// class ResultScreen extends StatelessWidget {
//   final String resultText;
//   const ResultScreen({Key? key, required this.resultText}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('暗記カードの結果'),
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             title: Text('質問: ${resultText}'), // 例として、ここでresultTextを表示しています
//             // subtitle: Text('答え: ${resultText}'),
//           ),
//         ],
//       ),
//     );
//   }
// }
