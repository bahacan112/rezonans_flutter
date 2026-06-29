import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/kp.dart';

class SchumannData {
  final double currentKp;
  final DateTime updatedAt;
  final List<HistoryPoint> history;
  SchumannData(this.currentKp, this.updatedAt, this.history);
}

const _noaaUrl =
    'https://services.swpc.noaa.gov/products/noaa-planetary-k-index-forecast.json';

DateTime _parseUtc(String t) =>
    DateTime.parse(t.endsWith('Z') ? t : '${t}Z').toLocal();

Future<SchumannData> fetchSchumannData() async {
  try {
    final res = await http
        .get(Uri.parse(_noaaUrl))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('NOAA ${res.statusCode}');
    final List list = jsonDecode(res.body);
    final items = list
        .whereType<Map>()
        .where((o) => o['kp'] != null)
        .toList();
    if (items.isEmpty) throw Exception('NOAA empty');

    final now = DateTime.now();
    int lastObs = -1;
    for (int i = items.length - 1; i >= 0; i--) {
      final obs = items[i]['observed'];
      final t = _parseUtc(items[i]['time_tag']);
      if ((obs == 'observed' || obs == 'estimated') && !t.isAfter(now)) {
        lastObs = i;
        break;
      }
    }

    List<Map> past, future;
    double currentKp;
    DateTime updatedAt;
    if (lastObs != -1) {
      past = items.sublist(max(0, lastObs - 15), lastObs + 1).cast<Map>();
      future = items
          .sublist(lastObs + 1, min(lastObs + 9, items.length))
          .cast<Map>();
      currentKp = (items[lastObs]['kp'] as num).toDouble();
      updatedAt = _parseUtc(items[lastObs]['time_tag']);
    } else {
      past = items.sublist(max(0, items.length - 24)).cast<Map>();
      future = [];
      currentKp = (items.last['kp'] as num).toDouble();
      updatedAt = _parseUtc(items.last['time_tag']);
    }

    final history = <HistoryPoint>[
      for (final it in past)
        HistoryPoint(_parseUtc(it['time_tag']), (it['kp'] as num).toDouble(), false),
      for (final it in future)
        HistoryPoint(_parseUtc(it['time_tag']), (it['kp'] as num).toDouble(), true),
    ];

    return SchumannData(currentKp, updatedAt, history);
  } catch (_) {
    return _mockData();
  }
}

SchumannData _mockData() {
  final now = DateTime.now();
  final history = <HistoryPoint>[];
  for (int idx = 0; idx < 24; idx++) {
    final t = now.add(Duration(hours: (idx - 15) * 3));
    var base = 1.5 + sin(idx * 0.5) * 1.2 + cos(idx * 0.8) * 0.8;
    if (idx == 12 || idx == 13) base += 2.5;
    final kp = base.clamp(0.3, 8.7);
    history.add(HistoryPoint(t, (kp * 100).round() / 100, idx > 15));
  }
  final current = history[15].kp;
  return SchumannData(current, history[15].time, history);
}
