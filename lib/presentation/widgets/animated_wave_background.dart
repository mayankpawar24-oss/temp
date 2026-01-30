import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedWaveBackground extends StatefulWidget {
  final List<Color> colors;
  final double heightFactor;

  const AnimatedWaveBackground({
    super.key,
    required this.colors,
    this.heightFactor = 1.0,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WavePainter(
            progress: _controller.value,
            colors: widget.colors,
            heightFactor: widget.heightFactor,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double heightFactor;

  _WavePainter({
    required this.progress,
    required this.colors,
    required this.heightFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseHeight = size.height * 0.55 * heightFactor;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < colors.length; i++) {
      final color = colors[i];
      final waveHeight = size.height * (0.08 + i * 0.03) * heightFactor;
      final yOffset = baseHeight + (i * size.height * 0.06 * heightFactor);
      final phase = (progress * 2 * math.pi) + (i * math.pi / 2);

      final path = Path()..moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 8) {
        final dx = (x / size.width) * 2 * math.pi;
        final y = yOffset + math.sin(dx + phase) * waveHeight;
        path.lineTo(x, y);
      }

      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      paint.color = color;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.heightFactor != heightFactor;
  }
}
