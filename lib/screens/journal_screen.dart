import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/client.dart';
import '../auth/auth_provider.dart';
import '../theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _loading = true;
  bool _saving = false;
  double _moodScore = 5.0;
  final TextEditingController _notesController = TextEditingController();
  final Map<String, bool> _selectedSymptoms = {};
  UserProfile? _profile;
  CorrelationReport? _correlationReport;
  String? _correlationError;
  bool _loadingCorrelation = false;

  final List<Map<String, dynamic>> _symptomDefs = const [
    // Fiziksel
    {'slug': 'bas_agrisi', 'label': 'Baş Ağrısı', 'category': 'Fiziksel'},
    {'slug': 'kulak_cinlamasi', 'label': 'Kulak Çınlaması / Frekans Sesleri', 'category': 'Fiziksel'},
    {'slug': 'eklem_kas_agrisi', 'label': 'Eklem ve Kas Ağrıları', 'category': 'Fiziksel'},
    {'slug': 'sersemlik', 'label': 'Sersemlik / Baş Dönmesi', 'category': 'Fiziksel'},
    {'slug': 'kalp_carpintisi', 'label': 'Kalp Çarpıntısı / Hızlı Atış', 'category': 'Fiziksel'},
    {'slug': 'bas_ense_basinci', 'label': 'Baş ve Ense Bölgesinde Basınç', 'category': 'Fiziksel'},
    // Uyku
    {'slug': 'uykusuzluk', 'label': 'Uykusuzluk / İnsomnia', 'category': 'Uyku & Rüya'},
    {'slug': 'canli_ruyalar', 'label': 'Canlı / Rehber Rüyalar', 'category': 'Uyku & Rüya'},
    {'slug': 'uykudan_uyanma', 'label': 'Uykudan Sık Uyanma', 'category': 'Uyku & Rüya'},
    {'slug': 'yorgun_uyanma', 'label': 'Sabah Çok Yorgun Uyanma', 'category': 'Uyku & Rüya'},
    // Zihinsel
    {'slug': 'beyin_sisi', 'label': 'Beyin Sisi / Odaklanma Güçlüğü', 'category': 'Zihinsel'},
    {'slug': 'unutkanlik', 'label': 'Unutkanlık', 'category': 'Zihinsel'},
    {'slug': 'zihinsel_netlik', 'label': 'Zihinsel Netlik / Yüksek Odak', 'category': 'Zihinsel', 'positive': true},
    // Duygusal
    {'slug': 'huzursuzluk', 'label': 'Anksiyete / Huzursuzluk', 'category': 'Duygusal'},
    {'slug': 'sinirlilik', 'label': 'Sinirlilik / Öfke Patlaması', 'category': 'Duygusal'},
    {'slug': 'icsel_dinginlik', 'label': 'İçsel Dinginlik / Huzur', 'category': 'Duygusal', 'positive': true},
    // Enerji
    {'slug': 'halsizlik', 'label': 'Halsizlik / Yorgunluk', 'category': 'Enerji'},
    {'slug': 'enerji_patlamasi', 'label': 'Ani Enerji Patlaması', 'category': 'Enerji'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadTodayData() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _loading = true);

    try {
      // Load user profile to know their default home location
      _profile = await api.getProfile(token);
      
      // Load today's journal entry if exists
      final todayStr = _getTodayString();
      final journal = await api.getJournal(token, todayStr);
      
      if (journal != null) {
        _moodScore = (journal.moodScore ?? 5).toDouble();
        _notesController.text = journal.notes ?? '';
        for (final sym in journal.symptoms.entries) {
          _selectedSymptoms[sym.key] = sym.value;
        }
      }

      // Load correlation analysis if premium
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user?.isPremium == true) {
        await _loadCorrelation();
      }
    } catch (_) {
      // Silently handle or fallback
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCorrelation() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    setState(() {
      _loadingCorrelation = true;
      _correlationError = null;
    });
    try {
      final rep = await api.getCorrelationAnalysis(token);
      setState(() => _correlationReport = rep);
    } catch (e) {
      setState(() => _correlationError = 'Korelasyon analizi alınamadı. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setState(() => _loadingCorrelation = false);
    }
  }

  Future<void> _saveTodayJournal() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _saving = true);
    final todayStr = _getTodayString();

    try {
      // 1. Save journal
      await api.saveJournal(
        token,
        date: todayStr,
        moodScore: _moodScore.round(),
        symptoms: _selectedSymptoms,
        notes: _notesController.text,
        city: _profile?.homeCity ?? 'İstanbul',
        countryCode: _profile?.homeCountry ?? 'TR',
        cityLatitude: 41.0082, // defaults
        cityLongitude: 28.9784,
      );

      // 2. Also trigger a live consciousness signal if symptoms are checked
      final activeSymptoms = _selectedSymptoms.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      if (activeSymptoms.isNotEmpty) {
        await api.sendSignal(
          token: token,
          city: _profile?.homeCity ?? 'İstanbul',
          countryCode: _profile?.homeCountry ?? 'TR',
          cityLatitude: 41.0082,
          cityLongitude: 28.9784,
          symptoms: activeSymptoms,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bugünkü durumunuz başarıyla kozmik veri tabanına kaydedildi!')),
        );
      }

      // Refresh correlation report if premium
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user?.isPremium == true) {
        await _loadCorrelation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isPremium = auth.user?.isPremium ?? false;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bgSpace,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    // Group symptoms by category
    final categories = <String, List<Map<String, dynamic>>>{};
    for (final def in _symptomDefs) {
      final cat = def['category'] as String;
      categories.putIfAbsent(cat, () => []).add(def);
    }

    return Scaffold(
      backgroundColor: AppColors.bgSpace,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KOZMİK GÜNLÜK',
                  style: AppText.sans(size: 22, weight: FontWeight.w800, color: AppColors.primaryGold)),
              Text('Enerji dalgalanmalarının bedensel ve ruhsal etkilerini kaydedin',
                  style: AppText.sans(size: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),

              // 1. Mood Section
              _buildSectionCard(
                title: 'Ruh Hali & Enerji Seviyesi',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 - Çok Düşük / Bloke', style: AppText.sans(size: 12, color: Colors.white30)),
                        Text('${_moodScore.round()}/10', style: AppText.sans(size: 18, weight: FontWeight.w800, color: AppColors.primaryGold)),
                        Text('10 - Çok Yüksek / Uyanış', style: AppText.sans(size: 12, color: Colors.white30)),
                      ],
                    ),
                    Slider(
                      value: _moodScore,
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      activeColor: AppColors.primaryGold,
                      inactiveColor: Colors.white12,
                      onChanged: (v) => setState(() => _moodScore = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Predefined Symptoms Sections
              _buildSectionCard(
                title: 'Bugün Hissedilen Belirtiler',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final cat in categories.keys) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Text(cat, style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.primaryGold.withValues(alpha: 0.8))),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final def in categories[cat]!) ...[
                            ChoiceChip(
                              label: Text(def['label'] as String, style: AppText.sans(size: 12, weight: _selectedSymptoms[def['slug']] == true ? FontWeight.w700 : FontWeight.w400)),
                              selected: _selectedSymptoms[def['slug']] == true,
                              selectedColor: def['positive'] == true ? KpColors.quiet.withValues(alpha: 0.3) : AppColors.primaryGold.withValues(alpha: 0.25),
                              backgroundColor: Colors.white.withValues(alpha: 0.03),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: _selectedSymptoms[def['slug']] == true
                                      ? (def['positive'] == true ? KpColors.quiet : AppColors.primaryGold)
                                      : AppColors.borderLight,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: _selectedSymptoms[def['slug']] == true
                                    ? (def['positive'] == true ? KpColors.quiet : AppColors.primaryGold)
                                    : AppColors.textMuted,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSymptoms[def['slug'] as String] = selected;
                                });
                              },
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 8),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Notes Section
              _buildSectionCard(
                title: 'Kişisel Günlük Notları (Özel)',
                child: TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: AppText.sans(size: 14),
                  decoration: InputDecoration(
                    hintText: 'Bugüne dair enerjisel hislerinizi, rüyalarınızı ve tecrübelerinizi yazın...',
                    hintStyle: AppText.sans(size: 13, color: AppColors.textMuted),
                    fillColor: Colors.white.withValues(alpha: 0.02),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderGold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveTodayJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text('Günlüğü Kaydet & Canlı Haritaya Sinyal Gönder',
                          style: AppText.sans(size: 14, weight: FontWeight.w800, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Premium Weekly Correlation Analysis
              Text('KOZMİK SAĞLIK RAPORU',
                  style: AppText.sans(size: 22, weight: FontWeight.w800, color: AppColors.primaryGold)),
              Text('Uzay havası fırtınaları ile biyolojinizin ilişkisini analiz edin',
                  style: AppText.sans(size: 13, color: AppColors.textMuted)),
              const SizedBox(height: 16),

              if (!isPremium)
                _buildPremiumTeaser()
              else if (_loadingCorrelation)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  ),
                )
              else if (_correlationError != null)
                Text(_correlationError!, style: AppText.sans(size: 14, color: KpColors.storm))
              else if (_correlationReport != null)
                _buildCorrelationReport(_correlationReport!)
              else
                Text('Henüz yeterli veri yok. Raporu görmek için en az 4-5 günlük durum kaydetmelisiniz.',
                    style: AppText.sans(size: 14, color: AppColors.textMuted)),

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

  Widget _buildPremiumTeaser() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x2A1C1605), Color(0x1F0B0B16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Center(child: Text('⭐', style: TextStyle(fontSize: 34))),
          const SizedBox(height: 8),
          Text('Kozmik Sağlık Raporunu Kilitleyin', style: AppText.sans(size: 16, weight: FontWeight.w800, color: AppColors.primaryGold)),
          const SizedBox(height: 8),
          Text(
            'Haftalık Kp Endeksi ve Schumann Rezonansı uyarılma düzeyleri ile girdiğiniz semptomları ve ruh halinizi matematiksel Pearson Korelasyonu ile analiz ediyoruz. Hangi kozmik dalgalardan ne kadar etkilendiğinizi keşfedin.',
            textAlign: TextAlign.center,
            style: AppText.sans(size: 12, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Open upgrade in main screen or prompt directly
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF0B0B16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                        ),
                        child: const Center(child: Text('⚡', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(height: 12),
                      Text('Kozmik Portal Premium', style: AppText.sans(size: 18, weight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Text(
                        'Premium üyeliği aktive ederek kişiselleştirilmiş korelasyon grafiklerine, fırtına eşik ayarlarına ve detaylı kozmik analize anında erişin.',
                        textAlign: TextAlign.center,
                        style: AppText.sans(size: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await context.read<AuthProvider>().upgradePremium();
                            if (ctx.mounted) Navigator.pop(ctx);
                            _loadTodayData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Şimdi Premium\'a Geç ₺399.99/yıl',
                              style: AppText.sans(size: 13, weight: FontWeight.w800, color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Premium\'a Yükselt', style: AppText.sans(size: 13, weight: FontWeight.w700, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationReport(CorrelationReport report) {
    return Column(
      children: [
        Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Korelasyon Analiz Sonuçları', style: AppText.sans(size: 15, weight: FontWeight.w800)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGold),
                    ),
                    child: Text('${report.daysAnalyzed} Gün Analiz Edildi', style: AppText.sans(size: 11, color: AppColors.primaryGold, weight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Dönem: ${report.from} / ${report.to}', style: AppText.sans(size: 12, color: AppColors.textMuted)),
              const Divider(color: Colors.white12, height: 24),
              
              _buildCorrelationRow('Ruh Hali & Jeomanyetik Kp', report.moodVsKp),
              const SizedBox(height: 12),
              _buildCorrelationRow('Ruh Hali & Schumann Enerjisi', report.moodVsSchumann),
              const SizedBox(height: 12),
              _buildCorrelationRow('Semptom Yoğunluğu & Jeomanyetik Kp', report.symptomCountVsKp),
              const SizedBox(height: 12),
              _buildCorrelationRow('Semptom Yoğunluğu & Schumann Enerjisi', report.symptomCountVsSchumann),

              const Divider(color: Colors.white12, height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ℹ️ ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      report.note,
                      style: AppText.sans(size: 11, color: AppColors.textMuted, height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationRow(String title, CorrelationValue val) {
    final r = val.r;
    Color indicatorColor = AppColors.textMuted;
    if (r != null) {
      if (r > 0.3) {
        indicatorColor = KpColors.active;
      } else if (r < -0.3) {
        indicatorColor = KpColors.portal;
      } else {
        indicatorColor = KpColors.quiet;
      }
    }

    final barWidth = r != null ? (r.abs() * 100).clamp(5.0, 100.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppText.sans(size: 13, weight: FontWeight.w700)),
            Text(
              r != null ? '${r > 0 ? "+" : ""}${r.toStringAsFixed(2)}' : 'Yetersiz Veri',
              style: AppText.mono(size: 13, weight: FontWeight.w800, color: indicatorColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    if (r != null && r < 0) ...[
                      const Spacer(),
                      Container(
                        width: barWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ] else if (r != null && r >= 0) ...[
                      Container(
                        width: barWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                    ] else
                      Container(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: Text(
                val.label,
                style: AppText.sans(size: 12, color: indicatorColor, weight: FontWeight.w700),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
