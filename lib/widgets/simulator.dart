import 'package:flutter/material.dart';
import '../models/kp.dart';
import '../theme.dart';

class Simulator extends StatelessWidget {
  final bool simulating;
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onReset;
  const Simulator({
    super.key,
    required this.simulating,
    required this.value,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final color = simulating ? getKpSpiritualDetails(value).color : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8C12121C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Kozmik Enerji Simülatörü', style: AppText.sans(size: 18, weight: FontWeight.w700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: KpColors.portal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: KpColors.portal.withValues(alpha: 0.3)),
            ),
            child: Text('TEST PANELİ',
                style: AppText.sans(size: 10, weight: FontWeight.w800, color: KpColors.portal)),
          ),
        ]),
        const SizedBox(height: 2),
        Text('Farklı Genlik seviyelerinin etkilerini ve renk değişimlerini test edin',
            style: AppText.sans(size: 13, color: AppColors.textMuted)),
        Row(children: [
          Text('Genlik 0', style: AppText.mono(size: 13, color: AppColors.textMuted)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primaryGold,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                thumbColor: AppColors.primaryGold,
                trackHeight: 4,
              ),
              child: Slider(min: 0, max: 9, value: value, onChanged: onChanged),
            ),
          ),
          Text('Genlik 9', style: AppText.mono(size: 13, color: AppColors.textMuted)),
        ]),
        Row(children: [
          Text('Simüle Edilen Değer: ', style: AppText.sans(size: 14, color: AppColors.textMuted)),
          Text(simulating ? 'Genlik ${value.toStringAsFixed(1)}' : 'Canlı Akış',
              style: AppText.sans(size: 14, weight: FontWeight.w700, color: color)),
          const Spacer(),
          if (simulating)
            GestureDetector(
              onTap: onReset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text('Canlı Veriye Dön', style: AppText.sans(size: 13)),
              ),
            ),
        ]),
      ]),
    );
  }
}
