# rezonans_flutter

Schumann Rezonansı mobil uygulamasının **Flutter** sürümü.
NOAA jeomanyetik Kp verisini gösterir; üyelik/auth + premium + bildirim tercihleri için
[backend](https://github.com/bahacan112/renozans-schumman) (`https://renozans-backend.baha.tr`) ile konuşur.

## Gereksinimler
- Flutter 3.44+ (Dart 3.12+)
- Android Studio + Android SDK
- Bir Android cihaz / emülatör

## Çalıştırma
```bash
flutter pub get
flutter run --release    # standalone (PC'siz çalışır)
# veya geliştirme için:
flutter run
```

## Özellikler
- E-posta/şifre giriş & kayıt, şifremi unuttum / sıfırlama (kod ile)
- Google ile giriş (`google_sign_in`, ID token → backend `/auth/google`)
- Canlı NOAA Kp paneli: radial gösterge, spektrogram, trend grafiği, simülatör
- Premium üyelik + kişiselleştirilmiş Kp aralığı bildirim tercihleri
- In-app bildirim kutusu (zil)

## Yapılandırma
- API adresi: `lib/api/client.dart` → `apiBase`
- Google Web Client ID: `lib/auth/google.dart` (serverClientId)

### Google ile giriş (her geliştirici için)
Android client, build'i imzalayan keystore'un SHA-1'ine bağlıdır. Google girişini
kullanacaksan kendi SHA-1'ini proje sahibine ilet (Google Cloud'daki Android OAuth
client'a eklensin):
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

## Proje yapısı
```
lib/
  main.dart            # provider + auth kapısı
  theme.dart           # renkler, tipografi
  models/kp.dart       # Kp yorumları + formatlama
  api/                 # noaa.dart (NOAA), client.dart (backend)
  auth/                # auth_provider.dart, google.dart
  screens/             # auth_screen.dart, main_screen.dart
  widgets/             # starfield, status_card, spectrogram, trend_chart, ...
```

> Not: FCM push bildirimleri bu sürümde henüz yok (in-app bildirimler çalışıyor).
