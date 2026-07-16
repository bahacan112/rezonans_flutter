import 'package:flutter/material.dart';
import '../theme.dart';

class KpDetails {
  final String label;
  final String spiritual;
  final String scientific;
  final String physical;
  final String spiritualGuidance;
  final Color color;
  const KpDetails(this.label, this.spiritual, this.scientific, this.physical, this.spiritualGuidance, this.color);
}

KpDetails getKpSpiritualDetails(double kp) {
  if (kp < 3) {
    return const KpDetails(
      'Dengeli Akış (Sakin)',
      'Dengeli Enerji Akışı & Topraklama',
      'Manyetik alan oldukça dingin ve dengeli. Dünya\'nın koruyucu kalkanı stabil durumda, plazma akışı normal seviyelerde seyrediyor.',
      'Sakin bir sinir sistemi, dengeli kalp ritmi, derin ve dinlendirici uyku. Fiziksel bedende güçlü bir topraklanma hissi.',
      'Kök çakra meditasyonları için mükemmel bir zaman. Zihnin gürültüsünü yatıştırmak, sessizlikte kalmak ve adaçayı yakarak alanınızı arındırmak için idealdir.',
      KpColors.quiet,
    );
  } else if (kp < 4) {
    return const KpDetails(
      'Enerjisel Kıpırdanma',
      'Yenilenme ve Hafif Duyarlılık',
      'Güneş rüzgarında hafif bir hızlanma ve manyetik alanda küçük ölçekli dalgalanma başlangıcı mevcut.',
      'Hafif esneme ihtiyacı, rüyalarda sembollerin canlanması ve aura sınırlarında ince bir duyarlılık artışı.',
      'Prana akışını dengelemek için nefes egzersizleri yapın. Kristal kuvars veya ametist taşları ile aura alanınızı güçlendirebilirsiniz.',
      KpColors.unsettled,
    );
  } else if (kp < 5) {
    return const KpDetails(
      'Yüksek Titreşim (Aktif)',
      'Yüksek Sezgi ve Hücresel Uyanış',
      'Jeomanyetik alan aktif durumda. Güneş\'ten gelen yüklü parçacıklar manyetosfer sınırlarını uyararak iyonosferde hareketlilik yaratıyor.',
      'Başın arka kısmında hafif bir basınç, duygusal hassasiyet ve başkalarının enerjilerini hissetme (empati) yeteneğinde artış.',
      'Üçüncü göz ve taç çakra çalışmaları için çok uygundur. Enerjisel sınırlarınızı korumak için kendinizi mavi bir ışık küresi içinde imgeleyin.',
      KpColors.active,
    );
  } else if (kp < 6) {
    return const KpDetails(
      'Işık Kapısı (G1)',
      'DNA Aktivasyonu & Evrensel Bilgi Akışı',
      'G1 seviyesinde jeomanyetik fırtına. Manyetik kalkanın güney yönlü (Bz-) aralanması sonucu güneş rüzgarı parçacıkları iyonosfere sızmaya başladı.',
      'Uykuya geçişte zorlanma, hafif şakak ağrıları, kulaklarda yüksek frekanslı çınlama sesleri ve ani vücut sıcaklığı değişimleri.',
      'Yoğun ışık kodlarının hücresel entegrasyonu başlar. Bol su tüketin. Alanınızı arındırmak için üzerlik otu veya adaçayı tütsüsü yapın.',
      KpColors.storm,
    );
  } else if (kp < 7) {
    return const KpDetails(
      'Kozmik Entegrasyon (G2)',
      'Işık Beden Aktivasyonu & Uyumlanma',
      'G2 seviyesinde orta şiddetli jeomanyetik fırtına. İyonosfer katmanında belirgin bir alçalma ve elektrik iletkenliğinde yoğunlaşma ölçülüyor.',
      'Kalp çakrasında uyarılma (çarpıntı hissi), eklem ağrıları ve gün içinde ani esneme veya yorgunluk dalgaları.',
      'Işık beden aktivasyon süreci. Ağır yiyeceklerden kaçının, tuzlu su banyosu ile aurik alanınızı temizleyip dinlenmeye özen gösterin.',
      KpColors.storm,
    );
  } else if (kp < 8) {
    return const KpDetails(
      'Portal Geçişi (G3)',
      'Yoğun Işık Kodları & Çakra Dengeleme',
      'G3 seviyesinde güçlü jeomanyetik fırtına. Kutup ışıkları (aurora) alt enlemlere iniyor. Manyetik kalkan büyük ölçüde geçirgenleşti.',
      'Yoğun uykusuzluk, astral seyahat deneyimleri, sinir sisteminde aşırı elektriklenme hissi, derin rüyalar ve vizyonlar.',
      'Büyük bir kozmik kapı açıldı. Eski duygusal yükleri ve karmik bağları kesmek için niyet çalışmaları yapın. Selenit taşı ile topraklanın.',
      KpColors.portal,
    );
  } else if (kp < 9) {
    return const KpDetails(
      'Hücresel Dönüşüm (G4)',
      'Yüksek Boyutlu Frekans Uyumu',
      'G4 seviyesinde çok şiddetli jeomanyetik fırtına. Dünya genelinde elektrik şebekelerinde voltaj düzensizlikleri ve yoğun jeomanyetik akış.',
      'Aşırı duyarlı duyular (ışık ve sese hassasiyet), baş dönmesi, vücutta karıncalanma ve epifiz bezinde yoğun uyarılma.',
      'Hücresel düzeyde derin bir DNA güncellemesi. Fiziksel bedeni zorlamayın. Toprağa basarak veya tuzlu suyla topraklanmayı sağlayın.',
      KpColors.portal,
    );
  } else {
    return const KpDetails(
      'Ekstrem Kozmik Portal (G5)',
      'Kolektif Bilinçte Muazzam Vites Değişimi',
      'G5 seviyesinde ekstrem jeomanyetik fırtına. Manyetik kalkanda tam geçirgenlik durumu ve iyonosferde maksimum düzeyde uyarılma.',
      'Zamansızlık hissi, uyku düzeninin tamamen bozulması, yüksek zihinsel uyanıklık ile fiziksel yorgunluğun bir arada yaşanması.',
      'Kolektif bilinçte boyutsal geçiş ve vites değişimi. Taç çakranızdan bedeninize beyaz bir ışık sütununun indiğini imgeleyerek meditasyon yapın.',
      KpColors.extreme,
    );
  }
}

const _dayNames = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];
String _pad(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime d) =>
    '${_dayNames[d.weekday % 7]} ${_pad(d.hour)}:${_pad(d.minute)}';

class HistoryPoint {
  final DateTime time;
  final double kp;
  final double schumann;
  final bool predicted;
  HistoryPoint(this.time, this.kp, this.predicted, {double? schumann})
      : schumann = schumann ?? kp;
}
