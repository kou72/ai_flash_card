import 'package:flash_pdf_card/riverpod/cards_state.dart';
import 'package:flash_pdf_card/type/types.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'drift/cards_database.dart' show FlashCard;

class TestPlayView extends ConsumerStatefulWidget {
  final String deckName;
  final int deckId;
  const TestPlayView({super.key, required this.deckName, required this.deckId});
  @override
  TestPlayViewState createState() => TestPlayViewState();
}

class TestPlayViewState extends ConsumerState<TestPlayView> {
  final _cardWidth = 400.0;
  final _cardHeight = 200.0;
  final _cardFontSize = 16.0;
  final _buttonWidth = 100.0;
  final _buttonHeight = 40.0;
  final _questionColor = Colors.blueGrey;
  final _answerColor = Colors.blueAccent;
  bool _isFlipped = true;
  bool _onNote = false;

  List<FlashCard> _cards = [];
  bool _isLoading = true;
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadCards());
  }

  Future<void> loadCards() async {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    try {
      List<FlashCard> fetchedCards =
          await cardsDatabase.getCards(widget.deckId);
      setState(() {
        _cards = fetchedCards;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(child: _testPlayContent()),
    );
  }

  Widget _testPlayContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _flashCard(_cards[_currentCardIndex]),
        const SizedBox(height: 8),
        _noteButton(),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _correctButton(_cards[_currentCardIndex]),
            _pendingButton(_cards[_currentCardIndex]),
            _incorrectButton(_cards[_currentCardIndex]),
          ],
        )
      ],
    );
  }

  Widget _noteButton() {
    var buttonStyle = _onNote
        ? ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[700]),
            foregroundColor: MaterialStateProperty.all(Colors.grey),
          )
        : null;

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: _cardWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => setState(() => _onNote = !_onNote),
        style: buttonStyle,
        child: const Text('ノート'),
      ),
    );
  }

  Widget _correctButton(dynamic card) {
    return _statusButton(
        card: card,
        status: CardStatus.correct,
        color: Colors.green,
        icon: Icons.check);
  }

  Widget _pendingButton(dynamic card) {
    return _statusButton(
        card: card,
        status: CardStatus.pending,
        color: Colors.amber,
        icon: Icons.change_history);
  }

  Widget _incorrectButton(dynamic card) {
    return _statusButton(
        card: card,
        status: CardStatus.incorrect,
        color: Colors.red,
        icon: Icons.close);
  }

  Widget _statusButton(
      {required dynamic card,
      required CardStatus status,
      required Color color,
      required IconData icon}) {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);

    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => {
          cardsDatabase.updateCardStatus(card.id, status),
          nextCard(),
          print(card)
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(color),
        ),
        child: Icon(icon),
      ),
    );
  }

  void nextCard() {
    if (_currentCardIndex < _cards.length - 1) {
      setState(() => _currentCardIndex++);
    } else {
      // テスト終了処理（任意）
    }
  }

  Widget _flashCard(card) {
    return SizedBox(
      width: _cardWidth,
      child: Card(
        child: InkWell(
          onTap: () {
            setState(() => _isFlipped = !_isFlipped);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _cardHeight,
                maxHeight: _cardHeight,
              ),
              child: _flashCardText(card),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCardText(card) {
    if (_isFlipped) {
      return Text(
        card.question,
        style: TextStyle(color: _questionColor, fontSize: _cardFontSize),
      );
    } else {
      return Text(
        card.answer,
        style: TextStyle(color: _answerColor, fontSize: _cardFontSize),
      );
    }
  }
}
