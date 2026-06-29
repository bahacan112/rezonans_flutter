import 'package:flutter/material.dart';
import '../models/kp.dart';
import '../theme.dart';

class Spectrogram extends StatefulWidget {
  final List<HistoryPoint> history;
  const Spectrogram({super.key, required this.history});
  @override
  State<Spectrogram> createState() => _SpectrogramState();
}

const _hzLabels = ['32 Hz', '26 Hz', '20 Hz', '14 Hz', '7.8 Hz'];
const _colW = 34.0;
const _h = 135.0;

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Schumann Rezonans Spektrogramı', style: AppText.sans(size: 14, weight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text('Atmosferik boşlukta rezonans frekanslarının uyarılma şiddeti',
            style: AppText.sans(size: 10, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        SizedBox(
          height: 24,
          child: Center(
            child: hover == null
                ? Text('Detayları görmek için dalgaların üzerine dokunun',
                    style: AppText.sans(size: 9, color: AppColors.textMuted))
                : Text(
                    'Zaman: ${_range(hover!.time)} | Kp: ${hover!.kp.toStringAsFixed(2)} | ${getKpSpiritualDetails(hover!.kp).label}',
                    style: AppText.sans(size: 9, color: getKpSpiritualDetails(hover!.kp).color)),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: _h,
            color: AppColors.bgSpace,
            child: Row(children: [
              Container(
                width: 44,
                color: const Color(0xFF06060C),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final l in _hzLabels)
                      Text(l, style: AppText.mono(size: 8, weight: FontWeight.w700, color: AppColors.primaryGold)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GestureDetector(
                    onTapDown: (e) {
                      final i = (e.localPosition.dx / _colW).floor();
                      if (i >= 0 && i < widget.history.length) {
                        setState(() => hover = widget.history[i]);
                      }
                    },
                    child: CustomPaint(
                      size: Size(widget.history.length * _colW, _h),
                      painter: _SpecPainter(widget.history, hover),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SpecPainter extends CustomPainter {
  final List<HistoryPoint> history;
  final HistoryPoint? hover;
  _SpecPainter(this.history, this.hover);

  // (yPct, alpha) per band, top->bottom
  static const _bands = [
    [0.12, 0.12], [0.32, 0.22], [0.52, 0.38], [0.72, 0.62], [0.9, 0.95],
  ];

  Color _rgb(double kp) {
    if (kp < 3) return const Color(0xFF10B981);
    if (kp < 4) return const Color(0xFFF59E0B);
    if (kp < 5) return const Color(0xFFF97316);
    if (kp < 8) return const Color(0xFFEF4444);
    return const Color(0xFF00E5FF);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.bgSpace);
    final now = DateTime.now();
    final p = Paint();
    for (int i = 0; i < history.length; i++) {
      final h = history[i];
      final x = i * _colW;
      final forecast = h.time.isAfter(now);
      final dim = forecast ? 0.35 : 1.0;
      final intensity = (h.kp / 9 + 0.15).clamp(0.0, 1.0);
      final base = _rgb(h.kp);
      for (final b in _bands) {
        final yc = b[0] * size.height;
        p.color = base.withValues(alpha: b[1] * dim * intensity);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 1, yc - 8, _colW - 2, 16),
            const Radius.circular(3),
          ),
          p,
        );
      }
      if (hover != null && hover!.time == h.time) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, _colW, size.height),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.06)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpecPainter old) => old.hover != hover || old.history != history;
}
