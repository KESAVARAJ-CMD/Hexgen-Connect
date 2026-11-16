import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/favorites_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../models/pose_data.dart';
import '../coach/ask_coach_screen.dart';
import '../../widgets/athlete_story_viewer.dart';
import '../../widgets/session_video_stage.dart';

const String _defaultVideoAsset = 'assets/U15S125O3B1.mp4';

class SimpleOverVideoScreen extends StatefulWidget {
  final String sessionTitle;
  final String overName;
  final String overType;
  final String date;
  final String lane;
  final String speed;
  final String ballsSummary;
  final String videoAsset;

  const SimpleOverVideoScreen({
    super.key,
    required this.sessionTitle,
    required this.overName,
    this.overType = 'Pace Practice',
    this.date = 'Today • 06:00 PM',
    this.lane = 'Lane 3 (Turf Pitch)',
    this.speed = '142 km/h',
    this.ballsSummary = '6 Balls • 0 Wickets • 4 Runs',
    this.videoAsset = _defaultVideoAsset,
    this.initialBallIndex = 0,
  });

  final int initialBallIndex;

  @override
  State<SimpleOverVideoScreen> createState() => _SimpleOverVideoScreenState();
}

class _SimpleOverVideoScreenState extends State<SimpleOverVideoScreen> {
  late int _selectedBallIndex;
  final FavoritesService _favoritesService = FavoritesService();
  Set<String> _highlightedBallIds = {};

  @override
  void initState() {
    super.initState();
    _selectedBallIndex = widget.initialBallIndex.clamp(0, _balls.length - 1);
    _favoritesService.addListener(_onFavoritesChanged);
    _loadHighlightStatus();
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  String _ballHighlightId(String ballName) =>
      'hl_${widget.sessionTitle}_${widget.overName}_$ballName';

  bool _isBallHighlighted(String ballName) =>
      _highlightedBallIds.contains(_ballHighlightId(ballName));

  Future<void> _loadHighlightStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('athlete_custom_highlights_v1') ?? [];
      final ids = <String>{};
      for (final s in list) {
        try {
          final json = jsonDecode(s) as Map<String, dynamic>;
          final id = json['id'] as String?;
          if (id != null) ids.add(id);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _highlightedBallIds = ids;
        });
      }
    } catch (_) {}
  }

  static const _balls = [
    {
      'ball': 'Ball 1',
      'desc': 'Good Length • Defended',
      'speed': '138.8 km/h',
      'line': 'Outside Off',
      'length': 'Good Length',
      'ballType': 'Fast Seam',
      'armType': 'Right Arm',
      'shot': 'Forward Defense',
    },
    {
      'ball': 'Ball 2',
      'desc': 'Outside Off • Left alone',
      'speed': '140.2 km/h',
      'line': '4th Stump',
      'length': 'Good Length',
      'ballType': 'Out-Swinger',
      'armType': 'Right Arm',
      'shot': 'Leave Alone',
    },
    {
      'ball': 'Ball 3',
      'desc': 'Full Pitch • Cover Drive (4 Runs)',
      'speed': '142.4 km/h',
      'line': 'Off Stump',
      'length': 'Full Pitch',
      'ballType': 'Fast Pace',
      'armType': 'Right Arm',
      'shot': 'Cover Drive',
    },
    {
      'ball': 'Ball 4',
      'desc': 'In-swinger • Play & Miss',
      'speed': '139.5 km/h',
      'line': 'Middle & Leg',
      'length': 'Full Length',
      'ballType': 'In-Swinger',
      'armType': 'Right Arm',
      'shot': 'On-Drive',
    },
    {
      'ball': 'Ball 5',
      'desc': 'Short of Length • Single',
      'speed': '137.0 km/h',
      'line': 'Outside Off',
      'length': 'Short Length',
      'ballType': 'Back of Length',
      'armType': 'Right Arm',
      'shot': 'Back-Foot Punch',
    },
    {
      'ball': 'Ball 6',
      'desc': 'Good Length • Solid Defense',
      'speed': '141.0 km/h',
      'line': 'Off Stump',
      'length': 'Good Length',
      'ballType': 'Straight Seam',
      'armType': 'Right Arm',
      'shot': 'Forward Defense',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeBall = _balls[_selectedBallIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.navyBlue, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.overName} Video',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
            Text(
              '${widget.sessionTitle} • ${widget.lane}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) {
              final activeBall = _balls[_selectedBallIndex];
              final ballName = activeBall['ball'] ?? 'Ball 1';
              final isHl = _isBallHighlighted(ballName);
              return IconButton(
                tooltip: isHl ? 'In Athlete Highlights ⭐' : 'Add Shot to Profile Highlights ⭐',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isHl ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: isHl
                        ? Border.all(color: const Color(0xFFFCD34D), width: 0.8)
                        : null,
                  ),
                  child: Icon(
                    isHl ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isHl ? const Color(0xFFD97706) : AppTheme.electricBlue,
                    size: 18,
                  ),
                ),
                onPressed: () => _addCurrentBallToHighlights(context, activeBall),
              );
            },
          ),
          Builder(
            builder: (context) {
              final activeBall = _balls[_selectedBallIndex];
              final ballId = '${widget.sessionTitle}_${widget.overName}_${activeBall['ball']}';
              final isFav = _favoritesService.isFavorite(ballId);
              return IconButton(
                tooltip: isFav ? 'Remove Shot Favorite' : 'Save Shot to Favorites',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isFav ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: isFav
                        ? Border.all(color: const Color(0xFFFECACA), width: 0.8)
                        : null,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    size: 18,
                  ),
                ),
                onPressed: () async {
                  final item = FavoriteItem(
                    id: ballId,
                    title: '${widget.sessionTitle} - ${widget.overName} (${activeBall['ball']})',
                    subtitle: '${activeBall['desc']} • ${activeBall['speed']}',
                    type: 'Shot',
                    date: widget.date,
                    speed: activeBall['speed'] ?? widget.speed,
                    lane: widget.lane,
                    extraData: {
                      'sessionTitle': widget.sessionTitle,
                      'overName': widget.overName,
                      'ball': activeBall['ball'],
                      'ballIndex': _selectedBallIndex,
                      'summary': activeBall['desc'],
                    },
                  );
                  final added = await _favoritesService.toggleFavorite(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              added ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: added ? const Color(0xFFEF4444) : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                added
                                    ? 'Saved ${activeBall['ball']} (${activeBall['desc']}) to Favorites ❤️'
                                    : 'Removed ${activeBall['ball']} from Favorites',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.navyBlue,
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Clean Video Stage ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SessionVideoStage(
                  assetPath: widget.videoAsset,
                  keypoints: const <String, Keypoint>{},
                  title: '${widget.overName} - ${activeBall['ball']}',
                  subtitle: '${widget.overType} • ${activeBall['speed']}',
                  height: 260,
                  compact: true,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Ball Selector (Quick Jump) ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Deliveries in this Over',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '6 Balls',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_balls.length, (index) {
                      final isSelected = _selectedBallIndex == index;
                      final ballName = _balls[index]['ball'] ?? '';
                      final ballId = '${widget.sessionTitle}_${widget.overName}_$ballName';
                      final isBallFav = _favoritesService.isFavorite(ballId);
                      final isBallHl = _isBallHighlighted(ballName);

                      return GestureDetector(
                        onTap: () => setState(() => _selectedBallIndex = index),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 52,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF0057FF).withValues(alpha: 0.22),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/cricket_ball.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.sports_baseball_rounded,
                                      size: 20,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'B${index + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? AppTheme.electricBlue : AppTheme.navyBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isBallHl)
                              Positioned(
                                top: -3,
                                left: -3,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    size: 10,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            if (isBallFav)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    size: 10,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  _buildHighlightShotButton(context, activeBall),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Delivery Configuration Card ────────────────────────────────
            _buildDeliveryConfigCard(activeBall),

            const SizedBox(height: 16),

            // ── Ask Coach Action Card (Side-by-Side Modern Layout) ─────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.forum_outlined, size: 16, color: AppTheme.electricBlue),
                          SizedBox(width: 6),
                          Text(
                            'Ask Coach For Advice',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '2 Options',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Option A: Specific Ball
                      Expanded(
                        child: HexgenButton(
                          text: 'BALL ${_selectedBallIndex + 1}',
                          icon: Icons.sports_cricket_rounded,
                          height: 46,
                          fontSize: 12,
                          onPressed: () {
                            AskCoachScreen.open(
                              context,
                              preAttachedSession:
                                  '${widget.sessionTitle} • ${widget.overName} (Ball ${_selectedBallIndex + 1})',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Option B: Full Over
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                AskCoachScreen.open(
                                  context,
                                  preAttachedSession:
                                      '${widget.sessionTitle} • ${widget.overName} (Full Over • 6 Balls)',
                                );
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.video_collection_rounded, size: 16, color: AppTheme.electricBlue),
                                    SizedBox(width: 6),
                                    Text(
                                      'FULL OVER',
                                      style: TextStyle(
                                        color: AppTheme.navyBlue,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Clean Back to Overs Action ─────────────────────────────────
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF64748B)),
                label: const Text(
                  'Back to Overs',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryConfigCard(Map<String, String> activeBall) {
    final ballSpeedStr = (activeBall['speed'] ?? widget.speed).replaceAll(' km/h', '');
    final speedVal = double.tryParse(ballSpeedStr) ?? 140.0;
    final ballName = activeBall['ball'] ?? 'Ball 1';
    final shotName = activeBall['shot'] ?? 'Forward Defense';
    final desc = activeBall['desc'] ?? '';
    final outcomeText = desc.contains('•') ? desc.split('•').last.trim() : desc;

    final String speedTier = speedVal >= 140.0
        ? '⚡ Express Pace'
        : speedVal >= 130.0
            ? '🔥 Fast Seam'
            : '🌀 Controlled Flight';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF0052FF).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Gradient Accent Stripe ────────────────────────
            Container(
              height: 3.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF00D2FF), Color(0xFF10B981)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            // ── Header: Title & Active Ball Tag ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0052FF), Color(0xFF00D2FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052FF).withValues(alpha: 0.28),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sensors_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery Configuration',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Bowling Machine Telemetry Feed',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF86EFAC), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$ballName Active',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // ── Row 1: Speed & Delivery Type (50% / 50% Equal Grid) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTelemetryMetricTile(
                      label: 'RELEASE SPEED',
                      labelColor: const Color(0xFF0369A1),
                      value: ballSpeedStr,
                      unit: 'km/h',
                      subLabel: speedTier,
                      subLabelColor: const Color(0xFF0284C7),
                      icon: Icons.speed_rounded,
                      iconColor: const Color(0xFF0284C7),
                      gradientColors: const [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                      borderColor: const Color(0xFFBAE6FD),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTelemetryMetricTile(
                      label: 'BALL & ARM TYPE',
                      labelColor: const Color(0xFF6D28D9),
                      value: activeBall['ballType'] ?? 'Fast Seam',
                      subLabel: activeBall['armType'] ?? 'Right Arm',
                      subLabelColor: const Color(0xFF7C3AED),
                      icon: Icons.rotate_right_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      gradientColors: const [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                      borderColor: const Color(0xFFE9D5FF),
                    ),
                  ),
                ],
              ),
            ),

            // ── Row 2: Pitch Line & Pitch Length (50% / 50% Equal Grid) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTelemetryMetricTile(
                      label: 'PITCH LINE',
                      labelColor: const Color(0xFFB45309),
                      value: activeBall['line'] ?? 'Outside Off',
                      subLabel: 'Target Channel',
                      subLabelColor: const Color(0xFFD97706),
                      icon: Icons.straighten_rounded,
                      iconColor: const Color(0xFFD97706),
                      gradientColors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      borderColor: const Color(0xFFFDE68A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTelemetryMetricTile(
                      label: 'PITCH LENGTH',
                      labelColor: const Color(0xFF047857),
                      value: activeBall['length'] ?? 'Good Length',
                      subLabel: 'Bounce Zone',
                      subLabelColor: const Color(0xFF059669),
                      icon: Icons.height_rounded,
                      iconColor: const Color(0xFF059669),
                      gradientColors: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                      borderColor: const Color(0xFFA7F3D0),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Shot Outcome Bar ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/cricket_ball.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.sports_cricket_rounded,
                        size: 16,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SHOT EXECUTED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          shotName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildOutcomeBadge(outcomeText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeBadge(String text) {
    Color bg1;
    Color bg2;
    Color border;
    Color textColor;
    IconData icon;

    final lower = text.toLowerCase();
    if (lower.contains('4') || lower.contains('bound') || lower.contains('run')) {
      bg1 = const Color(0xFFD1FAE5);
      bg2 = const Color(0xFFA7F3D0);
      border = const Color(0xFF6EE7B7);
      textColor = const Color(0xFF065F46);
      icon = Icons.stars_rounded;
    } else if (lower.contains('defend') || lower.contains('solid')) {
      bg1 = const Color(0xFFEFF6FF);
      bg2 = const Color(0xFFDBEAFE);
      border = const Color(0xFFBFDBFE);
      textColor = const Color(0xFF1E40AF);
      icon = Icons.shield_rounded;
    } else if (lower.contains('left') || lower.contains('leave')) {
      bg1 = const Color(0xFFF1F5F9);
      bg2 = const Color(0xFFE2E8F0);
      border = const Color(0xFFCBD5E1);
      textColor = const Color(0xFF334155);
      icon = Icons.visibility_off_rounded;
    } else if (lower.contains('miss')) {
      bg1 = const Color(0xFFFEF3C7);
      bg2 = const Color(0xFFFDE68A);
      border = const Color(0xFFFCD34D);
      textColor = const Color(0xFF92400E);
      icon = Icons.warning_amber_rounded;
    } else {
      bg1 = const Color(0xFFEFF6FF);
      bg2 = const Color(0xFFE0E7FF);
      border = const Color(0xFFC7D2FE);
      textColor = const Color(0xFF3730A3);
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bg1, bg2]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetricTile({
    required String label,
    required Color labelColor,
    required String value,
    String? unit,
    required String subLabel,
    required Color subLabelColor,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required Color borderColor,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: labelColor,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.navyBlue,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ],
            ],
          ),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: subLabelColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightShotButton(BuildContext context, Map<String, String> activeBall) {
    final ballName = activeBall['ball'] ?? 'Ball 1';
    final shotName = activeBall['shot'] ?? activeBall['desc'] ?? 'Shot';
    final isHl = _isBallHighlighted(ballName);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _addCurrentBallToHighlights(context, activeBall),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: isHl
              ? const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF00D2FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (isHl ? const Color(0xFF10B981) : const Color(0xFF0052FF))
                  .withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHl ? Icons.stars_rounded : Icons.star_border_rounded,
              color: isHl ? const Color(0xFFFDE047) : Colors.white,
              size: 19,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isHl
                    ? '$ballName IS IN PROFILE HIGHLIGHTS ⭐'
                    : 'ADD $ballName ($shotName) AS HIGHLIGHT ⭐',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCurrentBallToHighlights(
    BuildContext context,
    Map<String, String> activeBall,
  ) async {
    final ballName = activeBall['ball'] ?? 'Ball 1';
    final ballId = _ballHighlightId(ballName);
    final prefs = await SharedPreferences.getInstance();
    const key = 'athlete_custom_highlights_v1';
    final rawList = prefs.getStringList(key);

    List<AthleteHighlightItem> currentList = [];
    if (rawList != null && rawList.isNotEmpty) {
      for (final s in rawList) {
        try {
          currentList.add(AthleteHighlightItem.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (_) {}
      }
    } else {
      currentList = [
        const AthleteHighlightItem(
          id: 'hl_1',
          title: 'Cover Drive',
          speed: '142 km/h',
          thumbnailUrl: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=200&auto=format&fit=crop&q=80',
          icon: Icons.sports_cricket_rounded,
          gradientColors: [Color(0xFF0052FF), Color(0xFF00D2FF)],
        ),
        const AthleteHighlightItem(
          id: 'hl_2',
          title: 'In-Swing',
          speed: '138 km/h',
          thumbnailUrl: 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=200&auto=format&fit=crop&q=80',
          icon: Icons.air_rounded,
          gradientColors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
        ),
        const AthleteHighlightItem(
          id: 'hl_3',
          title: 'Spin Drills',
          speed: '78 km/h',
          thumbnailUrl: 'https://images.unsplash.com/photo-1599474924187-334a4ae5bd3c?w=200&auto=format&fit=crop&q=80',
          icon: Icons.sync_rounded,
          gradientColors: [Color(0xFF10B981), Color(0xFF06B6D4)],
        ),
        const AthleteHighlightItem(
          id: 'hl_4',
          title: 'Yorker Line',
          speed: '140 km/h',
          thumbnailUrl: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=200&auto=format&fit=crop&q=80',
          icon: Icons.bolt_rounded,
          gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      ];
    }

    final existingIndex = currentList.indexWhere((item) => item.id == ballId);
    final shotName = activeBall['shot'] ?? activeBall['desc'] ?? ballName;
    final ballSpeed = activeBall['speed'] ?? widget.speed;

    final newItem = AthleteHighlightItem(
      id: ballId,
      title: shotName,
      speed: ballSpeed,
      lane: '${widget.lane} • ${widget.overName}',
      date: widget.date,
      thumbnailUrl: _thumbnailForShot(shotName, activeBall['ballType'] ?? ''),
      icon: Icons.sports_cricket_rounded,
      gradientColors: const [Color(0xFF0052FF), Color(0xFF00D2FF)],
      videoAsset: widget.videoAsset,
    );

    if (existingIndex >= 0) {
      currentList.removeAt(existingIndex);
    }
    currentList.insert(0, newItem);

    final updatedStrings = currentList.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, updatedStrings);

    await _loadHighlightStatus();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.navyBlue,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFFACC15), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Added $shotName to Profile Highlights! ⭐',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
                  ),
                  Text(
                    '$ballName • $ballSpeed • Visible on Profile tab',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String _thumbnailForShot(String shot, String ballType) {
    final s = shot.toLowerCase();
    final b = ballType.toLowerCase();
    if (s.contains('cover') || s.contains('drive')) {
      return 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=200&auto=format&fit=crop&q=80';
    } else if (s.contains('defense') || s.contains('defend')) {
      return 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=200&auto=format&fit=crop&q=80';
    } else if (s.contains('pull') || s.contains('hook') || s.contains('punch')) {
      return 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=200&auto=format&fit=crop&q=80';
    } else if (b.contains('spin') || s.contains('spin') || s.contains('sweep')) {
      return 'https://images.unsplash.com/photo-1599474924187-334a4ae5bd3c?w=200&auto=format&fit=crop&q=80';
    } else if (b.contains('swing') || b.contains('fast') || b.contains('seam')) {
      return 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=200&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=200&auto=format&fit=crop&q=80';
  }
}
