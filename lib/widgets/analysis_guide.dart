import 'package:flutter/material.dart';
import '../theme.dart';

class AnalysisCard extends StatelessWidget {
  final String title;
  final String spiritual;
  final String text;
  const AnalysisCard({
    super.key,
    required this.title,
    required this.spiritual,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: AppText.sans(size: 15, weight: FontWeight.w700, color: AppColors.primaryGold)),
          const SizedBox(height: 5),
          Text(spiritual,
              style: AppText.sans(size: 13, weight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(text, style: AppText.sans(size: 12, height: 1.5, color: AppColors.textMuted)),
        ]),
      );
}

const _guide = [
  [
    'Planetary K-Index (Kp Endeksi) Nedir?',
    'Dünya genelindeki manyetometre istasyonlarından gelen verilerin birleştirilmesiyle oluşturulan ve gezegenimizin manyetik alanındaki düzensizlikleri 0 ile 9 arasında ölçen resmi bir küresel endekstir. Kp değerinin 5 ve üzeri olması küresel bir Jeomanyetik Fırtına durumunu gösterir.'
  ],
  [
    'Güneş Fırtınası ve Biyolojik Etkiler:',
    'Dünya\'nın manyetik alanı ile insan kalp ritmi, sinir sistemi dengesi ve melatonin salgısı doğrudan senkronizedir. Kp endeksinin yükseldiği günlerde baş ağrısı, yorgunluk, rüyalarda berraklık veya uyku bozuklukları gibi semptomlar yaşanması yaygındır.'
  ],
  [
    'Gelecek 24 Saat Nasıl Hesaplanır?',
    'L1 noktasındaki DSCOVR ve ACE uyduları, Güneş patlamasıyla fırlayan parçacıkları yola çıktığı an ölçer. Bu parçacıkların Dünya\'ya ulaşması 15 saat ile 3 gün sürer. Sistem bu verileri işleyerek henüz ulaşmamış kozmik paketleri saatlik modellemeler halinde önceden sunar.'
  ],
];

class GuideAccordion extends StatefulWidget {
  const GuideAccordion({super.key});
  @override
  State<GuideAccordion> createState() => _GuideAccordionState();
}

class _GuideAccordionState extends State<GuideAccordion> {
  bool open = false;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => open = !open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Text('ⓘ', style: TextStyle(color: AppColors.primaryGold, fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Jeomanyetik Rezonans Kılavuzu',
                        style: AppText.sans(size: 13, weight: FontWeight.w700))),
                Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: open ? AppColors.primaryGold : AppColors.textMuted, size: 20),
              ]),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final g in _guide) ...[
                    Text(g[0], style: AppText.sans(size: 11, weight: FontWeight.w700, color: AppColors.primaryGold)),
                    const SizedBox(height: 3),
                    Text(g[1], style: AppText.sans(size: 10, color: AppColors.textMuted, height: 1.4)),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
        ]),
      );
}
