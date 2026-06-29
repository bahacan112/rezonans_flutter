import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class Starfield extends StatefulWidget {
  final Color glowColor;
  const Starfield({super.key, this.glowColor = KpColors.portal});

  @override
  State<Starfield> createState() => _StarfieldState();
}

class _Star {
  double x, y, size, baseOpacity, phase, speed;
  _Star(this.x, this.y, this.size, this.baseOpacity, this.phase, this.speed);
}

class _StarfieldState extends State<Starfield>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();
  List<_Star>? _stars;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  void _ensureStars(Size size) {
    if (_stars != null) return;
    final count = min(160, (size.width * size.height / 9000).floor());
    _stars = List.generate(count, (_) {
      return _Star(
        _rng.nextDouble() * size.width,
        _rng.nextDouble() * size.height,
        _rng.nextDouble() * 1.3 + 0.5,
        _rng.nextDouble() * 0.6 + 0.2,
        _rng.nextDouble(),
        _rng.nextDouble() * 0.4 + 0.2,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);
      _ensureStars(size);
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => CustomPaint(
          size: size,
          painter: _StarfieldPainter(_stars!, _ctrl.value, widget.glowColor),
        ),
      );
    });
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  final Color glow;
  _StarfieldPainter(this.stars, this.t, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.bgSpace);

    // Aurora glow (top-right)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [glow.withValues(alpha: 0.10), glow.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.18),
        radius: size.width * 0.7,
      ));
    canvas.drawRect(Offset.zero & size, glowPaint);

    final p = Paint()..color = Colors.white;
    for (final s in stars) {
      final tw = (sin((t + s.phase) * 2 * pi) + 1) / 2; // 0..1
      p.color = Colors.white.withValues(alpha: s.baseOpacity * (0.3 + 0.7 * tw));
      final y = (s.y - t * s.speed * size.height) % size.height;
      canvas.drawRect(Rect.fromLTWH(s.x, y, s.size, s.size), p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) =>
      old.t != t || old.glow != glow;
}
