import 'package:flash_pdf_card/riverpod/cards_state.dart';
import 'package:flash_pdf_card/type/types.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      body: Center(
        child: _asyncTestPlayMonitor(),
      ),
    );
  }

  Widget _asyncTestPlayMonitor() {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return FutureBuilder(
      future: cardsDatabase.getCards(widget.deckId),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) const CircularProgressIndicator();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _flashCard(snapshot.data![0]),
            const SizedBox(height: 8),
            _noteButton(),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _correctButton(snapshot.data![0]),
                _pendingButton(snapshot.data![0]),
                _incorrectButton(snapshot.data![0]),
              ],
            )
          ],
        );
      },
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

  Widget _correctButton(card) {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => {
          cardsDatabase.updateCardStatus(
            card.id,
            CardStatus.correct,
          ),
          print(card)
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.green),
        ),
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _pendingButton(card) {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => {
          cardsDatabase.updateCardStatus(
            card.id,
            CardStatus.pending,
          ),
          print(card)
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.amber),
        ),
        child: const Icon(Icons.change_history),
      ),
    );
  }

  Widget _incorrectButton(card) {
    final cardsDatabase = ref.watch(cardsDatabaseProvider);
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => {
          cardsDatabase.updateCardStatus(
            card.id,
            CardStatus.incorrect,
          ),
          print(card)
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.red),
        ),
        child: const Icon(Icons.close),
      ),
    );
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
