import 'dart:developer' as dev;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log('Arka plan bildirimi alındı: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Arka plan mesaj dinleyicisini tanımla
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Ön plan bildirim dinleyicileri
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log('Ön planda bildirim alındı: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log('Bildirime tıklanarak uygulama açıldı: ${message.data}');
    });
  }

  static Future<void> requestPermissionsAndRegister(String authToken) async {
    try {
      // İzin iste
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      dev.log('Bildirim izin durumu: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Token al
        final fcmToken = await _messaging.getToken();
        if (fcmToken != null) {
          dev.log('FCM Token başarıyla alındı: $fcmToken');
          // Backend sunucusuna kaydet
          await api.registerPushToken(authToken, fcmToken);
          dev.log('FCM Token backend sunucusuna başarıyla kaydedildi.');
        }

        // Token yenilenirse otomatik olarak güncelle
        _messaging.onTokenRefresh.listen((newToken) async {
          try {
            await api.registerPushToken(authToken, newToken);
            dev.log('Yenilenen FCM Token backend sunucusuna kaydedildi.');
          } catch (e) {
            dev.log('Yenilenen FCM Token kaydedilemedi: $e');
          }
        });
      }
    } catch (e) {
      dev.log('Bildirim servisi kurulum hatası: $e');
    }
  }
}
