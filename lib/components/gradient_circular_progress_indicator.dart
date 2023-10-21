import 'package:flutter/material.dart';
import 'dart:math';

class GradientCircularProgressIndicator extends StatefulWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final double progress;

  const GradientCircularProgressIndicator({
    Key? key,
    this.width = 100.0,
    this.height = 100.0,
    this.colors = const [Colors.blue, Colors.purple],
    required this.progress,
  }) : super(key: key);

  @override
  GradientCircularProgressIndicatorState createState() =>
      GradientCircularProgressIndicatorState();
}

class GradientCircularProgressIndicatorState
    extends State<GradientCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GradientCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween(begin: oldWidget.progress, end: widget.progress)
          .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: GradientCircularProgressPainter(
                _animation.value, widget.colors),
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
  final double progress;
  final List<Color> colors;

  GradientCircularProgressPainter(this.progress, this.colors);

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

    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;

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
