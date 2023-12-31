import 'package:flash_pdf_card/riverpod/cards_state.dart';
import 'package:flash_pdf_card/type/types.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'drift/cards_database.dart' show FlashCard;

class TestPlayView extends ConsumerStatefulWidget {
  final String deckName;
  final List<FlashCard> cards;
  const TestPlayView({super.key, required this.deckName, required this.cards});
  @override
  TestPlayViewState createState() => TestPlayViewState();
}

class UpdateStatus {
  late int id;
  late CardStatus status;
  UpdateStatus({required this.id, required this.status});
}

class TestPlayViewState extends ConsumerState<TestPlayView> {
  final _cardWidth = 400.0;
  final _cardHeight = 200.0;
  final _buttonWidth = 100.0;
  final _buttonHeight = 40.0;
  bool _isFlipped = true;
  bool _showNote = false;
  List<FlashCard> _cards = [];
  // ignore: prefer_final_fields
  List<UpdateStatus> _updateList = []; // 更新対象のステータスをaddしていく
  int _index = 0;

  @override
  void initState() {
    super.initState();
    setState(() => _cards = widget.cards);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
      ),
      body: Center(child: _testPlayContent()),
    );
  }

  Widget _testPlayContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _flashCard(),
        const SizedBox(height: 8),
        _noteButton(),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _incorrectButton(),
            _pendingButton(),
            _correctButton(),
          ],
        )
      ],
    );
  }

  Widget _flashCard() {
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
              child: _flashCardText(_cards[_index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCardText(card) {
    const cardFontSize = 16.0;
    const questionColor = Colors.blueGrey;
    const answerColor = Colors.blueAccent;
    const noteColor = Colors.blueAccent;
    if (_showNote) {
      return Text(
        card.note,
        style: const TextStyle(color: noteColor, fontSize: cardFontSize),
      );
    } else if (_isFlipped) {
      return Text(
        card.question,
        style: const TextStyle(color: questionColor, fontSize: cardFontSize),
      );
    } else {
      return Text(
        card.answer,
        style: const TextStyle(color: answerColor, fontSize: cardFontSize),
      );
    }
  }

  Widget _noteButton() {
    var buttonStyle = _showNote
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
        onPressed: () => setState(() => _showNote = !_showNote),
        style: buttonStyle,
        child: const Text('ノート'),
      ),
    );
  }

  Widget _incorrectButton() {
    return _statusButton(
      status: CardStatus.incorrect,
      color: Colors.red,
      icon: Icons.close,
    );
  }

  Widget _pendingButton() {
    return _statusButton(
      status: CardStatus.pending,
      color: Colors.amber,
      icon: Icons.change_history,
    );
  }

  Widget _correctButton() {
    return _statusButton(
      status: CardStatus.correct,
      color: Colors.green,
      icon: Icons.circle_outlined,
    );
  }

  Widget _statusButton(
      {required CardStatus status,
      required Color color,
      required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4),
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => {
          setState(() {
            _updateList.add(
              UpdateStatus(id: _cards[_index].id, status: status),
            );
          }),
          nextCard(),
          print(_cards[_index])
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
    if (_index < _cards.length - 1) {
      setState(() => _index++);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("テスト完了"),
          content: const Text("全てのカードの確認が完了しました。"),
          actions: <Widget>[
            TextButton(
              child: const Text("閉じる"),
              onPressed: () async {
                await _updateAllCards();
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAllCards() async {
    final cardsDB = ref.watch(cardsDatabaseProvider);
    for (var update in _updateList) {
      await cardsDB.updateCardStatus(update.id, update.status);
    }
  }
}
