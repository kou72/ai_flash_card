import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash PDF Card',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);
  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  String? _pickedFileName = '';

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _pickedFileName = file.name;
      });
      // ここでファイルをアップロードするロジックを実装する
    } else {
      // ユーザーがファイル選択をキャンセルした場合の処理
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash PDF Card'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'PDFの内容を読み取り暗記カードを作成します',
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _pickPDF,
              child: const Text('PDFをアップロード'),
            ),
            const SizedBox(height: 20.0),
            Text('選択されたファイル: $_pickedFileName'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => {},
              child: const Text('暗記カードを作成'),
            ),
          ],
        ),
      ),
    );
  }
}


// class UploadAndProcessScreen extends StatefulWidget {
//   const UploadAndProcessScreen({Key? key}) : super(key: key);
//   @override
//   UploadAndProcessScreenState createState() => UploadAndProcessScreenState();
// }

// class UploadAndProcessScreenState extends State<UploadAndProcessScreen> {
//   bool _isUploading = false;
//   double _progressValue = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('アップロード&処理'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 // PDFアップロードのロジックをここに実装
//                 // 例: uploadPDF();
//               },
//               child: const Text('PDFをアップロード'),
//             ),
//             const SizedBox(height: 20),
//             if (_isUploading) ...[
//               const Text('処理中...'),
//               const SizedBox(height: 10),
//               LinearProgressIndicator(value: _progressValue),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // この関数はPDFのアップロードとテキスト抽出のロジックを示すダミーです。
//   // 実際のロジックを実装する際には、適切な方法で更新する必要があります。
//   Future<void> uploadPDF() async {
//     setState(() {
//       _isUploading = true;
//       _progressValue = 0.1;
//     });

//     // PDFのアップロードとテキスト抽出のロジックをここに実装

//     // ダミーの暗記カードリスト
//     List<Flashcard> flashcards = [
//       Flashcard(question: "質問1", answer: "答え1"),
//       Flashcard(question: "質問2", answer: "答え2"),
//       // ... 他の暗記カード
//     ];

//     setState(() {
//       _progressValue = 1.0;
//       _isUploading = false;
//     });
//     // ResultScreenへの遷移
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ResultScreen(flashcards: flashcards),
//       ),
//     );
//   }
// }

// class ResultScreen extends StatefulWidget {
//   final List<Flashcard> flashcards;

//   const ResultScreen({super.key, required this.flashcards});

//   @override
//   ResultScreenState createState() => ResultScreenState();
// }

// class ResultScreenState extends State<ResultScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('暗記カードの結果'),
//       ),
//       body: ListView.builder(
//         itemCount: widget.flashcards.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(widget.flashcards[index].question),
//             onTap: () {
//               // タップしたときの詳細表示ロジック
//               _showDetail(widget.flashcards[index]);
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _showDetail(Flashcard flashcard) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(flashcard.question),
//           content: Text(flashcard.answer),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('閉じる'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class Flashcard {
//   final String question;
//   final String answer;

//   Flashcard({required this.question, required this.answer});
// }
