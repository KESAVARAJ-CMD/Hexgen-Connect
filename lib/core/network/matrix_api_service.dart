import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MatrixPlayerModel {
  final int playerId;
  final String playerName;
  final String mobileNumber;
  final String battingHand;
  final String skillLevel;
  final int totalSessions;

  MatrixPlayerModel({
    required this.playerId,
    required this.playerName,
    required this.mobileNumber,
    required this.battingHand,
    required this.skillLevel,
    required this.totalSessions,
  });

  factory MatrixPlayerModel.fromJson(Map<String, dynamic> json) => MatrixPlayerModel(
    playerId: json['player_id'] as int? ?? 0,
    playerName: json['player_name'] as String? ?? 'Player',
    mobileNumber: json['mobile_number'] as String? ?? '',
    battingHand: json['batting_hand'] as String? ?? 'Right Handed',
    skillLevel: json['skill_level'] as String? ?? 'Beginner',
    totalSessions: json['total_sessions'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'player_id': playerId,
    'player_name': playerName,
    'mobile_number': mobileNumber,
    'batting_hand': battingHand,
    'skill_level': skillLevel,
    'total_sessions': totalSessions,
  };
}

class MatrixVideoItem {
  final int sessionId;
  final String videoPath;
  final String uploadStatus;
  final String uploadedAt;
  final int fileSizeBytes;
  final int playerId;
  final String playerName;
  final String mobileNumber;
  final String sessionName;
  final String sessionDate;

  MatrixVideoItem({
    required this.sessionId,
    required this.videoPath,
    required this.uploadStatus,
    required this.uploadedAt,
    required this.fileSizeBytes,
    required this.playerId,
    required this.playerName,
    required this.mobileNumber,
    required this.sessionName,
    required this.sessionDate,
  });

  factory MatrixVideoItem.fromJson(Map<String, dynamic> json) => MatrixVideoItem(
    sessionId: json['session_id'] as int? ?? 0,
    videoPath: json['video_path'] as String? ?? '',
    uploadStatus: json['upload_status'] as String? ?? 'completed',
    uploadedAt: json['uploaded_at'] as String? ?? '',
    fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
    playerId: json['player_id'] as int? ?? 0,
    playerName: json['player_name'] as String? ?? 'Player',
    mobileNumber: json['mobile_number'] as String? ?? '',
    sessionName: json['session_name'] as String? ?? 'Session',
    sessionDate: json['session_date'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'video_path': videoPath,
    'upload_status': uploadStatus,
    'uploaded_at': uploadedAt,
    'file_size_bytes': fileSizeBytes,
    'player_id': playerId,
    'player_name': playerName,
    'mobile_number': mobileNumber,
    'session_name': sessionName,
    'session_date': sessionDate,
  };
}

class MatrixApiService {
  static final MatrixApiService _instance = MatrixApiService._internal();
  factory MatrixApiService() => _instance;
  MatrixApiService._internal();

  static const String baseUrl = 'https://webapi.hexgen.in';
  static const String apiKey = 'Hg_Matrix_6666';

  // Cache pre-signed playback URLs in memory (valid for 1 hour)
  final Map<String, _CachedPlaybackUrl> _urlCache = {};

  /// 2.1. Get Player Profiles by Mobile Number (Screen 1: Select Player)
  /// GET /api/matrix/players?mobile_number={mobile_number}
  Future<List<MatrixPlayerModel>> fetchPlayersByMobile(String mobileNumber) async {
    if (mobileNumber.trim().isEmpty) return [];
    try {
      final cleanPhone = mobileNumber.replaceAll(RegExp(r'\D'), '');
      final last10 = cleanPhone.length > 10
          ? cleanPhone.substring(cleanPhone.length - 10)
          : cleanPhone;

      final url = Uri.parse('$baseUrl/api/matrix/players?mobile_number=$last10');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawPlayers = data['players'] as List<dynamic>? ?? [];
        return rawPlayers
            .map((e) => MatrixPlayerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('[MatrixApiService] fetchPlayersByMobile failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[MatrixApiService] fetchPlayersByMobile error: $e');
      return [];
    }
  }

  /// 2.2. Search Videos by Mobile Number, Player ID or Session ID (Screen 2)
  /// GET /api/matrix/videos/search?player_id={player_id}&mobile_number={mobile_number}&limit={limit}
  Future<List<MatrixVideoItem>> searchVideos({
    String? mobileNumber,
    int? playerId,
    int? sessionId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (playerId != null && playerId > 0) {
        queryParams['player_id'] = playerId.toString();
      }
      if (mobileNumber != null && mobileNumber.trim().isNotEmpty) {
        final cleanPhone = mobileNumber.replaceAll(RegExp(r'\D'), '');
        final last10 = cleanPhone.length > 10
            ? cleanPhone.substring(cleanPhone.length - 10)
            : cleanPhone;
        queryParams['mobile_number'] = last10;
      }
      if (sessionId != null) {
        queryParams['session_id'] = sessionId.toString();
      }

      final uri = Uri.parse('$baseUrl/api/matrix/videos/search').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawVideos = data['videos'] as List<dynamic>? ?? [];
        return rawVideos
            .map((e) => MatrixVideoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('[MatrixApiService] searchVideos failed: ${response.statusCode} -> ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('[MatrixApiService] searchVideos error: $e');
      return [];
    }
  }

  /// 2.2. Get Sessions, Overs & Videos for Selected Player (Screens 1 & 2: Sessions & Nets Screen)
  /// GET /api/matrix/players/{player_id}/sessions
  Future<Map<String, dynamic>?> fetchPlayerSessions(int playerId) async {
    if (playerId <= 0) return null;
    try {
      final uri = Uri.parse('$baseUrl/api/matrix/players/$playerId/sessions');
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('[MatrixApiService] fetchPlayerSessions failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[MatrixApiService] fetchPlayerSessions error: $e');
    }
    return null;
  }

  /// 2.3. Get Video Playback / Streaming URL
  /// GET /api/matrix/videos/play?video_path={video_path}
  Future<String?> getPlaybackUrl(String videoPath) async {
    if (videoPath.isEmpty) return null;

    // Check memory cache
    final cached = _urlCache[videoPath];
    if (cached != null && !cached.isExpired) {
      return cached.url;
    }

    try {
      final uri = Uri.parse('$baseUrl/api/matrix/videos/play').replace(
        queryParameters: {'video_path': videoPath},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final playbackUrl = data['playback_url'] as String?;
        final expiresIn = data['expires_in_seconds'] as int? ?? 3600;

        if (playbackUrl != null && playbackUrl.isNotEmpty) {
          _urlCache[videoPath] = _CachedPlaybackUrl(
            url: playbackUrl,
            expiresAt: DateTime.now().add(Duration(seconds: expiresIn - 120)),
          );
          return playbackUrl;
        }
      } else {
        debugPrint('[MatrixApiService] getPlaybackUrl failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[MatrixApiService] getPlaybackUrl error: $e');
    }
    return null;
  }

  /// 2.3. Check upload status for a session
  /// GET /api/matrix/sessions/{session_id}/videos/upload-status
  Future<Map<String, dynamic>?> getUploadStatus(int sessionId, {String? videoPath}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/matrix/sessions/$sessionId/videos/upload-status').replace(
        queryParameters: videoPath != null ? {'video_path': videoPath} : null,
      );
      final response = await http.get(
        uri,
        headers: {'X-API-Key': apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[MatrixApiService] getUploadStatus error: $e');
    }
    return null;
  }
}

class _CachedPlaybackUrl {
  final String url;
  final DateTime expiresAt;

  _CachedPlaybackUrl({required this.url, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
