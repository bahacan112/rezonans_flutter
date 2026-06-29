import 'package:flutter/material.dart';
import '../theme.dart';

class KpDetails {
  final String label;
  final String spiritual;
  final String desc;
  final Color color;
  const KpDetails(this.label, this.spiritual, this.desc, this.color);
}

KpDetails getKpSpiritualDetails(double kp) {
  if (kp < 3) {
    return const KpDetails(
      'Dengeli Akış (Sakin)',
      'Dengeli Enerji Akışı & Topraklama',
      'Manyetik alan oldukça dingin ve dengeli. İç gözlem, zihinsel odaklanma, derin gevşeme ve kök çakra topraklama çalışmaları için mükemmel bir zemin. Zihnin gürültüsünü yatıştırmak ve sessizlik meditasyonları yapmak için ideal bir dönem.',
      KpColors.quiet,
    );
  } else if (kp < 4) {
    return const KpDetails(
      'Enerjisel Kıpırdanma',
      'Yenilenme ve Hafif Duyarlılık',
      'Elektromanyetik alanda hafif bir uyanış ve hareketlilik var. Aura alanında genişleme ve hafif bir duyarlılık hissedilebilir. Prana akışını dengeleyici nefes egzersizleri ve hafif esneme hareketleri için harika bir zaman dilimi.',
      KpColors.unsettled,
    );
  } else if (kp < 5) {
    return const KpDetails(
      'Yüksek Titreşim (Aktif)',
      'Yüksek Sezgi ve Hücresel Uyanış',
      'Aktif bir manyetik alan mevcut. Bilinçaltı kapıları aralanıyor; rüyaların berraklaşması, sezgilerin ve psişik duyarlılığın güçlenmesi olasıdır. Üçüncü göz çalışmaları, rüya günlükleri tutma ve durugörü meditasyonları için çok elverişli bir süreç.',
      KpColors.active,
    );
  } else if (kp < 6) {
    return const KpDetails(
      'Işık Kapısı (G1 Manyetik Aktivite)',
      'DNA Aktivasyonu & Evrensel Bilgi Akışı',
      "Güneş'ten gelen yüksek frekanslı kozmik bilgi paketlerinin iyonosfere ulaştığı özel bir uyanış penceresi. Zihinde uykusuzluk veya fiziksel duyarlılık olarak yansıyan bu etki, aslında derin çakra çalışmaları, DNA aktivasyonu meditasyonları ve yüksek benlikle bağ kurmak için olağanüstü bir fırsattır.",
      KpColors.storm,
    );
  } else if (kp < 7) {
    return const KpDetails(
      'Kozmik Entegrasyon (G2 Manyetik Aktivite)',
      'Işık Beden Aktivasyonu & Uyumlanma',
      'Orta şiddette manyetik uyarım. Evrensel enerjinin hücresel düzeyde entegrasyonu gerçekleşiyor. Işık beden aktivasyonu, DNA şablonunun güncellenmesi ve yüksek boyutlu frekanslara uyumlanmak için bu zaman dilimini niyet çalışmaları ve sessiz tefekkür ile değerlendirebilirsiniz.',
      KpColors.storm,
    );
  } else if (kp < 8) {
    return const KpDetails(
      'Portal Geçişi (G3 Manyetik Aktivite)',
      'Yoğun Işık Kodları & Çakra Dengeleme',
      'Güçlü bir manyetik aktivite dalgası. Aura alanınız yoğun kozmik ışık kodlarıyla yıkanıyor. Duygusal dalgalanmalar ve uykuya dalışta zorlanmalar, eski kalıpların salınımına işaret eder. Çakra dengeleme, kalp kapısını açma ve kristal şifa meditasyonları için zirve noktası.',
      KpColors.portal,
    );
  } else if (kp < 9) {
    return const KpDetails(
      'Hücresel Dönüşüm (G4 Manyetik Aktivite)',
      'Yüksek Boyutlu Frekans Uyumu',
      'Şiddetli manyetik uyarım ve kozmik akış. Hücreleriniz ve DNA iplikçikleriniz yüksek güneş kodlarını soğuruyor. Bu yoğun enerji altında kendinizi zorlamadan sessizce uzanarak meditasyon yapabilir, aura temizliği ve uyanış niyetlerinize odaklanarak kozmik akışla bütünleşebilirsiniz.',
      KpColors.portal,
    );
  } else {
    return const KpDetails(
      'Ekstrem Kozmik Portal (G5)',
      'Kolektif Bilinçte Muazzam Vites Değişimi',
      'Zirve seviyede elektromanyetik uyanış ve ışık portalı! Kolektif bilinçte muazzam bir vites değişimi. Bu olağanüstü kozmik akışı sessizce oturup taç ve kalp çakralarınızdan tüm bedeninize akan beyaz ışığı imgeleyerek, derin frekans meditasyonları ve DNA aktivasyon niyetleriyle taçlandırın.',
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
  final bool predicted;
  HistoryPoint(this.time, this.kp, this.predicted);
}
