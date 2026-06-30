import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/client.dart';
import '../api/noaa.dart';
import '../auth/auth_provider.dart';
import '../models/kp.dart';
import '../theme.dart';
import '../widgets/analysis_guide.dart';
import '../widgets/notification_card.dart';
import '../widgets/simulator.dart';
import '../widgets/spectrogram.dart';
import '../widgets/starfield.dart';
import '../widgets/status_card.dart';
import '../widgets/trend_chart.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  SchumannData? data;
  bool loading = true;
  bool simulating = false;
  double simKp = 0;
  List<int> prefs = [1, 2, 3];
  int unread = 0;
  List<NotificationItem> notifications = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _load());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
      _loadPrefs();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? get _token => context.read<AuthProvider>().token;

  Future<void> _load() async {
    final d = await fetchSchumannData();
    if (mounted) setState(() {
      data = d;
      loading = false;
    });
  }

  Future<void> _loadNotifications() async {
    final t = _token;
    if (t == null) return;
    try {
      final r = await api.notifications(t);
      if (mounted) setState(() {
        notifications = r.items;
        unread = r.unread;
      });
    } catch (_) {}
  }

  Future<void> _loadPrefs() async {
    final t = _token;
    if (t == null) return;
    try {
      final b = await api.getPrefs(t);
      if (mounted) setState(() => prefs = b);
    } catch (_) {}
  }

  void _togglePref(int band) {
    final next = prefs.contains(band)
        ? (prefs.where((b) => b != band).toList())
        : ([...prefs, band]..sort());
    setState(() => prefs = next);
    final t = _token;
    if (t != null) api.setPrefs(t, next).catchError((_) => next);
  }

  double get activeKp => simulating ? simKp : (data?.currentKp ?? 0);

  List<HistoryPoint> get history {
    final base = data?.history ?? [];
    if (!simulating) return base;
    return [
      for (int i = 0; i < base.length; i++)
        i == 15 ? HistoryPoint(base[i].time, simKp, base[i].predicted) : base[i]
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isPremium = user?.isPremium ?? false;
    final glow = getKpSpiritualDetails(activeKp).color;

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(child: Starfield(glowColor: glow)),
        SafeArea(
          child: Column(children: [
            _header(),
            Expanded(
              child: loading && data == null
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _load();
                        await _loadNotifications();
                      },
                      color: AppColors.primaryGold,
                      backgroundColor: AppColors.bgDark,
                      child: ListView(
                        padding: const EdgeInsets.all(15),
                        children: [
                          _accountCard(user),
                          const SizedBox(height: 15),
                          AnalysisCard(
                            title: 'Schumann Kozmik Enerji Analizi',
                            spiritual: getKpSpiritualDetails(activeKp).spiritual,
                            text: getKpSpiritualDetails(activeKp).desc,
                          ),
                          const SizedBox(height: 15),
                          Simulator(
                            simulating: simulating,
                            value: simKp,
                            onChanged: (v) => setState(() {
                              simulating = true;
                              simKp = v;
                            }),
                            onReset: () => setState(() {
                              simulating = false;
                              simKp = 0;
                            }),
                          ),
                          const SizedBox(height: 15),
                          StatusCard(
                              kp: activeKp,
                              updatedLabel: data != null ? formatTime(data!.updatedAt) : '--:--'),
                          const SizedBox(height: 15),
                          Spectrogram(history: history),
                          const SizedBox(height: 15),
                          TrendChart(history: history),
                          const SizedBox(height: 15),
                          NotificationCard(
                            isPremium: isPremium,
                            prefs: prefs,
                            onTogglePref: _togglePref,
                            onUnlock: _showPremium,
                          ),
                          const SizedBox(height: 15),
                          const GuideAccordion(),
                          const SizedBox(height: 24),
                          Center(
                            child: Text('Schumann Kozmik Portal © 2026',
                                style: AppText.sans(size: 11, color: Colors.white24)),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Text('v1.0.0 Flutter',
                                style: AppText.mono(size: 10, color: Colors.white12)),
                          ),
                        ],
                      ),
                    ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
        decoration: const BoxDecoration(
          color: Color(0xCC0A0A0F),
          border: Border(bottom: BorderSide(color: AppColors.borderGold)),
        ),
        child: Row(children: [
          _headerBtn(
            Stack(clipBehavior: Clip.none, children: [
              const Center(child: Text('🔔', style: TextStyle(fontSize: 16))),
              if (unread > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: KpColors.storm,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF0A0A0F), width: 1.5),
                    ),
                    child: Text(unread > 9 ? '9+' : '$unread',
                        style: AppText.sans(size: 9, weight: FontWeight.w800)),
                  ),
                ),
            ]),
            _showNotifications,
          ),
          Expanded(
            child: Column(children: [
              Text('SCHUMANN REZONANSI',
                  style: AppText.sans(size: 15, weight: FontWeight.w800, color: AppColors.primaryGold, letterSpacing: 0.5)),
              Text('Canlı Jeomanyetik Kp ve Kozmik Akış',
                  style: AppText.sans(size: 12, color: AppColors.textMuted)),
            ]),
          ),
          _headerBtn(const Center(child: Icon(Icons.refresh, color: AppColors.primaryGold, size: 20)), _load),
        ]),
      );

  Widget _headerBtn(Widget child, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGold),
          ),
          child: child,
        ),
      );

  Widget _accountCard(AuthUser? user) {
    final initial = (user?.name ?? user?.email ?? '?').characters.first.toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGold),
          ),
          child: Text(initial, style: AppText.sans(size: 16, weight: FontWeight.w800, color: AppColors.primaryGold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user?.name ?? 'Kozmik Yolcu', style: AppText.sans(size: 15, weight: FontWeight.w700), maxLines: 1),
            Text('${user?.email ?? ''}${(user?.isPremium ?? false) ? '  ·  ⭐ Premium' : ''}',
                style: AppText.sans(size: 12, color: AppColors.textMuted), maxLines: 1),
          ]),
        ),
        GestureDetector(
          onTap: () => context.read<AuthProvider>().signOut(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text('Çıkış', style: AppText.sans(size: 12, weight: FontWeight.w600, color: AppColors.textMuted)),
          ),
        ),
      ]),
    );
  }

  void _showNotifications() async {
    await _loadNotifications();
    final t = _token;
    if (t != null) api.markNotificationsRead(t).catchError((_) {});
    setState(() => unread = 0);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0B16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _NotificationsSheet(items: notifications),
    );
  }

  void _showPremium() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0B16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _PremiumSheet(onUpgrade: () async {
        await context.read<AuthProvider>().upgradePremium();
        if (ctx.mounted) Navigator.pop(ctx);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Ödeme başarılı! Premium üyeliğiniz aktif edildi.')));
        }
      }),
    );
  }
}

Color _bandColor(int band) =>
    band >= 2 ? (band >= 3 ? KpColors.portal : KpColors.storm) : KpColors.quiet;

class _NotificationsSheet extends StatelessWidget {
  final List<NotificationItem> items;
  const _NotificationsSheet({required this.items});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Bildirimler', style: AppText.sans(size: 16, weight: FontWeight.w800)),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textMuted)),
        ]),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(children: [
              const Text('🔔', style: TextStyle(fontSize: 34)),
              const SizedBox(height: 8),
              Text('Henüz bildirim yok.', style: AppText.sans(size: 14, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Jeomanyetik fırtına başladığında burada görünecek.',
                  textAlign: TextAlign.center, style: AppText.sans(size: 11, color: AppColors.textMuted)),
            ]),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final n = items[i];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                        margin: const EdgeInsets.only(top: 5, right: 12),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: _bandColor(n.band), shape: BoxShape.circle)),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: AppText.sans(size: 13, weight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(n.body, style: AppText.sans(size: 11, color: AppColors.textMuted, height: 1.4)),
                        const SizedBox(height: 5),
                        Text(
                            formatTime(DateTime.fromMillisecondsSinceEpoch(n.createdAt)),
                            style: AppText.mono(size: 9, color: Colors.white24)),
                      ]),
                    ),
                  ]),
                );
              },
            ),
          ),
      ]),
    );
  }
}

class _PremiumSheet extends StatelessWidget {
  final Future<void> Function() onUpgrade;
  const _PremiumSheet({required this.onUpgrade});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        const SizedBox(height: 4),
        Text('Evrensel Enerji Akışını Anlık Takip Edin',
            style: AppText.sans(size: 11, color: AppColors.textMuted)),
        const SizedBox(height: 20),
        for (final f in const [
          ['Anlık Fırtına Uyarısı', 'Kp endeksi 5\'i geçtiğinde anlık bildirim gelir.'],
          ['Gelişmiş Hücresel Analiz', 'Hücresel uyanış ve DNA portal geçişlerine dair tavsiyeler.'],
          ['Reklamsız Deneyim', 'Frekansları hiçbir reklam bölünmesi olmadan izleyin.'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('✓', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f[0], style: AppText.sans(size: 12, weight: FontWeight.w700)),
                  Text(f[1], style: AppText.sans(size: 10, color: AppColors.textMuted, height: 1.4)),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Şimdi Premium\'a Geç  ₺399.99/yıl',
                style: AppText.sans(size: 13, weight: FontWeight.w800, color: Colors.black)),
          ),
        ),
      ]),
    );
  }
}
