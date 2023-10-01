import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flash_pdf_card/ai_dialog.dart';
import 'package:flash_pdf_card/components/gradient_floating_action_button.dart';
import "riverpod/cards_state.dart";

class CardListView extends HookConsumerWidget {
  const CardListView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    final cardsStream = ref.watch(cardsStreamProvider);

    return Scaffold(
      // body: ListView.builder(
      //   itemCount: flashCardData.length,
      //   itemBuilder: (context, index) {
      //     return _flashCard(index);
      //   },
      // ),
      body: Center(
        child: _asyncCardList(cardsStream),
      ),
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
            onPressed: () async {
              await cardsDatabase.insertCard("question", "answer");
            },
          ),
        ],
      ),
    );
  }
}

Widget _asyncCardList(AsyncValue cardsStream) {
  return cardsStream.when(
    data: (cards) => _cardList(cards),
    loading: () => const CircularProgressIndicator(),
    error: (error, stackTrace) => Text('error: $error'),
  );
}

Widget _cardList(List cards) {
  return ListView.builder(
    itemCount: cards.length,
    itemBuilder: (context, index) {
      return ListTile(
        leading: const Icon(Icons.sell),
        title: Text(cards[index].question),
        onTap: () {},
      );
    },
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
