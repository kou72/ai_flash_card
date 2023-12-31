import 'package:flutter/material.dart';

class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String? label;
  final List<Color> gradientColors;

  const GradientFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.iconData,
    required this.label,
    this.gradientColors = const [Colors.blue, Colors.purple], // デフォルトのグラデーション色
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 4,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: label != null
            ? FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 4,
                icon: Icon(iconData),
                label: Text(label!),
                onPressed: onPressed,
              )
            : FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 4,
                onPressed: onPressed,
                child: Icon(iconData),
              ),
      ),
    );
  }
}
