import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingView extends StatefulWidget {
  LoadingView(double size, {super.key, this.duration = const Duration(milliseconds: 600)}) : _size = Size(size, size);

  final Size _size;
  final Duration duration;

  @override
  State<StatefulWidget> createState() {
    return _LoadingViewState();
  }
}

class _LoadingViewState extends State<LoadingView> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(value: 1.0, duration: widget.duration, vsync: this);
    _animationController.forward(from: 0.0);
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LoadingViewPainter(_animationController),
      size: widget._size,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _LoadingViewPainter extends CustomPainter {
  _LoadingViewPainter(
    AnimationController repaint, {
    // ignore: unused_element
    this.color = Colors.white,
  })  : animation = IntTween(begin: 0, end: _LoadingViewPainter._lineCount).animate(repaint),
        super(repaint: repaint);

  final Animation animation;
  final Color color;
  late Paint _paint;

  static const int _lineCount = 12;
  static const double _degreePerLine = (2 * math.pi) / _lineCount;

  @override
  void paint(Canvas canvas, Size size) {
    double min = math.min(size.width, size.height);

    double width = min / 12, height = min / 6;

    _paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.saveLayer(Rect.fromLTRB(0.0, 0.0, size.width, size.height), _paint);

    double radians = animation.value * _degreePerLine;
    canvas.translate(min / 2, min / 2);
    canvas.rotate(radians);

    for (int i = 0; i < _lineCount; i++) {
      canvas.rotate(_degreePerLine);
      _paint.color = _paint.color.withAlpha(255 * (i + 1) ~/ _lineCount);
      canvas.translate(0.0, -min / 2 + width / 2);
      canvas.drawLine(Offset.zero, Offset(0.0, height), _paint);
      canvas.translate(0.0, min / 2 - width / 2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LoadingViewPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
