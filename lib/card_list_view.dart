import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'
    show ConsumerState, ConsumerStatefulWidget, AsyncValue, AsyncValueX;

// import file
import 'riverpod/database_provider.dart' show cardsStreamProvider;
import 'components/gradient_floating_action_button.dart'
    show GradientFloatingActionButton;
import 'components/flash_card_item.dart' show FlashCardItem;
import 'card_dialog/ai_dialog.dart' show AiDialog;
import "card_detail_view.dart" show CardDetailView;

class CardListView extends ConsumerStatefulWidget {
  final int deckId;
  const CardListView({super.key, required this.deckId});
  @override
  CardListViewState createState() => CardListViewState();
}

class CardListViewState extends ConsumerState<CardListView> {
  bool _cardsIsEmpty = true;

  @override
  Widget build(BuildContext context) {
    final cardsStream = ref.watch(cardsStreamProvider(widget.deckId));
    return Scaffold(
      body: Center(
        child: _asyncCardList(cardsStream),
      ),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _asyncCardList(AsyncValue cardsStream) {
    return cardsStream.when(
      data: (cards) {
        setState(() => _cardsIsEmpty = !cards.isNotEmpty);
        return cards.isNotEmpty ? _cardList(cards) : _noCardsText();
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('error: $error'),
    );
  }

  Widget _noCardsText() {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 18.0,
    );
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sell, color: Colors.grey, size: 64.0),
        SizedBox(height: 16.0),
        Text('画像からカードを生成してみましょう！', style: textStyle),
        Text('文字を抽出して暗記カードに変換します', style: textStyle),
      ],
    );
  }

  Widget _cardList(List cards) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return FlashCardItem(
            id: cards[index].id,
            deckId: cards[index].deckId,
            question: cards[index].question,
            answer: cards[index].answer,
            note: cards[index].note,
          );
        },
      ),
    );
  }

  Widget _floatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _aiCardButton(),
        const SizedBox(height: 16),
        _createCardButton(),
      ],
    );
  }

  Widget _aiCardButton() {
    return GradientFloatingActionButton(
      onPressed: () => _showAiDialog(),
      iconData: Icons.smart_toy,
      label: _cardsIsEmpty ? '画像からカード生成' : null,
      gradientColors: const [Colors.blue, Colors.purple],
    );
  }

  Widget _createCardButton() {
    if (_cardsIsEmpty) {
      return FloatingActionButton.extended(
        heroTag: 'createCard',
        icon: const Icon(Icons.edit),
        label: const Text('自分でカードを作成'),
        onPressed: _createEmptyCard,
      );
    } else {
      return FloatingActionButton(
        heroTag: 'createCard',
        child: const Icon(Icons.edit),
        onPressed: () => _createEmptyCard(),
      );
    }
  }

  void _createEmptyCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailView(
          isnew: true,
          id: 0,
          deckId: widget.deckId,
          question: "",
          answer: "",
          note: "",
        ),
      ),
    );
  }

  void _showAiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AiDialog(deckId: widget.deckId);
      },
    );
  }
}
