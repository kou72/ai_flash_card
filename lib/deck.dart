import 'package:flutter/material.dart';

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

class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String label;
  final List<Color> gradientColors;

  const GradientFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.iconData,
    required this.label,
    this.gradientColors = const [Colors.blue, Colors.purple], // デフォルトのグラデーション色
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 4,
        icon: Icon(iconData),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}
