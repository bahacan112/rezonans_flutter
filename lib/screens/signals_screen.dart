import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../api/client.dart';
import '../auth/auth_provider.dart';
import '../theme.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  bool _loadingSignals = true;
  List<LiveSignal> _signals = [];
  String? _signalsError;

  // Premium City Search
  final TextEditingController _searchController = TextEditingController();
  bool _loadingCityDetails = false;
  CitySymptomDistribution? _cityDistribution;
  String? _cityError;

  final Map<String, String> _symptomTranslations = const {
    'bas_agrisi': 'Baş Ağrısı',
    'kulak_cinlamasi': 'Kulak Çınlaması / Frekans Sesleri',
    'eklem_kas_agrisi': 'Eklem ve Kas Ağrıları',
    'sersemlik': 'Sersemlik / Baş Dönmesi',
    'kalp_carpintisi': 'Kalp Çarpıntısı',
    'bas_ense_basinci': 'Baş ve Ense Basıncı',
    'uykusuzluk': 'Uykusuzluk',
    'canli_ruyalar': 'Canlı Rüyalar',
    'uykudan_uyanma': 'Uykudan Sık Uyanma',
    'yorgun_uyanma': 'Sabah Yorgun Uyanma',
    'beyin_sisi': 'Beyin Sisi / Odaklanma Güçlüğü',
    'unutkanlik': 'Unutkanlık',
    'zihinsel_netlik': 'Zihinsel Netlik',
    'huzursuzluk': 'Anksiyete / Huzursuzluk',
    'sinirlilik': 'Sinirlilik / Öfke Patlaması',
    'icsel_dinginlik': 'İçsel Dinginlik',
    'halsizlik': 'Halsizlik / Yorgunluk',
    'enerji_patlamasi': 'Enerji Patlaması',
  };

  @override
  void initState() {
    super.initState();
    _loadLiveSignals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveSignals() async {
    setState(() {
      _loadingSignals = true;
      _signalsError = null;
    });

    try {
      final list = await api.getLiveSignals(hours: 3);
      setState(() => _signals = list);
    } catch (e) {
      setState(() => _signalsError = 'Canlı sinyaller yüklenemedi. Lütfen tekrar deneyin.');
    } finally {
      setState(() => _loadingSignals = false);
    }
  }

  Future<void> _searchCity(String city) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || city.trim().isEmpty) return;

    setState(() {
      _loadingCityDetails = true;
      _cityError = null;
      _cityDistribution = null;
    });

    try {
      final dist = await api.getCitySignals(token, city.trim(), hours: 24);
      setState(() => _cityDistribution = dist);
    } catch (e) {
      setState(() => _cityError = 'Şehir analiz verisi alınamadı.');
    } finally {
      setState(() => _loadingCityDetails = false);
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return DateFormat('dd MMM, HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isPremium = auth.user?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgSpace,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadLiveSignals,
          color: AppColors.primaryGold,
          backgroundColor: AppColors.bgDark,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('KOLEKTİF BİLİNÇ',
                  style: AppText.sans(size: 22, weight: FontWeight.w800, color: AppColors.primaryGold)),
              Text('Dünya genelinde anlık olarak bildirilen enerjisel semptomlar',
                  style: AppText.sans(size: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),

              // 1. Premium City Search Section
              _buildCitySearchSection(isPremium),
              const SizedBox(height: 24),

              // 2. Live Signal Feed Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Canlı Aktivite Akışı (Son 3 Saat)',
                      style: AppText.sans(size: 16, weight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primaryGold, size: 20),
                    onPressed: _loadLiveSignals,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. Live Signal Feed Cards
              if (_loadingSignals)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  ),
                )
              else if (_signalsError != null)
                Center(
                  child: Text(_signalsError!, style: AppText.sans(size: 14, color: KpColors.storm)),
                )
              else if (_signals.isEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      const Text('📡', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text('Şu anda canlı sinyal yok.', style: AppText.sans(size: 14, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Bugünkü Kozmik Günlük kaydınızı girerek ilk sinyali siz bırakın!',
                          textAlign: TextAlign.center, style: AppText.sans(size: 11, color: AppColors.textMuted)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _signals.length,
                  itemBuilder: (ctx, idx) {
                    final sig = _signals[idx];
                    return _buildSignalCard(sig);
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalCard(LiveSignal sig) {
    final list = sig.symptoms.map((s) => _symptomTranslations[s] ?? s).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${sig.city}, ${sig.countryCode.toUpperCase()}',
                        style: AppText.sans(size: 14, weight: FontWeight.w700)),
                    Text(_formatTime(sig.feltAt),
                        style: AppText.sans(size: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Hissedilenler: $list',
                  style: AppText.sans(size: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySearchSection(bool isPremium) {
    if (!isPremium) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x1F0B0B16), Color(0x2A1C1605)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text('Şehir Bazlı Yoğunluk Analizi (Premium)', style: AppText.sans(size: 15, weight: FontWeight.w800, color: AppColors.primaryGold)),
            const SizedBox(height: 6),
            Text(
              'Herhangi bir şehri aratarak, son 24 saat içinde o şehirde yaşayan aktif kullanıcıların hangi semptomları ne oranda hissettiğini yüzde grafikleriyle inceleyin.',
              textAlign: TextAlign.center,
              style: AppText.sans(size: 12, color: AppColors.textMuted, height: 1.5),
            ),
          ],
        ),
      );
    }

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
          Text('Şehir Bazlı Semptom Dağılımı', style: AppText.sans(size: 15, weight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppText.sans(size: 14),
                  decoration: InputDecoration(
                    hintText: 'Şehir adı yazın (Örn: İstanbul)',
                    hintStyle: AppText.sans(size: 13, color: AppColors.textMuted),
                    fillColor: Colors.white.withValues(alpha: 0.02),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderGold),
                    ),
                  ),
                  onSubmitted: _searchCity,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _searchCity(_searchController.text),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: const Center(
                    child: Icon(Icons.search, color: AppColors.primaryGold, size: 20),
                  ),
                ),
              ),
            ],
          ),
          
          if (_loadingCityDetails)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
            ),

          if (_cityError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_cityError!, style: AppText.sans(size: 13, color: KpColors.storm)),
            ),

          if (_cityDistribution != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_cityDistribution!.city} Son 24 Saat Raporu', style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.primaryGold)),
                Text('${_cityDistribution!.total} Aktif Sinyal', style: AppText.sans(size: 12, color: AppColors.textMuted)),
              ],
            ),
            const Divider(color: Colors.white12, height: 16),
            if (_cityDistribution!.symptoms.isEmpty)
              Text('Son 24 saat içinde bu şehirde herhangi bir semptom bildirilmemiş.', style: AppText.sans(size: 12, color: AppColors.textMuted))
            else
              for (final sym in _cityDistribution!.symptoms) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_symptomTranslations[sym.slug] ?? sym.slug, style: AppText.sans(size: 12)),
                          Text('%${sym.percent} (${sym.count} kişi)', style: AppText.mono(size: 11, color: AppColors.primaryGold, weight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: sym.percent / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ],
      ),
    );
  }
}
