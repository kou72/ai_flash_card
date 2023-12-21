import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CardTestView extends ConsumerStatefulWidget {
  @override
  CardTestViewState createState() => CardTestViewState();
}

class CardTestViewState extends ConsumerState<CardTestView> {
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
