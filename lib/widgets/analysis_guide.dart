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
    'Schumann Genlik Değeri Nedir? (Kp ve Genlik İlişkisi)',
    'Uygulamamızda "Genlik" olarak basitleştirilen bu değer, aslında NOAA uydularından alınan küresel jeomanyetik Kp indeksidir. Teknik olarak Schumann Rezonansının gerçek genliği pikotesla (pT) cinsinden ölçülen elektromanyetik dalga gücüdür; Kp indeksi ise Dünya manyetik alanındaki dalgalanmaları (0-9 arası) ölçer.\n\n'
        'Aralarındaki ilişki ise şudur: Güneş fırtınaları nedeniyle Kp indeksi yükseldiğinde, Dünya\'nın manyetik kalkanı dalgalanır ve bu yüklü parçacıklar Schumann dalgalarının yansıdığı "tavanı" (iyonosferi) bastırarak fiziksel rezonans genliğini ve frekansını doğrudan etkiler. Uygulamamızda kullanıcılara kolaylık sağlamak amacıyla, Dünya\'nın bu jeomanyetik uyarılma düzeyi "Schumann Genliği" olarak basitleştirilerek yansıtılmıştır.'
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
    'Tomsk (SOS70) ve Diğer Kaynaklar (GCI, Cumana vb.) ile Neden Farklar Var?',
    'Tomsk (SOS70), Cumana (İtalya) veya GCI (Global Coherence Initiative) gibi gözlemevleri, kendi yerel bölgelerindeki elektromanyetik sinyalleri ve yıldırım deşarjlarını ölçer. Bu rasathanelerin kendi sitelerinde de belirttikleri üzere, grafiklerdeki ani dikey yükselmeler genellikle bölgesel gürültülerden ve yerel şimşek fırtınalarından kaynaklanır.\n\n'
        'Uygulamamız ise tüm dünyayı etkileyen küresel jeomanyetik fırtınaları (NOAA verilerini) temel aldığı için, yerel ölçüm yapan istasyonlar ile aralarında farklar oluşması fiziksel ve bilimsel açıdan tamamen normaldir. Ayrıca bu siteler genellikle kendi yerel saat dilimlerini (örneğin Tomsk UTC+7) kullanırken, uygulamamız tüm verileri otomatik olarak kendi yerel saat diliminize çevirir.'
  ],
  [
    'Tahmin ile Gerçekleşen Ölçüm Neden Farklı Olabilir?',
    'Uzay havası tahminleri, güneş fırtınasının yola çıktığını ve Dünya\'ya ulaşacağını önceden modeller (Tahmin). Ancak şu sebeplerle gerçek ölçüm daha düşük kalabilir:\n\n'
        '• Zamanlama Gecikmesi: Fırtınanın hızı yavaşlayabilir ve tahmin edilenden saatler sonra ulaşabilir. Bu süreçte geçmiş ölçümler sakin kalmaya devam eder.\n'
        '• Manyetik Kutuplanma (Bz): Fırtınanın manyetik alanı Dünya\'nın kalkanıyla aynı yöndeyse (Kuzey Bz+) kalkanımız fırtınayı engeller ve dalgalanma ölçülmez.\n'
        '• Rota Sapması (Teğet Geçme): Fırtına uzayda yön değiştirip Dünya\'yı sıyırıp geçebilir.\n'
        '• Küresel Ortalama: Kp indeksi küresel bir ortalamadır; fırtına lokal kalsa da küresel etki zayıf kalabilir.'
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
