import 'package:flutter/material.dart';
import '../models/kp.dart';
import '../theme.dart';

class Spectrogram extends StatefulWidget {
  final List<HistoryPoint> history;
  const Spectrogram({super.key, required this.history});

  @override
  State<Spectrogram> createState() => _SpectrogramState();
}

const _hzLabels = ['7.8 Hz', '14 Hz', '20 Hz', '26 Hz', '32 Hz'];
const _bandYFactors = [0.196, 0.353, 0.508, 0.660, 0.810];

class _SpectrogramState extends State<Spectrogram> {
  HistoryPoint? hover;

  String _range(DateTime start) {
    final end = start.add(const Duration(hours: 3));
    const days = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];
    final sd = days[start.weekday % 7], ed = days[end.weekday % 7];
    final sh = start.hour.toString().padLeft(2, '0');
    final eh = end.hour.toString().padLeft(2, '0');
    return sd != ed ? '$sd $sh:00 - $ed $eh:00' : '$sd $sh:00 - $eh:00';
  }

  @override
  Widget build(BuildContext context) {
    const double colW = 16.0; // Narrower columns for higher horizontal resolution
    const double h = 150.0;
    final double totalWidth = widget.history.length * colW;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schumann Rezonans Spektrogramı',
            style: AppText.sans(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'Atmosferik boşlukta rezonans frekanslarının uyarılma şiddeti',
            style: AppText.sans(size: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            child: Center(
              child: hover == null
                  ? Text(
                      'Detayları görmek için dalgaların üzerine dokunun',
                      style: AppText.sans(size: 9, color: AppColors.textMuted),
                    )
                  : Text(
                      'Zaman: ${_range(hover!.time)} | Kp: ${hover!.kp.toStringAsFixed(2)} | ${getKpSpiritualDetails(hover!.kp).label}',
                      style: AppText.sans(size: 9, color: getKpSpiritualDetails(hover!.kp).color),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: h,
              color: const Color(0xFF030308),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Y-Axis Labels (Frequencies)
                  Container(
                    width: 44,
                    height: h,
                    color: const Color(0xFF06060C),
                    child: Stack(
                      children: [
                        for (int i = 0; i < _hzLabels.length; i++)
                          Positioned(
                            top: _bandYFactors[i] * h - 6,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                _hzLabels[i],
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Spectrogram Custom Paint
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GestureDetector(
                        onTapDown: (e) {
                          final i = (e.localPosition.dx / colW).floor();
                          if (i >= 0 && i < widget.history.length) {
                            setState(() => hover = widget.history[i]);
                          }
                        },
                        child: CustomPaint(
                          size: Size(totalWidth, h),
                          painter: _SpecPainter(widget.history, hover, colW),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecPainter extends CustomPainter {
  final List<HistoryPoint> history;
  final HistoryPoint? hover;
  final double colW;
  _SpecPainter(this.history, this.hover, this.colW);

  // The global _bandYFactors is used here instead.

  // Map Kp values to a continuous color scale matching the real SOS70 spectrogram
  Color _getSpectrogramColor(double kp) {
    final t = (kp / 9.0).clamp(0.0, 1.0);
    if (t < 0.15) {
      // Very Quiet: Dark Space Blue/Cyan gradient
      return Color.lerp(const Color(0xFF00081A), const Color(0xFF002266), t / 0.15)!;
    } else if (t < 0.35) {
      // Quiet to Active: Blue to Green
      return Color.lerp(const Color(0xFF002266), const Color(0xFF00E676), (t - 0.15) / 0.20)!;
    } else if (t < 0.55) {
      // Active to Moderate: Green to Yellow-Orange
      return Color.lerp(const Color(0xFF00E676), const Color(0xFFFFD600), (t - 0.35) / 0.20)!;
    } else if (t < 0.75) {
      // Strong: Yellow-Orange to Red
      return Color.lerp(const Color(0xFFFFD600), const Color(0xFFE53935), (t - 0.55) / 0.20)!;
    } else {
      // Zirve/Extreme: Red to Pure Glowing White
      return Color.lerp(const Color(0xFFE53935), const Color(0xFFFFFFFF), (t - 0.75) / 0.25)!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    // 1. Draw Space Background Gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF020205), Color(0xFF050510)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Draw Subtle Horizontal Frequency Guide Lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    for (final factor in _bandYFactors) {
      final y = factor * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    if (history.isEmpty) return;

    // 3. Interpolate and Paint continuous waves
    // We increase horizontal resolution by interpolating between the 3-hour data points
    const int interpolationSteps = 4; // Sub-steps per column
    final double stepWidth = colW / interpolationSteps;
    final int totalSteps = (history.length - 1) * interpolationSteps + 1;

    for (int i = 0; i < totalSteps; i++) {
      final double exactIndex = i / interpolationSteps;
      final int leftIdx = exactIndex.floor();
      final int rightIdx = exactIndex.ceil().clamp(0, history.length - 1);
      final double t = exactIndex - leftIdx;

      final HistoryPoint leftPoint = history[leftIdx];
      final HistoryPoint rightPoint = history[rightIdx];

      // Interpolate Kp and time
      final double kp = leftPoint.kp + (rightPoint.kp - leftPoint.kp) * t;
      final bool forecast = leftPoint.time.isAfter(now);

      final double x = exactIndex * colW;

      // Skip painting lines off canvas
      if (x < 0 || x > size.width) continue;

      // Determine intensity and color based on the interpolated Kp value
      final double intensity = (kp / 9.0 + 0.1).clamp(0.0, 1.0);
      final Color baseColor = _getSpectrogramColor(kp);
      final double opacityDim = forecast ? 0.35 : 1.0;

      // Draw the spectrogram data as overlapping vertical gradient blobs for each frequency band
      for (final yFactor in _bandYFactors) {
        final double yc = yFactor * size.height;
        
        // Define a smooth vertical glow height based on Kp intensity
        final double blobHeight = 12.0 + (kp * 1.5);
        final rect = Rect.fromLTRB(
          x,
          yc - (blobHeight / 2),
          x + stepWidth + 0.5, // 0.5 overlap prevents pixel gaps
          yc + (blobHeight / 2),
        );

        final Paint blobPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              baseColor.withValues(alpha: 0.0),
              baseColor.withValues(alpha: 0.85 * opacityDim * intensity),
              baseColor.withValues(alpha: 0.0),
            ],
          ).createShader(rect);

        canvas.drawRect(rect, blobPaint);
      }

      // 4. Draw Vertical Lightning/Solar Bursts (White vertical streams for high activity points)
      if (kp > 5.0 && !forecast) {
        final burstRect = Rect.fromLTRB(x, 0, x + stepWidth + 0.5, size.height);
        final burstPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.3 * ((kp - 5.0) / 4.0)),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(burstRect);
        canvas.drawRect(burstRect, burstPaint);
      }
    }

    // 5. Draw Hover Indicator Overlay
    if (hover != null) {
      final int idx = history.indexWhere((p) => p.time == hover!.time);
      if (idx != -1) {
        final x = idx * colW;
        canvas.drawRect(
          Rect.fromLTWH(x, 0, colW, size.height),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.06)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpecPainter old) =>
      old.hover != hover || old.history != history;
}
