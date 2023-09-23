import 'package:flutter/material.dart';
import 'package:flash_pdf_card/ai_dialog.dart';
import 'package:flash_pdf_card/components/gradient_floating_action_button.dart';

class DeckPage extends StatefulWidget {
  final String deckName;
  const DeckPage({Key? key, required this.deckName}) : super(key: key);
  @override
  DeckPageState createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
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
        return const AiDialog();
      },
    );
  }
}
