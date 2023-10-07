import 'package:flutter/material.dart';

class CardDetailView extends StatefulWidget {
  final String question;
  final String answer;
  // final String note;
  const CardDetailView({
    super.key,
    required this.question,
    required this.answer,
    // required this.note,
  });
  @override
  CardDetailViewState createState() => CardDetailViewState();
}

class CardDetailViewState extends State<CardDetailView> {
  String _question = '';
  String _answer = '';
  String _note = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _question = widget.question;
      _answer = widget.answer;
      // _note = widget.note;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カード詳細'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('問題'),
              _questionCard(),
              const SizedBox(height: 24),
              const Text('答え'),
              _answerCard(),
              const SizedBox(height: 24),
              const Text('ノート'),
              _noteCard(),
              const SizedBox(height: 24),
              _saveButton(),
              const SizedBox(height: 12),
              _deleteButton(),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionCard() {
    // TextFieldの初期値をセット
    final controller = TextEditingController(text: _question);
    // TextFieldのカーソルを末尾にするために必要
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    const cardWidth = 400.0;
    const cardHeight = 200.0;
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 24.0,
            right: 24.0,
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (String value) {
              setState(() => _question = value);
            },
          ),
        ),
      ),
    );
  }

  Widget _answerCard() {
    // TextFieldの初期値をセット
    final controller = TextEditingController(text: _answer);
    // TextFieldのカーソルを末尾にするために必要
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    const cardWidth = 400.0;
    const cardHeight = 200.0;
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 24.0,
            right: 24.0,
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (String value) {
              setState(() => _answer = value);
            },
          ),
        ),
      ),
    );
  }

  Widget _noteCard() {
    // TextFieldの初期値をセット
    final controller = TextEditingController(text: _note);
    // TextFieldのカーソルを末尾にするために必要
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    const cardWidth = 400.0;
    const cardHeight = 200.0;
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 24.0,
            right: 24.0,
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (String value) {
              setState(() => _note = value);
            },
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: 200,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(),
        onPressed: () {},
        child: const Text('保存'),
      ),
    );
  }

  Widget _deleteButton() {
    return SizedBox(
      width: 200,
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 0.5),
        ),
        onPressed: () {},
        child: const Text('削除', style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
