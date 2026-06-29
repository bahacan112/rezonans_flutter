import 'package:flutter/material.dart';
import '../models/kp.dart';
import '../theme.dart';

class TrendChart extends StatefulWidget {
  final List<HistoryPoint> history;
  const TrendChart({super.key, required this.history});
  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
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
    final now = DateTime.now();
    return _card(
      title: 'Jeomanyetik Kp Eğilimi (Son 72 Saat)',
      sub: 'Ölçülen ve tahmin edilen jeomanyetik fırtına değerleri',
      child: Column(children: [
        SizedBox(
          height: 24,
          child: Center(
            child: hover == null
                ? Text('Detayları görmek için sütunların üzerine dokunun',
                    style: AppText.sans(size: 9, color: AppColors.textMuted))
                : Text(
                    'Zaman: ${_range(hover!.time)}${hover!.predicted ? ' (Tahmin)' : ' (Ölçüm)'}  |  Kp: ${hover!.kp.toStringAsFixed(2)}',
                    style: AppText.sans(size: 9, color: AppColors.textMuted)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final h in widget.history)
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => hover = h),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: (h.kp / 9).clamp(0.1, 1.0),
                          child: _bar(h, h.time.isAfter(now)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 6, children: [
          _legend(KpColors.quiet, 'Sakin (0-3)'),
          _legend(KpColors.active, 'Aktif (3-5)'),
          _legend(KpColors.storm, 'Fırtına (5+)'),
          _legend(null, 'Tahmin'),
        ]),
      ]),
    );
  }

  Widget _bar(HistoryPoint h, bool predicted) {
    final color = getKpSpiritualDetails(h.kp).color;
    return Container(
      decoration: BoxDecoration(
        color: predicted ? Colors.transparent : color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        border: predicted ? Border.all(color: color) : null,
      ),
    );
  }

  Widget _legend(Color? dot, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dot,
            shape: dot != null ? BoxShape.circle : BoxShape.rectangle,
            border: dot == null ? Border.all(color: AppColors.primaryGold) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppText.sans(size: 9, color: AppColors.textMuted)),
      ]);
}

Widget _card({required String title, required String sub, required Widget child}) => Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppText.sans(size: 14, weight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(sub, style: AppText.sans(size: 10, color: AppColors.textMuted)),
        const SizedBox(height: 12),
        child,
      ]),
    );
