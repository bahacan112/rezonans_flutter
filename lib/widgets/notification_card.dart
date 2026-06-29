import 'package:flutter/material.dart';
import '../theme.dart';

class _Band {
  final int band;
  final String label, range;
  final Color color;
  const _Band(this.band, this.label, this.range, this.color);
}

const _bands = [
  _Band(1, 'Hareketlenme', 'Kp 3 – 5', KpColors.unsettled),
  _Band(2, 'Jeomanyetik Fırtına', 'Kp 5 – 7', KpColors.storm),
  _Band(3, 'Portal Geçişi', 'Kp 7+', KpColors.portal),
];

class NotificationCard extends StatelessWidget {
  final bool isPremium;
  final List<int> prefs;
  final ValueChanged<int> onTogglePref;
  final VoidCallback onUnlock;
  const NotificationCard({
    super.key,
    required this.isPremium,
    required this.prefs,
    required this.onTogglePref,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) {
      return GestureDetector(
        onTap: onUnlock,
        child: _wrap(Row(children: [
          const Text('🔒', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text('Kozmik Rezonans Bildirimleri', style: AppText.sans(size: 12, weight: FontWeight.w700))),
                const SizedBox(width: 8),
                _badge('PREMIUM', AppColors.primaryGold, Colors.black),
              ]),
              const SizedBox(height: 6),
              Text('Hangi Kp aralıklarında bildirim alacağınızı seçin. Premium\'a yükselterek aktif edin.',
                  style: AppText.sans(size: 10, color: AppColors.textMuted, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.45), width: 1.5),
            ),
            child: Text('Satın Al', style: AppText.sans(size: 11, weight: FontWeight.w700, color: AppColors.primaryGold)),
          ),
        ])),
      );
    }

    final anyOn = prefs.isNotEmpty;
    return _wrap(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Text('🔔', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('Kozmik Rezonans Bildirimleri', style: AppText.sans(size: 12, weight: FontWeight.w700)),
        ]),
        _badge(anyOn ? 'AKTİF' : 'KAPALI', anyOn ? KpColors.portal : Colors.white24, anyOn ? Colors.black : Colors.white),
      ]),
      const SizedBox(height: 8),
      Text('Bildirim almak istediğiniz Kp aralıklarını seçin. Sadece seçtikleriniz hem uygulamada hem telefon bildirimi olarak gelir.',
          style: AppText.sans(size: 10, color: AppColors.textMuted, height: 1.4)),
      const SizedBox(height: 4),
      for (final b in _bands)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: Row(children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: b.color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.label, style: AppText.sans(size: 12, weight: FontWeight.w600)),
                Text(b.range, style: AppText.mono(size: 10, color: AppColors.textMuted)),
              ]),
            ),
            Switch(
              value: prefs.contains(b.band),
              onChanged: (_) => onTogglePref(b.band),
              activeThumbColor: AppColors.primaryGold,
              activeTrackColor: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
          ]),
        ),
    ]));
  }

  Widget _wrap(Widget child) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: child,
      );

  Widget _badge(String t, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(t, style: AppText.sans(size: 8, weight: FontWeight.w900, color: fg, letterSpacing: 0.8)),
      );
}
