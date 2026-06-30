import 'package:flutter/material.dart';
import '../models/kp.dart';
import '../theme.dart';

class StatusCard extends StatefulWidget {
  final double kp;
  final String updatedLabel;
  const StatusCard({super.key, required this.kp, required this.updatedLabel});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ((4 - widget.kp / 3).clamp(1, 4) * 1000).round()),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StatusCard old) {
    super.didUpdateWidget(old);
    _pulse.duration =
        Duration(milliseconds: ((4 - widget.kp / 3).clamp(1, 4) * 1000).round());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = getKpSpiritualDetails(widget.kp);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xB30E0E16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.04).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: d.color, width: 3.5),
              boxShadow: [BoxShadow(color: d.color.withValues(alpha: 0.5), blurRadius: 14)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(widget.kp.toStringAsFixed(2),
                  style: AppText.sans(size: 23, weight: FontWeight.w800, color: d.color)),
              Text('Genlik',
                  style: AppText.sans(size: 11, weight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
            ]),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.label, style: AppText.sans(size: 17, weight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(d.spiritual,
                style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.primaryGold)),
            const SizedBox(height: 8),
            Text(widget.updatedLabel,
                style: AppText.sans(size: 13, color: AppColors.textMuted)),
          ]),
        ),
      ]),
    );
  }
}
