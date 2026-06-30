import 'package:flutter/material.dart';
import '../models/kp.dart';
import '../theme.dart';

class Spectrogram extends StatefulWidget {
  final List<HistoryPoint> history;
  const Spectrogram({super.key, required this.history});

  @override
  State<Spectrogram> createState() => _SpectrogramState();
}

class _SpectrogramState extends State<Spectrogram> {
  late String _imageUrl;
  bool _loading = true;
  bool _error = false;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _updateUrl();
  }

  void _updateUrl() {
    setState(() {
      _loading = true;
      _error = false;
      // Append a timestamp to bypass network/CDN caches and get the fresh image
      _imageUrl = 'http://sos70.tsu.ru/new/shm.png?t=${DateTime.now().millisecondsSinceEpoch}_$_refreshCounter';
    });
  }

  void _forceRefresh() {
    _refreshCounter++;
    _updateUrl();
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Schumann Spektrogramı (SOS70)',
              style: AppText.sans(size: 14, weight: FontWeight.w700, color: AppColors.primaryGold),
            ),
            iconTheme: const IconThemeData(color: AppColors.primaryGold),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  Navigator.of(context).pop();
                  _forceRefresh();
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                _imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Resim yüklenemedi.\nLütfen internet bağlantınızı kontrol edin.',
                      textAlign: TextAlign.center,
                      style: AppText.sans(size: 12, color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schumann Rezonans Spektrogramı',
                      style: AppText.sans(size: 14, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Atmosferik boşlukta rezonans frekanslarının uyarılma şiddeti',
                      style: AppText.sans(size: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryGold, size: 20),
                onPressed: _forceRefresh,
                tooltip: 'Grafiği Yenile',
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openFullscreen(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160,
                width: double.infinity,
                color: const Color(0xFF07070F),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      _imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          // Image loaded successfully
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _loading) {
                              setState(() => _loading = false);
                            }
                          });
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryGold),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && !_error) {
                            setState(() {
                              _error = true;
                              _loading = false;
                            });
                          }
                        });
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, color: Colors.white24, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Gözlem verisi şu an alınamıyor.\n(Tomsk İstasyonu sunucusu yanıt vermiyor olabilir)',
                                  textAlign: TextAlign.center,
                                  style: AppText.sans(size: 10, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _forceRefresh,
                                  icon: const Icon(Icons.replay, size: 14),
                                  label: const Text('Tekrar Dene'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                                    foregroundColor: AppColors.primaryGold,
                                    textStyle: AppText.sans(size: 10, weight: FontWeight.w700),
                                    side: const BorderSide(color: AppColors.borderGold),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (!_loading && !_error)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.zoom_in, color: AppColors.primaryGold, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Büyütmek için dokunun',
                                style: AppText.sans(size: 8, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kaynak: Tomsk State University (SOS70)',
                style: AppText.sans(size: 9, color: AppColors.textMuted).copyWith(fontStyle: FontStyle.italic),
              ),
              Text(
                'Güncelleme: ${formatTime(DateTime.now())}',
                style: AppText.sans(size: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
