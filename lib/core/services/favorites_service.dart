import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'Session' or 'Over'
  final String date;
  final String speed;
  final String lane;
  final Map<String, dynamic>? extraData;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
    this.speed = '140 km/h',
    this.lane = 'Hexgen Turf',
    this.extraData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'type': type,
    'date': date,
    'speed': speed,
    'lane': lane,
    if (extraData != null) 'extraData': extraData,
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? 'Cricket Session',
    subtitle: json['subtitle'] as String? ?? '',
    type: json['type'] as String? ?? 'Session',
    date: json['date'] as String? ?? '',
    speed: json['speed'] as String? ?? '140 km/h',
    lane: json['lane'] as String? ?? 'Hexgen Turf',
    extraData: json['extraData'] as Map<String, dynamic>?,
  );
}

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal() {
    _loadFromPrefs();
  }

  static const String _prefKey = 'hexgen_favorites_v1';
  final List<FavoriteItem> _items = [];

  List<FavoriteItem> get items => List.unmodifiable(_items);

  bool isFavorite(String id) => _items.any((item) => item.id == id);

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _items.clear();
      for (final str in jsonList) {
        try {
          _items.add(FavoriteItem.fromJson(jsonDecode(str) as Map<String, dynamic>));
        } catch (_) {}
      }
    } else {
      // Pre-seed with the user's top session for immediate visual delight
      _items.add(
        FavoriteItem(
          id: 'SES-03',
          title: 'Session 3 - Cover Drive & High Elbow Practice',
          subtitle: '3 Overs • 142.4 km/h • Hexgen Turf',
          type: 'Session',
          date: '12 October 2025 • 06:00 PM',
          speed: '142.4 km/h',
          lane: 'Hexgen Turf',
        ),
      );
      await _saveToPrefs();
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_prefKey, jsonList);
  }

  Future<bool> toggleFavorite(FavoriteItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    final bool nowFavorite;
    if (index >= 0) {
      _items.removeAt(index);
      nowFavorite = false;
    } else {
      _items.insert(0, item);
      nowFavorite = true;
    }
    await _saveToPrefs();
    notifyListeners();
    return nowFavorite;
  }

  Future<void> removeFavorite(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _saveToPrefs();
    notifyListeners();
  }
}
