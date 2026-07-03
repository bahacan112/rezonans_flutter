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
  [
    'İyonosfer Katmanı ve Schumann Rezonansı İlişkisi Nedir?',
    'İyonosfer, Dünya yüzeyinden yaklaşık 60 km ila 1000 km yükseklikte bulunan, güneş ışınları ve kozmik radyasyonla iyonize olmuş elektrik yüklü bir gaz (plazma) katmanıdır. Bu katman, elektrik iletkenliği sayesinde Dünya yüzeyi ile birlikte devasa bir doğal elektromanyetik "dalga kılavuzu" (waveguide) oluşturur. Şimşeklerin yarattığı elektromanyetik sinyaller bu kılavuzun tavanı (iyonosfer) ve tabanı (yer küre) arasında yansıyarak 7.83 Hz temel frekansındaki Schumann Rezonansını oluşturur. Güneş patlamaları iyonosferin yüksekliğini ve iletkenliğini değiştirerek rezonans dalgalarını doğrudan etkiler.'
  ],
  [
    'Güneş Rüzgarı Hızları ve Etkileri Nelerdir?',
    'Güneş rüzgarı, Güneş\'in korona katmanından uzaya yayılan yüklü parçacıkların (plazma) akışıdır. Normal zamanlarda güneş rüzgarı hızı yaklaşık 300 - 400 km/s (saniyede kilometre) civarındadır. Ancak Güneş\'te koronal delikler veya patlamalar (CME) meydana geldiğinde, bu hız 800 - 1000+ km/s değerlerine ulaşabilir. Güneş rüzgarının hızı ve parçacık yoğunluğu ne kadar yüksekse, Dünya\'nın manyetik alanına (manyetosfer) çarptığında oluşturduğu jeomanyetik fırtına (ve dolayısıyla uygulamadaki Kp değeri) o kadar şiddetli olur.'
  ],
  [
    'Manyetik Alan Dalgalanmaları ve Kritik "Bz" Parametresi Nedir?',
    'Dünya\'nın manyetik alanı bizi güneş fırtınalarından koruyan koruyucu bir kalkandır. Güneş rüzgarı ile gelen manyetik alanın dikey yönüne Bz parametresi denir. Bu yön kuzeye doğru (Bz+) olduğunda, Dünya\'nın kalkanı ile aynı yönde olduğu için fırtına püskürtülür ve yer yüzünde neredeyse hiçbir hareketlilik (Kp) ölçülmez. Ancak Bz yönü güneye doğru (Bz-) döndüğünde, Dünya\'nın manyetik alanı ile zıt yönlü olarak "manyetik yeniden birleşme" yaşanır; kalkanımız aralanır, güneş enerjisi içeri sızar ve güçlü jeomanyetik fırtınalar tetiklenir.'
  ],
  [
    'Güneş Patlaması Sınıfları Nedir? (X, M, C Sınıfı Patlamalar Ne Anlama Gelir?)',
    'Güneş patlamaları, yaydıkları X-ışını yoğunluğuna göre harflerle sınıflandırılır: A, B, C, M ve X. Her harf bir öncekinin 10 katı gücü temsil eder:\n\n'
        '• X-Sınıfı (En Şiddetli): Dünya genelinde büyük radyo kesintilerine ve uzun süreli jeomanyetik fırtınalara yol açabilir.\n'
        '• M-Sınıfı (Orta Şiddetli): Kutup bölgelerinde kısa radyo kesintilerine ve küçük-orta jeomanyetik fırtınalara neden olabilir.\n'
        '• C-Sınıfı (Zayıf): Dünya üzerinde neredeyse hiç fark edilebilir bir etki yaratmaz.'
  ],
  [
    'Kp İndeksine Göre Fırtına Seviyeleri (G1 - G5 Skalası) Nelerdir?',
    'NOAA, jeomanyetik fırtınaların şiddetini Kp değerlerine göre G1\'den G5\'e kadar sınıflandırır:\n\n'
        '• Kp = 5: G1 (Küçük Fırtına) - Güç şebekelerinde hafif dalgalanmalar, kutup ışıkları (aurora) oluşumu.\n'
        '• Kp = 6: G2 (Orta Fırtına) - Yüksek enlem güç sistemlerinde voltaj alarmları, uydularda yön düzeltmeleri.\n'
        '• Kp = 7: G3 (Güçlü Fırtına) - Uydu navigasyonlarında ve düşük frekanslı radyo sinyallerinde aksamalar.\n'
        '• Kp = 8: G4 (Şiddetli Fırtına) - Güç kontrol sistemlerinde yaygın voltaj sorunları, orta enlemlerde kutup ışıkları.\n'
        '• Kp = 9 ve üzeri: G5 (Ekstrem Fırtına) - Elektrik şebekelerinde çökmeler, uydularda kalıcı hasarlar ve yoğun auroralar.'
  ],
  [
    'Güneş Lekeleri ve 11 Yıllık Solar Döngü Nedir?',
    'Güneş\'in manyetik aktivitesi sabit değildir; yaklaşık 11 yıllık periyotlarla yükselir ve alçalır. Bu periyoda Solar Döngü denir. Döngünün zirve noktasına "Solar Maksimum" denir ve bu dönemde Güneş yüzeyinde yoğun manyetik alanların oluşturduğu koyu renkli Güneş Lekeleri (Sunspots) çoğalır. Bu lekeler, güneş patlamalarının ve fırtınalarının birincil kaynağıdır. Döngü boyunca lekeler arttıkça Dünya\'ya çarpan fırtına sayısı ve dolayısıyla Kp dalgalanmaları da en yüksek seviyeye ulaşır.'
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
