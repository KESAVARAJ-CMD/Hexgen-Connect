import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionItem {
  final String id;
  final String title;
  final String name;
  final String date;
  final String time;
  final String lane;
  final String coach;
  final String oversCount;
  final String speed;
  final String armType;
  final String bowlerType;
  final String length;
  final String variation;
  final String direction;
  final String level;
  final List<Map<String, dynamic>> overs;

  SessionItem({
    required this.id,
    required this.title,
    required this.name,
    required this.date,
    required this.time,
    this.lane = 'Hexgen Turf',
    this.coach = 'Self Practice',
    required this.oversCount,
    required this.speed,
    this.armType = 'Right Arm',
    this.bowlerType = 'Pace',
    this.length = 'Good Length',
    this.variation = 'Swing',
    this.direction = 'In',
    this.level = 'Basic',
    required this.overs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'name': name,
    'date': date,
    'time': time,
    'lane': lane,
    'coach': coach,
    'oversCount': oversCount,
    'speed': speed,
    'armType': armType,
    'bowlerType': bowlerType,
    'length': length,
    'variation': variation,
    'direction': direction,
    'level': level,
    'overs': overs,
  };

  factory SessionItem.fromJson(Map<String, dynamic> json) => SessionItem(
    id: json['id'] as String? ?? 'SES-01',
    title: json['title'] as String? ?? 'Session',
    name: json['name'] as String? ?? 'Practice Session',
    date: json['date'] as String? ?? '',
    time: json['time'] as String? ?? '',
    lane: json['lane'] as String? ?? 'Hexgen Turf',
    coach: json['coach'] as String? ?? 'Self Practice',
    oversCount: json['oversCount'] as String? ?? '6 Overs',
    speed: json['speed'] as String? ?? '140 km/h',
    armType: json['armType'] as String? ?? 'Right Arm',
    bowlerType: json['bowlerType'] as String? ?? 'Pace',
    length: json['length'] as String? ?? 'Good Length',
    variation: json['variation'] as String? ?? 'Swing',
    direction: json['direction'] as String? ?? 'In',
    level: json['level'] as String? ?? 'Basic',
    overs: (json['overs'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
  );

  Map<String, dynamic> toMap() => toJson();
}

class SessionsService extends ChangeNotifier {
  static final SessionsService _instance = SessionsService._internal();
  factory SessionsService() => _instance;
  SessionsService._internal() {
    _loadFromPrefs();
  }

  static const String _prefKey = 'hexgen_user_sessions_v1';
  final List<SessionItem> _sessions = [];

  List<SessionItem> get sessions => List.unmodifiable(_sessions);

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_prefKey);

      if (jsonList != null && jsonList.isNotEmpty) {
        _sessions.clear();
        for (final str in jsonList) {
          try {
            _sessions.add(SessionItem.fromJson(jsonDecode(str) as Map<String, dynamic>));
          } catch (_) {}
        }
      } else {
        // Pre-seed with the 3 default sessions
        _seedDefaults();
      }
    } catch (_) {
      if (_sessions.isEmpty) _seedDefaults();
    }
    notifyListeners();
  }

  void _seedDefaults() {
    _sessions.clear();
    _sessions.addAll([
      SessionItem(
        id: 'SES-03',
        title: 'Session 3',
        name: 'Cover Drive & High Elbow Practice',
        date: '12 October 2025',
        time: '06:00 PM',
        lane: 'Hexgen Turf',
        coach: 'Coach Madhu',
        oversCount: '3 Overs',
        speed: '142.4 km/h',
        armType: 'Right Arm',
        bowlerType: 'Pace',
        length: 'Good',
        variation: 'Swing',
        direction: 'In',
        level: 'High',
        overs: [
          {
            'over': 'Over 01',
            'summary': '6 Balls • 142.4 km/h • Fast Pace',
            'speed': '142.4 km/h',
            'type': 'Fast Pace',
          },
          {
            'over': 'Over 02',
            'summary': '6 Balls • 138.8 km/h • In-Swing',
            'speed': '138.8 km/h',
            'type': 'In-Swing Defense',
          },
          {
            'over': 'Over 03',
            'summary': '6 Balls • 78.5 km/h • Off-Spin',
            'speed': '78.5 km/h',
            'type': 'Spin Delivery',
          },
        ],
      ),
      SessionItem(
        id: 'SES-02',
        title: 'Session 2',
        name: 'Pace Attack & Line Alignment',
        date: '28 September 2025',
        time: '07:30 AM',
        lane: 'Hexgen Turf',
        coach: 'Coach Rahul',
        oversCount: '2 Overs',
        speed: '138.8 km/h',
        armType: 'Right Arm',
        bowlerType: 'Pace',
        length: 'Good',
        variation: 'Seam',
        direction: 'Out',
        level: 'Medium',
        overs: [
          {
            'over': 'Over 01',
            'summary': '6 Balls • 138.8 km/h • Fast Seam',
            'speed': '138.8 km/h',
            'type': 'Fast Pace',
          },
          {
            'over': 'Over 02',
            'summary': '6 Balls • 136.0 km/h • Out-Swing',
            'speed': '136.0 km/h',
            'type': 'Out-Swing Line',
          },
        ],
      ),
      SessionItem(
        id: 'SES-01',
        title: 'Session 1',
        name: 'Front-Foot Balance & Defense',
        date: '15 September 2025',
        time: '05:00 PM',
        lane: 'Hexgen Turf',
        coach: 'Coach Priya',
        oversCount: '4 Overs',
        speed: '134.0 km/h',
        armType: 'Right Arm',
        bowlerType: 'Pace',
        length: 'Good',
        variation: 'Swing',
        direction: 'In',
        level: 'Basic',
        overs: [
          {
            'over': 'Over 01',
            'summary': '6 Balls • 134.0 km/h • Good Length',
            'speed': '134.0 km/h',
            'type': 'Good Length Defense',
          },
          {
            'over': 'Over 02',
            'summary': '6 Balls • 132.5 km/h • Full Pitch',
            'speed': '132.5 km/h',
            'type': 'Full Pitch Drive',
          },
          {
            'over': 'Over 03',
            'summary': '6 Balls • 82.0 km/h • Flighted Spin',
            'speed': '82.0 km/h',
            'type': 'Flighted Spin',
          },
          {
            'over': 'Over 04',
            'summary': '6 Balls • 135.0 km/h • Fast Yorker',
            'speed': '135.0 km/h',
            'type': 'Yorker Defense',
          },
        ],
      ),
    ]);
  }

  Future<void> addSession(SessionItem item) async {
    // Insert at the beginning so the newest session appears at the top
    _sessions.insert(0, item);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> deleteSession(int index) async {
    if (index >= 0 && index < _sessions.length) {
      _sessions.removeAt(index);
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _sessions.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_prefKey, stringList);
    } catch (_) {}
  }
}
