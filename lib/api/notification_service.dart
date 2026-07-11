import 'package:firebase_messaging/firebase_messaging.dart';
import 'client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Arka plan bildirimi alındı: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Arka plan mesaj dinleyicisini tanımla
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Ön plan bildirim dinleyicileri
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Ön planda bildirim alındı: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Bildirime tıklanarak uygulama açıldı: ${message.data}');
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

      print('Bildirim izin durumu: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Token al
        final fcmToken = await _messaging.getToken();
        if (fcmToken != null) {
          print('FCM Token başarıyla alındı: $fcmToken');
          // Backend sunucusuna kaydet
          await api.registerPushToken(authToken, fcmToken);
          print('FCM Token backend sunucusuna başarıyla kaydedildi.');
        }

        // Token yenilenirse otomatik olarak güncelle
        _messaging.onTokenRefresh.listen((newToken) async {
          try {
            await api.registerPushToken(authToken, newToken);
            print('Yenilenen FCM Token backend sunucusuna kaydedildi.');
          } catch (e) {
            print('Yenilenen FCM Token kaydedilemedi: $e');
          }
        });
      }
    } catch (e) {
      print('Bildirim servisi kurulum hatası: $e');
    }
  }
}
