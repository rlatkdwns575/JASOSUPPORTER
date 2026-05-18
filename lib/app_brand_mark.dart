import 'package:flutter/material.dart';

/// PNG 없이 그리는 앱 마크(배경 완전 투명). 앱바·빈 화면 등에 사용.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final Color c = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _JasoMarkPainter(color: c)),
    );
  }
}

class _JasoMarkPainter extends CustomPainter {
  _JasoMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide;
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;
    final double p = s * 0.1;

    final RRect doc = RRect.fromRectAndRadius(
      Rect.fromLTWH(p, p, w - 2 * p, h - 2 * p),
      Radius.circular(s * 0.12),
    );
    canvas.drawRRect(doc, stroke);

    final double lx = p + s * 0.12;
    final double rx = w - p - s * 0.12;
    double y = p + s * 0.32;
    canvas.drawLine(Offset(lx, y), Offset(rx, y), stroke);
    y += s * 0.16;
    canvas.drawLine(Offset(lx, y), Offset(rx - s * 0.12, y), stroke);
    y += s * 0.16;
    canvas.drawLine(Offset(lx, y), Offset(rx - s * 0.22, y), stroke);

    final Paint pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(p + s * 0.2, h - p - s * 0.08),
      Offset(w - p - s * 0.08, p + s * 0.42),
      pen,
    );
  }

  @override
  bool shouldRepaint(covariant _JasoMarkPainter old) => old.color != color;
}
