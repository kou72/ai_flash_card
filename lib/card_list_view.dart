import 'package:flutter/material.dart';
import 'package:flash_pdf_card/ai_dialog.dart';
import 'package:flash_pdf_card/components/gradient_floating_action_button.dart';

class CardListView extends StatefulWidget {
  const CardListView({Key? key}) : super(key: key);
  @override
  CardListViewState createState() => CardListViewState();
}

class CardListViewState extends State<CardListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
}

void _showAiDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AiDialog();
    },
  );
}
