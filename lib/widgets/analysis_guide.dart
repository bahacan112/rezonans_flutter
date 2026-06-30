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
              style: AppText.sans(size: 19, weight: FontWeight.w700, color: AppColors.primaryGold)),
          const SizedBox(height: 5),
          Text(spiritual,
              style: AppText.sans(size: 16, weight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text(text, style: AppText.sans(size: 16, height: 1.55, color: AppColors.textMuted)),
        ]),
      );
}

const _guide = [
  [
    'Schumann Genlik Değeri Nedir?',
    'Schumann Rezonans Spektrogramında dalgaların gücünü ve iyonosferdeki elektromanyetik uyarılma düzeyini gösteren bilimsel ölçüdür. Bu genlik değerleri, küresel jeomanyetik Kp hareketliliği ile doğrudan doğru orantılıdır; güneş patlamaları arttıkça genlik yükselir ve iyonosferde yoğun ışık kodları tetiklenir.'
  ],
  [
    'Ölçüm (Ölçülen) ve Tahmin (Gelecek) Ayrımı Nedir?',
    'Uygulamamızdaki grafiklerde altın sarısı kesikli bir "ŞİMDİ" çizgisi yer alır. Bu çizginin sol tarafında kalan net/parlak alanlar iyonosferde ölçülmüş ve kesinleşmiş geçmiş gerçek verileri (Ölçüm), sağ tarafında kalan loş alanlar ise uydulardan gelen verilerle modellenmiş gelecek 24 saatin öngörülerini (Tahmin) gösterir.'
  ],
  [
    'Kozmik Rezonans ve Biyolojik Etkiler (DNA Aktivasyonu):',
    'Dünya\'nın manyetik rezonansı ile insan beyninin Alfa dalgaları, sinir sistemi ve hücresel ritimler doğrudan uyumludur. Genlik değerlerinin yükseldiği uyanış pencerelerinde, beden yüksek kozmik frekansları entegre ederken hafif baş ağrısı, rüyalarda berraklık veya uykusuzluk hissedilebilir. Bu dönemler derin meditasyon ve DNA aktivasyonu çalışmaları için en yüksek potansiyele sahiptir.'
  ],
  [
    'Tomsk (SOS70) Grafiği ile Neden Farklar Var?',
    'Tomsk Rasathanesi (SOS70) kendi bilgilendirme sayfasında da belirttiği üzere, bu ölçümler yerel antenlerle Rusya\'nın Tomsk bölgesi üzerindeki yerel elektromanyetik hareketleri izler. O bölgedeki yerel bir şimşek fırtınası Tomsk grafiğinde devasa beyaz bir sütun oluşturabilir ancak bu küresel bir etki değildir. Uygulamamız ise tüm dünyayı sarsan küresel jeomanyetik fırtınaları (NOAA) temel alır. Dolayısıyla yerel şimşek anlarında Tomsk ile farklar oluşması fiziksel ve bilimsel açıdan tamamen normaldir.'
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
                const Text('ⓘ', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Jeomanyetik Rezonans Kılavuzu',
                        style: AppText.sans(size: 16, weight: FontWeight.w700))),
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
                    Text(g[0], style: AppText.sans(size: 15, weight: FontWeight.w700, color: AppColors.primaryGold)),
                    const SizedBox(height: 4),
                    Text(g[1], style: AppText.sans(size: 14, color: AppColors.textMuted, height: 1.5)),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
        ]),
      );
}
