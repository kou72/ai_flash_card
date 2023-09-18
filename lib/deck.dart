import 'package:flutter/material.dart';
import 'package:flash_pdf_card/components/gradient_floating_action_button.dart';

class Deck extends StatefulWidget {
  final String deckName;
  const Deck({Key? key, required this.deckName}) : super(key: key);
  @override
  DeckState createState() => DeckState();
}

class DeckState extends State<Deck> {
  // @override
  // void initState() {
  //   super.initState();
  //   flashCardData = createFlashCardDataList(widget.questionsData);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      // body: ListView.builder(
      //   itemCount: flashCardData.length,
      //   itemBuilder: (context, index) {
      //     return _flashCard(index);
      //   },
      // ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientFloatingActionButton(
            onPressed: () {
              _showAiDialog(context);
            },
            iconData: Icons.smart_toy,
            label: '画像からカード生成',
            gradientColors: const [Colors.blue, Colors.purple],
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'createCard',
            icon: const Icon(Icons.edit),
            label: const Text('自分でカードを作成'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showAiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('画像からカード生成します'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _gradationContainer(),
              ListTile(
                title: Text('画像を選択'),
                onTap: () {
                  // ここにボタンを押したときの処理を追加
                },
              ),
              ListTile(
                title: Text('カードを生成'),
                onTap: () {
                  // ここにボタンを押したときの処理を追加
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
          ],
        );
      },
    );
  }
}

Widget _gradationContainer() {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24.0),
    ),
    width: 204,
    height: 104,
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.0),
        color: Colors.white,
      ),
      width: 200,
      height: 100,
      child: _pdfPickContainer(),
    ),
  );
}

Widget _pdfPickContainer() {
  return Container(
    // decoration: BoxDecoration(
    //   border: Border.all(
    //     color: Colors.blueGrey,
    //     width: 2.0,
    //   ),
    //   borderRadius: BorderRadius.circular(24.0),
    // ),
    width: 200,
    height: 100,
    child: _pdfPickedIcon(),
  );
}

Widget _pdfPickedIcon() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      const Icon(
        Icons.check_circle,
        color: Colors.blueGrey,
        size: 64.0,
      ),
      const SizedBox(height: 8.0),
      Text(
        "PDF",
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 16.0,
        ),
      ),
    ],
  );
}
