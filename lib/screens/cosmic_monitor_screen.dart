import 'package:flutter/material.dart';
import '../theme.dart';

class CosmicMonitorScreen extends StatefulWidget {
  const CosmicMonitorScreen({super.key});

  @override
  State<CosmicMonitorScreen> createState() => _CosmicMonitorScreenState();
}

class _CosmicMonitorScreenState extends State<CosmicMonitorScreen> {
  final String _sdoUrl = 'https://sdo.gsfc.nasa.gov/assets/img/latest/latest_512_0193.jpg';
  bool _refreshingImage = false;
  late ImageProvider _sunImageProvider;

  @override
  void initState() {
    super.initState();
    _sunImageProvider = NetworkImage('$_sdoUrl?t=${DateTime.now().millisecondsSinceEpoch}');
  }

  void _refreshSunImage() {
    setState(() {
      _refreshingImage = true;
      _sunImageProvider = NetworkImage('$_sdoUrl?t=${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSpace,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KOZMİK GÖZLEM & TAKVİM',
                  style: AppText.sans(size: 22, weight: FontWeight.w800, color: AppColors.primaryGold)),
              Text('Canlı güneş etkinliği ve kozmik transit uyumu',
                  style: AppText.sans(size: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),

              // 1. Live Sun Monitor AIA 193
              _buildSectionCard(
                title: 'Canlı Güneş Monitörü (NASA SDO AIA 193 Å)',
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image(
                            image: _sunImageProvider,
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                if (_refreshingImage) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    setState(() => _refreshingImage = false);
                                  });
                                }
                                return child;
                              }
                              return Container(
                                height: 250,
                                color: Colors.black26,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.wifi_off, color: Colors.white24, size: 40),
                                      const SizedBox(height: 8),
                                      Text('NASA SDO yayını yüklenemedi.', style: AppText.sans(size: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _refreshSunImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.borderGold),
                              ),
                              child: _refreshingImage
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold))
                                  : const Icon(Icons.refresh, color: AppColors.primaryGold, size: 16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AIA 193: Koronal Delikler & Rüzgarlar',
                              style: AppText.sans(size: 10, color: AppColors.primaryGold, weight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NASA Güneş Dinamikleri Gözlemevi (SDO) tarafından 193 Angstrom dalga boyunda çekilen en güncel ultraviyole fotoğrafı. Bu dalga boyundaki karanlık alanlar (koronal delikler), Dünya\'ya doğru esen hızlı güneş rüzgarlarının ve jeomanyetik fırtınaların ana kaynağıdır.',
                      style: AppText.sans(size: 12, color: AppColors.textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Solar Flare Advisories (Güneş Patlaması)
              _buildSectionCard(
                title: 'Güneş Patlaması Bildirimleri (Flare Alert)',
                child: Column(
                  children: [
                    _buildAlertTile(
                      type: 'M-Sınıfı (Orta Şiddet)',
                      desc: 'Bugün saat 08:24 UTC civarında güneşin AR3546 bölgesinde M2.4 şiddetinde bir patlama gözlendi. İyonosferde kısa süreli radyo kesintilerine sebep oldu.',
                      dateStr: 'Bugün 08:24',
                      color: KpColors.active,
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    _buildAlertTile(
                      type: 'X-Sınıfı (Şiddetli Patlama)',
                      desc: '2 gün önce AR3540 bölgesinde X1.1 büyüklüğünde yüksek enerjili plazma fışkırması gerçekleşti. Bu plazma bulutunun (CME) bu gece yarısı Dünya manyetosferine ulaşarak Kp 6-7 fırtınası tetiklemesi bekleniyor.',
                      dateStr: '2 gün önce',
                      color: KpColors.storm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Astrological Sync
              _buildSectionCard(
                title: 'Astroloji & Kozmik Takvim (Astrological Sync)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌕', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Yaklaşan Dolunay: Kova Burcunda (21 Temmuz)', style: AppText.sans(size: 14, weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Enerjisel temizlik ve kolektif uyanışın doruk noktası.', style: AppText.sans(size: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Jeomanyetik fırtınaların ve iyonosferik uyarılmanın (Schumann) Dolunay ve Yeniay fazlarında biyolojik düzeyde daha yoğun hissedildiği bilinmektedir. Kova burcundaki bu dolunay, elektrik sistemimiz ve sinir uçlarımız üzerinde ekstra duyarlılık yaratabilir.',
                      style: AppText.sans(size: 12, color: AppColors.textMuted, height: 1.4),
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      children: [
                        const Text('🪐', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Merkür Retrosu Başlıyor', style: AppText.sans(size: 14, weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Zihinsel odak dağılması ve iletişim tıkanıklıkları.', style: AppText.sans(size: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Elektromanyetik alandaki dalgalanmalar, Merkür retrosunun getirdiği zihinsel yavaşlama, unutkanlık ve koordinasyon güçlüğü etkilerini ikiye katlayabilir. Bu dönemde elektronik cihaz kullanımlarında sakin kalmak ve kararları aceleye getirmemek faydalıdır.',
                      style: AppText.sans(size: 12, color: AppColors.textMuted, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.sans(size: 16, weight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAlertTile({required String type, required String desc, required String dateStr, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              type,
              style: AppText.sans(size: 10, color: color, weight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: AppText.sans(size: 12, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: AppText.mono(size: 9, color: Colors.white24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
