import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/matrix_api_service.dart';

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
  final bool isUpcoming;
  final List<Map<String, dynamic>> overs;
  final String sessionToken;

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
    this.isUpcoming = false,
    required this.overs,
    String? sessionToken,
  }) : sessionToken = sessionToken ??
            'HEX-SES-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}-${(id.hashCode.abs() % 9000 + 1000)}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionToken': sessionToken,
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
    'isUpcoming': isUpcoming,
    'overs': overs,
  };

  factory SessionItem.fromJson(Map<String, dynamic> json) => SessionItem(
    id: json['id'] as String? ?? 'SES-01',
    sessionToken: json['sessionToken'] as String?,
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
    isUpcoming: json['isUpcoming'] as bool? ?? false,
    overs: (json['overs'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [],
  );

  SessionItem copyWith({
    String? id,
    String? sessionToken,
    String? title,
    String? name,
    String? date,
    String? time,
    String? lane,
    String? coach,
    String? oversCount,
    String? speed,
    String? armType,
    String? bowlerType,
    String? length,
    String? variation,
    String? direction,
    String? level,
    bool? isUpcoming,
    List<Map<String, dynamic>>? overs,
  }) {
    return SessionItem(
      id: id ?? this.id,
      sessionToken: sessionToken ?? this.sessionToken,
      title: title ?? this.title,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      lane: lane ?? this.lane,
      coach: coach ?? this.coach,
      oversCount: oversCount ?? this.oversCount,
      speed: speed ?? this.speed,
      armType: armType ?? this.armType,
      bowlerType: bowlerType ?? this.bowlerType,
      length: length ?? this.length,
      variation: variation ?? this.variation,
      direction: direction ?? this.direction,
      level: level ?? this.level,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      overs: overs ?? this.overs,
    );
  }

  Map<String, dynamic> toMap() => toJson();
}

class SessionsService extends ChangeNotifier {
  static final SessionsService _instance = SessionsService._internal();
  factory SessionsService() => _instance;
  SessionsService._internal() {
    _loadFromPrefs();
  }

  static const String _legacyPrefKey = 'hexgen_user_sessions_v1';
  String _activePlayerPrefKey = 'hexgen_user_sessions_default_v2';
  final List<SessionItem> _sessions = [];

  List<SessionItem> get sessions => List.unmodifiable(_sessions);

  /// Sessions that are scheduled/upcoming (with QR ready to scan on machine)
  List<SessionItem> get upcomingSessions =>
      _sessions.where((s) => s.isUpcoming).toList();

  /// Sessions that have been played (history with video and overs)
  List<SessionItem> get pastSessions =>
      _sessions.where((s) => !s.isUpcoming).toList();

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clean legacy shared key that had cross-player contamination
      await prefs.remove(_legacyPrefKey);

      final pIdStr = prefs.getString('player_id');
      int numericPlayerId = int.tryParse(pIdStr?.replaceAll(RegExp(r'\D'), '') ?? '') ?? 0;
      if (numericPlayerId <= 0) {
        numericPlayerId = prefs.getInt('cloud_player_id') ?? 0;
      }

      if (numericPlayerId > 0) {
        _activePlayerPrefKey = 'hexgen_user_sessions_p${numericPlayerId}_v2';
        final jsonList = prefs.getStringList(_activePlayerPrefKey);
        if (jsonList != null && jsonList.isNotEmpty) {
          _sessions.clear();
          for (final str in jsonList) {
            try {
              final item = SessionItem.fromJson(jsonDecode(str) as Map<String, dynamic>);
              _sessions.add(item);
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    notifyListeners();
    // Fetch live recorded sessions from cloud backend
    fetchCloudSessions();
  }

  Future<void> addSession(SessionItem item) async {
    // Insert at the beginning so the newest session appears at the top
    _sessions.insert(0, item);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateSession(SessionItem updatedItem) async {
    final idx = _sessions.indexWhere((s) => s.id == updatedItem.id);
    if (idx != -1) {
      _sessions[idx] = updatedItem;
      notifyListeners();
      await _saveToPrefs();
    }
  }

  /// Switch to a new player, immediately wipe old player's past sessions, and fetch new player's cloud sessions
  Future<void> clearAndFetchForPlayer({
    String? mobileNumber,
    String? playerId,
    int? numericPlayerId,
  }) async {
    // Keep only local upcoming sessions, clear past sessions of previous player
    _sessions.removeWhere((s) => !s.isUpcoming);
    notifyListeners();

    await fetchCloudSessions(
      mobileNumber: mobileNumber,
      playerId: playerId ?? (numericPlayerId != null && numericPlayerId > 0 ? 'HX-${numericPlayerId.toString().padLeft(4, '0')}' : null),
    );
  }

  /// Fetch live recorded sessions & video replays from Hexgen Matrix Backend dynamically for the current player
  Future<void> fetchCloudSessions({String? mobileNumber, String? playerId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Remove old legacy shared key
      await prefs.remove(_legacyPrefKey);

      final phone = mobileNumber ?? prefs.getString('player_phone') ?? '';
      final pIdStr = playerId ?? prefs.getString('player_id');
      int numericPlayerId = int.tryParse(pIdStr?.replaceAll(RegExp(r'\D'), '') ?? '') ?? 0;
      if (numericPlayerId <= 0) {
        numericPlayerId = prefs.getInt('cloud_player_id') ?? 0;
      }

      // If we don't have a valid numericPlayerId, resolve it from registered players
      if (numericPlayerId <= 0 && phone.isNotEmpty) {
        final players = await MatrixApiService().fetchPlayersByMobile(phone);
        if (players.isNotEmpty) {
          final savedName = prefs.getString('player_name')?.trim().toLowerCase();
          final matched = players.firstWhere(
            (p) => p.playerName.trim().toLowerCase() == savedName,
            orElse: () => players.first,
          );
          numericPlayerId = matched.playerId;
        }
      }

      if (numericPlayerId <= 0) {
        return;
      }

      _activePlayerPrefKey = 'hexgen_user_sessions_p${numericPlayerId}_v2';

      bool loadedFromPlayerApi = false;
      final List<SessionItem> playerCloudSessions = [];

      // 1. PRIMARY API: GET /api/matrix/players/{player_id}/sessions
      final data = await MatrixApiService().fetchPlayerSessions(numericPlayerId);
      if (data != null && data['sessions'] is List) {
        final rawSessions = data['sessions'] as List<dynamic>;
        final playerName = data['player_name'] as String? ?? 'Player';

        final totalCount = rawSessions.length;
        for (int sessionIdx = 0; sessionIdx < rawSessions.length; sessionIdx++) {
          final s = rawSessions[sessionIdx];
          final sMap = s as Map<String, dynamic>;
          final sId = sMap['session_id'] as int? ?? (sessionIdx + 1);
          final sName = sMap['session_name'] as String? ?? 'Session $sId';
          final sessionSeqNum = totalCount - sessionIdx;
          final sessionTag = 'session $sessionSeqNum';
          final displayDate = sMap['display_date'] as String? ?? '';
          final sessionDateRaw = sMap['session_date'] as String? ?? '';
          final numOvers = sMap['num_overs'] as int? ?? (sMap['overs'] as List?)?.length ?? 1;
          final location = sMap['location'] as String? ?? 'Hexgen Turf';
          final videosList = (sMap['videos'] as List<dynamic>?) ?? [];

          String dateStr = 'Recent';
          String timeStr = '12:00 PM';
          if (displayDate.contains('•')) {
            final parts = displayDate.split('•');
            dateStr = parts[0].trim();
            timeStr = parts[1].trim();
          } else if (sessionDateRaw.isNotEmpty) {
            try {
              final dt = DateTime.parse(sessionDateRaw).toLocal();
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
              final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
              final ampm = dt.hour >= 12 ? 'PM' : 'AM';
              timeStr = '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
            } catch (_) {}
          }

          final rawOvers = (sMap['overs'] as List<dynamic>?) ?? [];
          final List<Map<String, dynamic>> parsedOvers = [];

          for (int i = 0; i < rawOvers.length; i++) {
            final o = rawOvers[i] as Map<String, dynamic>;
            final overNum = o['over_number'] as int? ?? (i + 1);
            final speedKmh = (o['speed_kmh'] as num?)?.toDouble() ?? 100.0;
            final bowlerType = o['bowler_type'] as String? ?? 'PACE';
            final variation = o['variation'] as String?;
            final styleDisplay = o['style_display'] as String? ?? (variation != null ? '$bowlerType • $variation' : bowlerType);
            final balls = o['balls'] as int? ?? 6;

            // 1. Parse ball-by-ball videos directly from over's 'videos' list
            final Map<int, String> ballVideosMap = {};
            final overVideosRaw = (o['videos'] as List<dynamic>?) ?? [];
            for (final v in overVideosRaw) {
              if (v is Map) {
                final bNum = v['ball_number'] as int? ?? 1;
                final vPath = v['video_path'] as String?;
                if (vPath != null && vPath.isNotEmpty) {
                  ballVideosMap[bNum] = vPath;
                }
              }
            }

            // 2. Fallback: match from session-level videos array by over_number
            if (ballVideosMap.isEmpty && videosList.isNotEmpty) {
              for (final v in videosList) {
                if (v is Map) {
                  final vOverNum = v['over_number'] as int?;
                  if (vOverNum == overNum) {
                    final bNum = v['ball_number'] as int? ?? 1;
                    final vPath = v['video_path'] as String?;
                    if (vPath != null && vPath.isNotEmpty) {
                      ballVideosMap[bNum] = vPath;
                    }
                  }
                }
              }
            }

            final bool backendHasVideo = (o['has_video'] as bool?) ?? false;
            // Over has video ONLY if it has actual video replays recorded
            final bool hasOverVideo = (backendHasVideo || ballVideosMap.isNotEmpty) && ballVideosMap.isNotEmpty;
            final String? firstVideoPath = ballVideosMap.isNotEmpty ? ballVideosMap.values.first : null;

            parsedOvers.add({
              'over': 'Over ${overNum.toString().padLeft(2, '0')}',
              'summary': '$balls Balls • ${speedKmh.toStringAsFixed(0)} km/h • $styleDisplay',
              'speed': '${speedKmh.toStringAsFixed(0)} km/h',
              'type': styleDisplay,
              'has_video': hasOverVideo,
              'video_path': firstVideoPath,
              'ball_videos': ballVideosMap,
              'bowler_type': bowlerType,
              'variation': variation,
            });
          }

          if (parsedOvers.isEmpty) {
            for (int i = 0; i < numOvers; i++) {
              final overNum = i + 1;
              parsedOvers.add({
                'over': 'Over ${overNum.toString().padLeft(2, '0')}',
                'summary': '6 Balls • 120 km/h • Pace',
                'speed': '120 km/h',
                'type': 'Pace',
                'has_video': false,
                'video_path': null,
                'ball_videos': <int, String>{},
              });
            }
          }

          final firstOver = parsedOvers.first;
          final cloudSessionId = 'SES-CLOUD-$sId';
          playerCloudSessions.add(
            SessionItem(
              id: cloudSessionId,
              title: sessionTag,
              name: sName,
              date: dateStr,
              time: timeStr,
              lane: location,
              coach: playerName,
              oversCount: '$numOvers ${numOvers == 1 ? "Over" : "Overs"}',
              speed: firstOver['speed'] as String? ?? '120 km/h',
              armType: 'Right Arm',
              bowlerType: firstOver['bowler_type'] as String? ?? 'Pace',
              length: 'Good',
              variation: firstOver['variation'] as String? ?? 'Swing',
              direction: 'In',
              level: 'Pro',
              isUpcoming: false,
              overs: parsedOvers,
            ),
          );
        }
        loadedFromPlayerApi = true;
      }

      // 2. FALLBACK to searchVideos if player API didn't return anything AND we need to search by playerId
      if (!loadedFromPlayerApi && phone.isNotEmpty) {
        final cloudVideos = await MatrixApiService().searchVideos(
          mobileNumber: phone,
          playerId: numericPlayerId,
        );
        if (cloudVideos.isNotEmpty) {
          final grouped = <int, List<MatrixVideoItem>>{};
          for (final v in cloudVideos) {
            if (v.playerId == numericPlayerId) {
              grouped.putIfAbsent(v.sessionId, () => []).add(v);
            }
          }

          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];

          final groupedList = grouped.entries.toList();
          for (int i = 0; i < groupedList.length; i++) {
            final entry = groupedList[i];
            final sessionId = entry.key;
            final ballsList = entry.value;
            final first = ballsList.first;
            final sName = first.sessionName.isNotEmpty ? first.sessionName : 'Session $sessionId';

            DateTime? parsedDate;
            try {
              parsedDate = DateTime.tryParse(first.sessionDate)?.toLocal();
            } catch (_) {}

            String dateStr = 'Today';
            String timeStr = '11:00 AM';
            if (parsedDate != null) {
              dateStr = '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
              final hour = parsedDate.hour > 12
                  ? parsedDate.hour - 12
                  : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
              final ampm = parsedDate.hour >= 12 ? 'PM' : 'AM';
              final minuteStr = parsedDate.minute.toString().padLeft(2, '0');
              timeStr = '${hour.toString().padLeft(2, '0')}:$minuteStr $ampm';
            }

            int calculatedOvers = (ballsList.length / 6).ceil();
            if (calculatedOvers < 1) calculatedOvers = 1;
            if (calculatedOvers > 10) calculatedOvers = 10;
            final totalOversCount = calculatedOvers < 10 && ballsList.isNotEmpty ? 10 : calculatedOvers;

            final List<Map<String, dynamic>> sessionOvers = [];

            for (int o = 0; o < totalOversCount; o++) {
              final overNum = o + 1;
              final overName = 'Over ${overNum.toString().padLeft(2, '0')}';

              String? videoPath;
              String uploadStatus = 'completed';
              String summary = '6 Balls • 140.0 km/h • Turf Delivery';
              String speed = '140.0 km/h';
              String type = 'Turf Delivery';

              if (o < ballsList.length) {
                final ball = ballsList[o];
                videoPath = ball.videoPath;
                uploadStatus = ball.uploadStatus;
                final mb = (ball.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
                summary = 'Cloud Replay • $mb MB • $uploadStatus';
                speed = '142.0 km/h';
                type = 'Match Replay';
              }

              sessionOvers.add({
                'over': overName,
                'summary': summary,
                'speed': speed,
                'type': type,
                'has_video': videoPath != null,
                'video_path': videoPath,
                'upload_status': uploadStatus,
              });
            }

            final cloudSessionId = 'SES-CLOUD-$sessionId';
            final fallbackSeq = groupedList.length - i;
            playerCloudSessions.add(
              SessionItem(
                id: cloudSessionId,
                title: 'session $fallbackSeq',
                name: sName,
                date: dateStr,
                time: timeStr,
                lane: 'Hexgen Turf',
                coach: first.playerName.isNotEmpty ? first.playerName : 'Self Practice',
                oversCount: '$totalOversCount ${totalOversCount == 1 ? "Over" : "Overs"}',
                speed: '142.0 km/h',
                armType: 'Right Arm',
                bowlerType: 'Pace',
                length: 'Good',
                variation: 'Swing',
                direction: 'In',
                level: 'Pro',
                isUpcoming: false,
                overs: sessionOvers,
              ),
            );
          }
        }
      }

      // Preserve local upcoming sessions for this player, replace past sessions with ONLY this player's cloud sessions
      final upcoming = _sessions.where((s) => s.isUpcoming).toList();
      _sessions.clear();
      _sessions.addAll(upcoming);
      _sessions.addAll(playerCloudSessions);

      notifyListeners();
      await _saveToPrefs();
    } catch (e) {
      debugPrint('[SessionsService] fetchCloudSessions error: $e');
    }
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> deleteSessionById(String id) => deleteSession(id);

  Future<void> markAsPlayed(String id) async {
    final idx = _sessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _sessions[idx] = _sessions[idx].copyWith(isUpcoming: false);
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _sessions.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_activePlayerPrefKey, stringList);
    } catch (_) {}
  }
}
