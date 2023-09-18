import 'package:flutter/material.dart';
import 'package:flash_pdf_card/components/gradient_floating_action_button.dart';
import 'package:flash_pdf_card/components/gradient_container.dart';

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
              const GradientContainer(
                text: "PDF",
                iconData: Icons.upload_file,
                width: 200,
                height: 100,
                colors: [Colors.blue, Colors.purple], // オプション: 新しいグラデーション色を指定
              ),
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
