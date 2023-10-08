import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'ai_dialog.dart';
import 'components/gradient_floating_action_button.dart';
import "components/flash_card.dart";
import "riverpod/cards_state.dart";

class CardListView extends ConsumerStatefulWidget {
  const CardListView({super.key});
  @override
  CardListViewState createState() => CardListViewState();
}

class CardListViewState extends ConsumerState<CardListView> {
  late ScrollController _scrollController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // カードと重なるためスクロールが一番下に来たらFABを非表示にする
  void _scrollListener() {
    double positionRate =
        _scrollController.offset / _scrollController.position.maxScrollExtent;
    if (positionRate == 1) {
      setState(() => _showFab = false);
    } else {
      setState(() => _showFab = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsStream = ref.watch(cardsStreamProvider);
    return Scaffold(
      body: Center(
        child: _asyncCardList(cardsStream),
      ),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _asyncCardList(AsyncValue cardsStream) {
    return cardsStream.when(
      data: (cards) => cards.isNotEmpty ? _cardList(cards) : _noCardsText(),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('error: $error'),
    );
  }

  Widget _noCardsText() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.sell,
          color: Colors.grey,
          size: 72.0,
        ),
        SizedBox(height: 16.0),
        Text(
          '最初のカードを作成しましょう！',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 24.0,
          ),
        ),
      ],
    );
  }

  Widget _cardList(List cards) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return FlashCard(
          id: cards[index].id,
          question: cards[index].question,
          answer: cards[index].answer,
        );
      },
    );
  }

  Widget? _floatingActionButton() {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    if (!_showFab) return null;
    return Column(
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
