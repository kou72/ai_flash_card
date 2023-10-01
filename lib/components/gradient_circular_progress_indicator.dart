import 'package:flutter/material.dart';
import 'dart:math';

class GradientCircularProgressIndicator extends StatefulWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final int milliseconds;

  const GradientCircularProgressIndicator({
    Key? key,
    this.width = 100.0,
    this.height = 100.0,
    this.colors = const [Colors.blue, Colors.purple],
    this.milliseconds = 1500,
  }) : super(key: key);

  @override
  GradientCircularProgressIndicatorState createState() =>
      GradientCircularProgressIndicatorState();
}

class GradientCircularProgressIndicatorState
    extends State<GradientCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationStart;
  late Animation<double> _animationEnd;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.milliseconds),
      vsync: this,
    );

    _animationStart = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.fastOutSlowIn),
      ),
    );

    _animationEnd = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: GradientCircularProgressPainter(
                _animationStart.value, _animationEnd.value, widget.colors),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double startProgress;
  final double endProgress;
  final List<Color> colors;

  GradientCircularProgressPainter(
      this.startProgress, this.endProgress, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = LinearGradient(
      colors: colors,
    );

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final double startAngle = 2 * pi * startProgress - pi / 2;
    final double endAngle = 2 * pi * endProgress - pi / 2;
    final double sweepAngle = endAngle - startAngle;

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2 - paint.strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
