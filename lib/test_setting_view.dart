import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "riverpod/cards_state.dart";
import 'test_play_view.dart';
import 'type/types.dart';

class TestSettingView extends ConsumerStatefulWidget {
  final String deckName;
  final int deckId;
  const TestSettingView(
      {super.key, required this.deckName, required this.deckId});
  @override
  TestSettingViewState createState() => TestSettingViewState();
}

class TestSettingViewState extends ConsumerState<TestSettingView> {
  List<FlashCard> _cards = [];
  List<FlashCard> _playCards = [];
  bool _playCorrect = false;
  bool _playPending = true;
  bool _playIncorrect = true;
  bool _playNone = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadCards());
  }

  Future<void> loadCards() async {
    final cardsDB = ref.watch(cardsDatabaseProvider);
    try {
      List<FlashCard> fetchedCards = await cardsDB.getCards(widget.deckId);
      setState(() => _cards = fetchedCards);
      _selectPlayCards();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _playCardsCount(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _noneButton(),
              _incorrectButton(),
              _pendingButton(),
              _correctButton(),
            ],
          ),
          const SizedBox(height: 32),
          _startButton(),
        ],
      ),
    );
  }

  Widget _playCardsCount() {
    final count = _playCards.length;
    return Text("$count 問", style: const TextStyle(fontSize: 24));
  }

  Widget _noneButton() {
    return _selectButton(
      status: CardStatus.none,
      icon: Icons.remove,
      color: Colors.grey,
      isPlay: _playNone,
      onPressed: () => setState(() => _playNone = !_playNone),
    );
  }

  Widget _incorrectButton() {
    return _selectButton(
      status: CardStatus.incorrect,
      icon: Icons.close,
      color: Colors.red,
      isPlay: _playIncorrect,
      onPressed: () => setState(() => _playIncorrect = !_playIncorrect),
    );
  }

  Widget _pendingButton() {
    return _selectButton(
      status: CardStatus.pending,
      icon: Icons.change_history,
      color: Colors.amber,
      isPlay: _playPending,
      onPressed: () => setState(() => _playPending = !_playPending),
    );
  }

  Widget _correctButton() {
    return _selectButton(
      status: CardStatus.correct,
      icon: Icons.circle_outlined,
      color: Colors.green,
      isPlay: _playCorrect,
      onPressed: () => setState(() => _playCorrect = !_playCorrect),
    );
  }

  Widget _selectButton({
    required CardStatus status,
    required IconData icon,
    required Color color,
    required bool isPlay,
    required Function onPressed,
  }) {
    final count = _cards.where((card) => card.status == status).length;
    TextStyle? textStyle = isPlay ? const TextStyle(color: Colors.black) : null;
    ButtonStyle? buttonStyle = isPlay
        ? ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            foregroundColor: MaterialStateProperty.all(color),
            side: MaterialStateProperty.all(BorderSide(color: color, width: 2)),
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(left: 2, right: 2),
      width: 80,
      height: 80,
      child: OutlinedButton(
        onPressed: () => {
          onPressed(),
          _selectPlayCards(),
        },
        style: buttonStyle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text("$count 問", style: textStyle),
          ],
        ),
      ),
    );
  }

  Widget _startButton() {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 400,
      height: 40,
      child: ElevatedButton(
        onPressed: () => _startTest(),
        child: const Text('スタート'),
      ),
    );
  }

  void _startTest() async {
    if (_playCards.isEmpty) {
      _cantTest();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestPlayView(deckName: widget.deckName, cards: _playCards),
      ),
    );
    loadCards();
  }

  void _selectPlayCards() {
    List<FlashCard> cards = [];
    if (_playCorrect) cards.addAll(_pickCards(CardStatus.correct));
    if (_playPending) cards.addAll(_pickCards(CardStatus.pending));
    if (_playIncorrect) cards.addAll(_pickCards(CardStatus.incorrect));
    if (_playNone) cards.addAll(_pickCards(CardStatus.none));
    cards.shuffle();

    _playCards.clear();
    _playCards = cards;
  }

  List<FlashCard> _pickCards(CardStatus status) {
    return _cards.where((card) => card.status == status).toList();
  }

  void _cantTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('問題がありません！'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
