import 'package:flutter/material.dart';

class CardTestView extends StatefulWidget {
  const CardTestView({super.key});
  @override
  CardTestViewState createState() => CardTestViewState();
}

class CardTestViewState extends State<CardTestView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              color: Colors.grey,
              size: 72.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'ただいま開発中です！',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
