import 'dart:convert';
import 'package:http/http.dart' as http;

const apiBase = 'https://renozans-backend.baha.tr';

class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? avatar;
  final bool isPremium;
  AuthUser({required this.id, this.email, this.name, this.avatar, this.isPremium = false});

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'],
        email: j['email'],
        name: j['name'],
        avatar: j['avatar'],
        isPremium: j['isPremium'] == true,
      );
}

class AuthResponse {
  final String token;
  final AuthUser user;
  AuthResponse(this.token, this.user);
}

class NotificationItem {
  final String id;
  final double kp;
  final int band;
  final String title;
  final String body;
  final int createdAt;
  NotificationItem(this.id, this.kp, this.band, this.title, this.body, this.createdAt);

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        j['id'],
        (j['kp'] as num).toDouble(),
        j['band'],
        j['title'],
        j['body'],
        j['createdAt'],
      );
}

class ApiException implements Exception {
  final int status;
  final String message;
  ApiException(this.status, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Object? body,
    String? token,
  }) async {
    final uri = Uri.parse('$apiBase$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    http.Response res;
    try {
      final b = body != null ? jsonEncode(body) : null;
      switch (method) {
        case 'POST':
          res = await http.post(uri, headers: headers, body: b);
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers, body: b);
          break;
        default:
          res = await http.get(uri, headers: headers);
      }
    } catch (_) {
      throw ApiException(0, 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edin.');
    }

    dynamic data;
    if (res.body.isNotEmpty) {
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        data = res.body;
      }
    }
    if (res.statusCode >= 400) {
      final msg = (data is Map && data['message'] != null)
          ? data['message'] as String
          : 'Bir hata oluştu. Lütfen tekrar deneyin.';
      throw ApiException(res.statusCode, msg);
    }
    return data;
  }

  AuthResponse _auth(dynamic d) =>
      AuthResponse(d['token'], AuthUser.fromJson(d['user']));

  Future<AuthResponse> register(String email, String password, [String? name]) async =>
      _auth(await _request('/auth/register', method: 'POST', body: {
        'email': email,
        'password': password,
        if (name != null && name.isNotEmpty) 'name': name,
      }));

  Future<AuthResponse> login(String email, String password) async =>
      _auth(await _request('/auth/login',
          method: 'POST', body: {'email': email, 'password': password}));

  Future<AuthResponse> google(String idToken) async => _auth(
      await _request('/auth/google', method: 'POST', body: {'idToken': idToken}));

  Future<Map?> forgotPassword(String email) async =>
      await _request('/auth/forgot-password', method: 'POST', body: {'email': email})
          as Map?;

  Future<void> resetPassword(String email, String code, String password) =>
      _request('/auth/reset-password',
          method: 'POST',
          body: {'email': email, 'code': code, 'password': password});

  Future<AuthUser> me(String token) async =>
      AuthUser.fromJson((await _request('/me', token: token))['user']);

  Future<AuthUser> upgradePremium(String token) async => AuthUser.fromJson(
      (await _request('/me/premium', method: 'POST', token: token))['user']);

  Future<({List<NotificationItem> items, int unread})> notifications(String token) async {
    final d = await _request('/me/notifications', token: token);
    return (
      items: (d['items'] as List)
          .map((e) => NotificationItem.fromJson(e))
          .toList(),
      unread: d['unreadCount'] as int,
    );
  }

  Future<void> markNotificationsRead(String token) =>
      _request('/me/notifications/read', method: 'POST', token: token);

  Future<List<int>> getPrefs(String token) async {
    final d = await _request('/me/prefs', token: token);
    return (d['bands'] as List).map((e) => e as int).toList();
  }

  Future<List<int>> setPrefs(String token, List<int> bands) async {
    final d = await _request('/me/prefs', method: 'PUT', token: token, body: {'bands': bands});
    return (d['bands'] as List).map((e) => e as int).toList();
  }

  Future<void> registerPushToken(String token, String fcmToken) =>
      _request('/me/push-token', method: 'POST', token: token, body: {'token': fcmToken});
}

final api = ApiClient();
