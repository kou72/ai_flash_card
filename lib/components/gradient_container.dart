import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final String text;
  final IconData iconData;
  final double width;
  final double height;
  final List<Color> colors;

  const GradientContainer({
    Key? key,
    required this.text,
    required this.iconData,
    required this.width,
    required this.height,
    this.colors = const [Colors.blue, Colors.purple], // デフォルトのグラデーション色
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      width: width + 4,
      height: height + 4,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: InkWell(
          onTap: () {
            print("Tap!");
          },
          borderRadius: BorderRadius.circular(22.0),
          child: SizedBox(
            width: width,
            height: height,
            child: _buildIconWithText(),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(
            iconData,
            color: Colors.white,
            size: 48.0,
          ),
        ),
        const SizedBox(height: 8.0),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, // ShaderMaskを適用するためのベースとなる色
              fontSize: 16.0,
            ),
          ),
        ),
      ],
    );
  }
}
