import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);          // Top center
    path.lineTo(0, size.height);             // Bottom left
    path.lineTo(size.width, size.height);    // Bottom right
    path.close();                            // Connect back to start

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TriangleWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const TriangleWidget({
    super.key,
    this.width = 100,
    this.height = 100,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: TrianglePainter(color: color),
    );
  }
}