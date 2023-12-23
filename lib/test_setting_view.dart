import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestSettingView extends ConsumerStatefulWidget {
  @override
  TestSettingViewState createState() => TestSettingViewState();
}

class TestSettingViewState extends ConsumerState<TestSettingView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TestSettingView'),
    );
  }
}
