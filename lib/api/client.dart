import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kp.dart';

const apiBase = 'http://10.0.2.2:4000';

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

  Future<JournalEntry> saveJournal(
    String token, {
    String? date,
    int? moodScore,
    Map<String, bool>? symptoms,
    String? notes,
    String? city,
    String? countryCode,
    double? cityLatitude,
    double? cityLongitude,
  }) async {
    final d = await _request(
      '/me/journal',
      method: 'POST',
      token: token,
      body: {
        'date': date,
        'mood_score': moodScore,
        'symptoms': symptoms,
        'notes': notes,
        'city': city,
        'country_code': countryCode,
        'city_latitude': cityLatitude,
        'city_longitude': cityLongitude,
      }..removeWhere((k, v) => v == null),
    );
    return JournalEntry.fromJson(d['journal']);
  }

  Future<List<JournalEntry>> getJournals(String token, {String? from, String? to}) async {
    final d = await _request(
      '/me/journal?${from != null ? 'from=$from' : ''}${to != null ? '&to=$to' : ''}',
      token: token,
    );
    return (d['items'] as List).map((e) => JournalEntry.fromJson(e)).toList();
  }

  Future<JournalEntry?> getJournal(String token, String date) async {
    try {
      final d = await _request('/me/journal/$date', token: token);
      return JournalEntry.fromJson(d['journal']);
    } catch (e) {
      if (e is ApiException && e.status == 404) return null;
      rethrow;
    }
  }

  Future<CorrelationReport> getCorrelationAnalysis(String token) async {
    final d = await _request('/me/journal/correlation-analysis', token: token);
    return CorrelationReport.fromJson(d);
  }

  Future<void> sendSignal({
    String? token,
    required String city,
    required String countryCode,
    required double cityLatitude,
    required double cityLongitude,
    required List<String> symptoms,
  }) async {
    await _request(
      '/signals',
      method: 'POST',
      token: token,
      body: {
        'city': city,
        'country_code': countryCode,
        'city_latitude': cityLatitude,
        'city_longitude': cityLongitude,
        'symptoms': symptoms,
      },
    );
  }

  Future<List<LiveSignal>> getLiveSignals({int hours = 3}) async {
    final d = await _request('/signals/live?hours=$hours');
    return (d['items'] as List).map((e) => LiveSignal.fromJson(e)).toList();
  }

  Future<CitySymptomDistribution> getCitySignals(String token, String city, {int hours = 3}) async {
    final d = await _request('/signals/city/${Uri.encodeComponent(city)}?hours=$hours', token: token);
    return CitySymptomDistribution.fromJson(d);
  }

  Future<UserProfile> getProfile(String token) async {
    final d = await _request('/me/profile', token: token);
    return UserProfile.fromJson(d['profile']);
  }

  Future<UserProfile> updateProfile(
    String token, {
    String? timezone,
    String? homeCity,
    String? homeCountry,
  }) async {
    final d = await _request(
      '/me/profile',
      method: 'PUT',
      token: token,
      body: {
        'timezone': timezone,
        'home_city': homeCity,
        'home_country': homeCountry,
      }..removeWhere((k, v) => v == null),
    );
    return UserProfile.fromJson(d['profile']);
  }

  Future<String> getDailyBulletin() async {
    final d = await _request('/space-weather/bulletin');
    return d['bulletin'] as String? ?? 'Bülten yüklenemedi.';
  }

  Future<List<HistoryPoint>> getSpaceWeatherHistory() async {
    final d = await _request('/space-weather/history');
    final items = d['items'] as List? ?? [];
    final now = DateTime.now();
    return items.map((e) {
      final time = DateTime.parse(e['timestamp'] as String).toLocal();
      final kp = (e['kpIndex'] as num?)?.toDouble() ?? 0.0;
      final schumann = (e['schumannScore'] as num?)?.toDouble() ?? kp;
      final predicted = time.isAfter(now);
      return HistoryPoint(time, kp, predicted, schumann: schumann);
    }).toList();
  }
}

final api = ApiClient();

class JournalEntry {
  final String id;
  final String userId;
  final String date;
  final int? moodScore;
  final Map<String, bool> symptoms;
  final String? notes;
  final String? city;
  final String? countryCode;
  final double? cityLatitude;
  final double? cityLongitude;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.moodScore,
    required this.symptoms,
    this.notes,
    this.city,
    this.countryCode,
    this.cityLatitude,
    this.cityLongitude,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final rawSymptoms = json['symptoms'] as Map<String, dynamic>? ?? {};
    final symptomsMap = rawSymptoms.map((key, value) => MapEntry(key, value == true));

    return JournalEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      moodScore: json['moodScore'] as int?,
      symptoms: symptomsMap,
      notes: json['notes'] as String?,
      city: json['city'] as String?,
      countryCode: json['countryCode'] as String?,
      cityLatitude: json['cityLatitude'] != null ? (json['cityLatitude'] as num).toDouble() : null,
      cityLongitude: json['cityLongitude'] != null ? (json['cityLongitude'] as num).toDouble() : null,
    );
  }
}

class CorrelationValue {
  final double? r;
  final String label;

  CorrelationValue(this.r, this.label);

  factory CorrelationValue.fromJson(Map<String, dynamic> json) {
    return CorrelationValue(
      json['r'] != null ? (json['r'] as num).toDouble() : null,
      json['label'] as String? ?? 'Bilinmiyor',
    );
  }
}

class CorrelationReport {
  final String from;
  final String to;
  final int daysAnalyzed;
  final CorrelationValue moodVsKp;
  final CorrelationValue moodVsSchumann;
  final CorrelationValue symptomCountVsKp;
  final CorrelationValue symptomCountVsSchumann;
  final String note;

  CorrelationReport({
    required this.from,
    required this.to,
    required this.daysAnalyzed,
    required this.moodVsKp,
    required this.moodVsSchumann,
    required this.symptomCountVsKp,
    required this.symptomCountVsSchumann,
    required this.note,
  });

  factory CorrelationReport.fromJson(Map<String, dynamic> json) {
    final range = json['range'] as Map<String, dynamic>? ?? {};
    final corr = json['correlations'] as Map<String, dynamic>? ?? {};
    return CorrelationReport(
      from: range['from'] as String? ?? '',
      to: range['to'] as String? ?? '',
      daysAnalyzed: json['daysAnalyzed'] as int? ?? 0,
      moodVsKp: CorrelationValue.fromJson(corr['mood_vs_kp'] ?? {}),
      moodVsSchumann: CorrelationValue.fromJson(corr['mood_vs_schumann'] ?? {}),
      symptomCountVsKp: CorrelationValue.fromJson(corr['symptomCount_vs_kp'] ?? {}),
      symptomCountVsSchumann: CorrelationValue.fromJson(corr['symptomCount_vs_schumann'] ?? {}),
      note: json['note'] as String? ?? '',
    );
  }
}

class LiveSignal {
  final String id;
  final String city;
  final String countryCode;
  final double cityLatitude;
  final double cityLongitude;
  final List<String> symptoms;
  final DateTime feltAt;

  LiveSignal({
    required this.id,
    required this.city,
    required this.countryCode,
    required this.cityLatitude,
    required this.cityLongitude,
    required this.symptoms,
    required this.feltAt,
  });

  factory LiveSignal.fromJson(Map<String, dynamic> json) {
    return LiveSignal(
      id: json['id'] as String? ?? '',
      city: json['city'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      cityLatitude: (json['cityLatitude'] as num).toDouble(),
      cityLongitude: (json['cityLongitude'] as num).toDouble(),
      symptoms: (json['symptoms'] as List? ?? []).map((e) => e as String).toList(),
      feltAt: DateTime.parse(json['feltAt'] as String),
    );
  }
}

class CitySymptomCount {
  final String slug;
  final int count;
  final int percent;

  CitySymptomCount({required this.slug, required this.count, required this.percent});

  factory CitySymptomCount.fromJson(Map<String, dynamic> json) {
    return CitySymptomCount(
      slug: json['slug'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
    );
  }
}

class CitySymptomDistribution {
  final String city;
  final int total;
  final List<CitySymptomCount> symptoms;

  CitySymptomDistribution({required this.city, required this.total, required this.symptoms});

  factory CitySymptomDistribution.fromJson(Map<String, dynamic> json) {
    return CitySymptomDistribution(
      city: json['city'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      symptoms: (json['symptoms'] as List? ?? [])
          .map((e) => CitySymptomCount.fromJson(e))
          .toList(),
    );
  }
}

class UserProfile {
  final String userId;
  final bool isPremium;
  final String timezone;
  final String? homeCity;
  final String? homeCountry;

  UserProfile({
    required this.userId,
    required this.isPremium,
    required this.timezone,
    this.homeCity,
    this.homeCountry,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? '',
      isPremium: json['isPremium'] == true,
      timezone: json['timezone'] as String? ?? 'UTC',
      homeCity: json['homeCity'] as String?,
      homeCountry: json['homeCountry'] as String?,
    );
  }
}
