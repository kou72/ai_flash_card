import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'card_dialog/ai_dialog.dart';
import 'components/gradient_floating_action_button.dart';
import "components/flash_card.dart";
import "riverpod/cards_state.dart";
import "card_detail_view.dart";

class CardListView extends ConsumerStatefulWidget {
  final int deckId;
  const CardListView({super.key, required this.deckId});
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
      data: (cards) => cards.isNotEmpty ? _cardList(cards) : _noCardsText(),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('error: $error'),
    );
  }

  Widget _noCardsText() {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 24.0,
    );
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sell, color: Colors.grey, size: 72.0),
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
        controller: _scrollController,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return FlashCard(
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

  Widget? _floatingActionButton() {
    if (!_showFab) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GradientFloatingActionButton(
          onPressed: () => _showAiDialog(),
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
          },
        ),
      ],
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
