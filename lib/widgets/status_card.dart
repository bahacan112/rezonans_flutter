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

class _StatusCardState extends State<StatusCard> {

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.label, style: AppText.sans(size: 17, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(d.spiritual,
                        style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.primaryGold)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.kp.toStringAsFixed(2),
                    style: AppText.sans(size: 24, weight: FontWeight.w900, color: d.color),
                  ),
                  Text(
                    'RS',
                    style: AppText.sans(size: 9, weight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final progress = (widget.kp / 10.0).clamp(0.0, 1.0);
              final fillWidth = constraints.maxWidth * progress;
              return Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                alignment: Alignment.centerLeft,
                child: fillWidth > 0
                    ? Container(
                        width: fillWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: d.color,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: d.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.00', style: AppText.mono(size: 10, color: AppColors.textMuted)),
              Text(widget.updatedLabel, style: AppText.sans(size: 12, color: AppColors.textMuted)),
              Text('10.00', style: AppText.mono(size: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
