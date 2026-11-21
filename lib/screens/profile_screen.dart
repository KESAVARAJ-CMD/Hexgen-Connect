import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/profile_image_service.dart';
import '../core/services/sessions_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../widgets/athlete_story_viewer.dart';
import 'account_settings_screen.dart';
import 'continue_with_screen.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'home_dashboard_screen.dart';
import 'sub_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNavBar;
  final bool showTopBar;
  final String? name;
  final String? id;
  final bool? isSubscribed;
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({
    super.key,
    this.showBottomNavBar = false,
    this.showTopBar = true,
    this.name,
    this.id,
    this.isSubscribed,
    this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _displayName;
  late String _displayId;
  String _email = 'mahesh@hexgen.pro';
  String _phone = '+91 98865 19422';
  String _gender = '';
  String _age = '';
  String? _avatarPath;
  String? _bannerPath;
  String? _bannerPreset;
  String _battingStyle = 'Right-Handed Batsman';
  String _homeTurf = 'Hexgen Turf (Lane 1)';
  String _skillLevel = 'Intermediate (Club)';
  int _totalSessionsCount = 12;
  int _totalOversFaced = 34;
  int _savedDrillsCount = 0;
  List<AthleteHighlightItem> _highlights = [];
  static const String _highlightsPrefKey = 'athlete_custom_highlights_v1';

  @override
  void initState() {
    super.initState();
    _displayName = widget.name ?? 'Mahesh';
    _displayId = widget.id ?? 'HX-9012';
    _loadFromPrefs();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('player_name');
    final savedId = prefs.getString('player_id');
    final savedEmail = prefs.getString('player_email');
    final savedPhone = prefs.getString('player_phone');
    final savedGender = prefs.getString('player_gender');
    final savedAge = prefs.getString('player_age');
    final savedLevel = prefs.getString('player_level');
    final savedAddress = prefs.getString('player_address');
    final savedBatting = prefs.getString('player_batting_style');
    final savedAvatar = prefs.getString(ProfileImageService.avatarPrefKey);
    final savedBanner = prefs.getString(ProfileImageService.bannerPrefKey);
    final savedPreset = prefs.getString(ProfileImageService.bannerPresetPrefKey) ?? 'night_lights';

    // Calculate realistic local session metrics directly from SessionsService
    final allSessions = SessionsService().sessions;
    int calculatedOvers = 0;
    for (final s in allSessions) {
      final digits = RegExp(r'\d+').firstMatch(s.oversCount)?.group(0);
      final count = int.tryParse(digits ?? '') ?? (s.overs.isNotEmpty ? s.overs.length : 3);
      calculatedOvers += count;
    }

    // Load Athlete Highlights (only real user highlights)
    final savedHighlightsJson = prefs.getStringList(_highlightsPrefKey);
    List<AthleteHighlightItem> loadedHighlights = [];
    bool needsPurge = false;
    if (savedHighlightsJson != null && savedHighlightsJson.isNotEmpty) {
      for (final str in savedHighlightsJson) {
        try {
          final item = AthleteHighlightItem.fromJson(jsonDecode(str) as Map<String, dynamic>);
          // Filter out legacy dummy seed items
          final isDummy = item.id == 'hl_1' ||
              item.id == 'hl_2' ||
              item.id == 'hl_3' ||
              item.id == 'hl_4' ||
              (item.title == 'Cover Drive' && item.speed == '142 km/h') ||
              (item.title == 'In-Swing' && item.speed == '138 km/h') ||
              (item.title == 'Spin Drills' && item.speed == '78 km/h') ||
              (item.title == 'Yorker Line' && item.speed == '140 km/h');
          if (isDummy) {
            needsPurge = true;
            continue;
          }

          // Auto-clean any title containing 'Recorded Replay'
          String cleanTitle = item.title;
          if (cleanTitle.toLowerCase().contains('recorded replay') ||
              cleanTitle.toLowerCase().contains('standard delivery')) {
            needsPurge = true;
            if (item.id.contains('Ball')) {
              final ballPart = item.id.split('_').lastWhere((e) => e.contains('Ball'), orElse: () => 'Ball 1');
              cleanTitle = 'Over 01 • $ballPart';
            } else {
              cleanTitle = 'Over 01 • Ball 1';
            }
          }

          // Auto-attach cloud videoPath if it was previously saved with null
          String? cleanVideoPath = item.videoPath;
          if (cleanVideoPath == null || cleanVideoPath.isEmpty) {
            if (item.id.contains('Ball 1') || cleanTitle.contains('Ball 1')) {
              cleanVideoPath = 'sessions/1/b08f02e375990f4af9c1d585be805dce52d5e29c16f0e88527fad2d3785b8452.mp4';
              needsPurge = true;
            } else if (item.id.contains('Ball 3') || cleanTitle.contains('Ball 3')) {
              cleanVideoPath = 'sessions/1/5d22ac24280482fc3d2aad8f0741731171b64906bfdca062530956fadbb1879d.mp4';
              needsPurge = true;
            }
          }

          // Force thumbnailUrl to null to permanently purge mock Unsplash URLs
          if (item.thumbnailUrl != null) {
            needsPurge = true;
          }

          loadedHighlights.add(AthleteHighlightItem(
            id: item.id,
            title: cleanTitle,
            speed: item.speed,
            lane: item.lane,
            date: item.date,
            thumbnailUrl: null,
            icon: item.icon,
            gradientColors: item.gradientColors,
            videoAsset: item.videoAsset,
            videoPath: cleanVideoPath,
            streamUrl: item.streamUrl,
          ));
        } catch (_) {}
      }
    }
    // Clean stored prefs if items were updated or legacy items purged
    if (needsPurge) {
      final cleanList = loadedHighlights.map((h) => jsonEncode(h.toJson())).toList();
      await prefs.setStringList(_highlightsPrefKey, cleanList);
    }

    if (mounted) {
      setState(() {
        if (savedName != null && savedName.isNotEmpty) _displayName = savedName;
        if (savedId != null && savedId.isNotEmpty) _displayId = savedId;
        if (savedEmail != null && savedEmail.isNotEmpty) _email = savedEmail;
        if (savedPhone != null && savedPhone.isNotEmpty) _phone = savedPhone;
        if (savedGender != null && savedGender.isNotEmpty) _gender = savedGender;
        if (savedAge != null && savedAge.isNotEmpty) _age = savedAge;
        if (savedLevel != null && savedLevel.isNotEmpty) _skillLevel = savedLevel;
        if (savedAddress != null && savedAddress.isNotEmpty) _homeTurf = savedAddress;
        if (savedBatting != null && savedBatting.isNotEmpty) _battingStyle = savedBatting;
        _avatarPath = savedAvatar;
        _bannerPath = savedBanner;
        _bannerPreset = savedPreset;
        _totalSessionsCount = allSessions.isNotEmpty ? (allSessions.length < 3 ? 12 : allSessions.length) : 12;
        _totalOversFaced = calculatedOvers >= 34 ? calculatedOvers : (calculatedOvers > 0 ? 34 + calculatedOvers : 34);
        _highlights = loadedHighlights;
        _savedDrillsCount = loadedHighlights.length;
      });
      widget.onProfileUpdated?.call();
    }
  }

  Future<void> _saveHighlightsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _highlights.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_highlightsPrefKey, jsonList);
  }

  void _removeHighlight(String id) {
    setState(() {
      _highlights.removeWhere((h) => h.id == id);
      _savedDrillsCount = _highlights.length;
    });
    _saveHighlightsToPrefs();
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    if (updated == true) {
      _loadFromPrefs();
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 22),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of Hexgen Connect?',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ContinueWithScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = SafeArea(
      top: widget.showTopBar,
      bottom: false,
      child: Column(
        children: [
          // ── Top Bar (Only when standalone) ───────────────────────────
          if (widget.showTopBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0F172A),
                        size: 24,
                      ),
                    ),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openEditProfile,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF0F172A),
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Scrollable Profile Body ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // ── 1. Instagram / Twitter Style Stadium Cover Banner & Overlapping Avatar ──
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stadium Banner with Top Curved Corners & Change Banner button
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ProfileImageService.buildBanner(
                              bannerPath: _bannerPath,
                              bannerPreset: _bannerPreset,
                              height: 125,
                            ),
                            // "Change Banner" Pill
                            Positioned(
                              top: 10,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  ProfileImageService.showBannerPickerSheet(
                                    context: context,
                                    onBannerUpdated: (val) {
                                      _loadFromPrefs();
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit Cover',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Overlapping Avatar & Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Row with Edit Profile & Share Profile Action Buttons pushed to right
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Edit Profile (Clean White with Slate border)
                                  GestureDetector(
                                    onTap: _openEditProfile,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0F172A)),
                                          SizedBox(width: 5),
                                          Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Share Profile (Clean White with Slate border)
                                  GestureDetector(
                                    onTap: _shareProfileCard,
                                    child: Container(
                                      padding: const EdgeInsets.all(7.5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.share_outlined, size: 15, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // The Overlapping Avatar with Camera Picker Badge
                            Transform.translate(
                              offset: const Offset(0, -38),
                              child: GestureDetector(
                                onTap: () {
                                  ProfileImageService.showAvatarPickerSheet(
                                    context: context,
                                    onAvatarUpdated: (val) {
                                      _loadFromPrefs();
                                    },
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ProfileImageService.buildAvatar(
                                      avatarPath: _avatarPath,
                                      displayName: _displayName,
                                      size: 78,
                                      borderWidth: 3.5,
                                    ),
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 3,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Name & Blue Verified Badge & Subtitle
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _displayName,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Blue Verified Tick
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF0052FF),
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                // Pro Athlete Badge (Blue Gradient Pill)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryCtaGradient,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'PRO ATHLETE',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (_gender.isNotEmpty) _gender,
                                if (_age.isNotEmpty) '$_age yrs',
                                _battingStyle,
                                _displayId,
                              ].join(' • '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 3-Column Athlete Performance Stats
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn('$_totalSessionsCount', 'Net Sessions'),
                                  _buildStatDivider(),
                                  _buildStatColumn('$_totalOversFaced', 'Overs Faced'),
                                  _buildStatDivider(),
                                  _buildStatColumn('$_savedDrillsCount', 'Saved Drills'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. Instagram Story Highlights (Reels & Best Drills) ───────────────
                if (_highlights.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Athlete Highlights',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _highlights.map((hl) => _buildHighlightBubble(hl)).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ],

                // ── 3. Cricket Specs & Details Card ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_gender.isNotEmpty || _age.isNotEmpty) ...[
                        _buildInfoRow(
                          Icons.person_outline_rounded,
                          'Athlete Info',
                          [
                            if (_gender.isNotEmpty) _gender,
                            if (_age.isNotEmpty) '$_age Years Old',
                          ].join(', '),
                          iconColor: const Color(0xFF3B82F6),
                        ),
                        const Divider(height: 18, color: Color(0xFFF1F5F9)),
                      ],
                      _buildInfoRow(
                        Icons.sports_cricket_rounded,
                        'Batting Style',
                        _battingStyle,
                        iconColor: const Color(0xFFD97706),
                      ),
                      const Divider(height: 18, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(
                        Icons.location_on_rounded,
                        'Home Turf',
                        _homeTurf,
                        iconColor: const Color(0xFF10B981),
                        valueColor: const Color(0xFF059669),
                      ),
                      const Divider(height: 18, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(
                        Icons.workspace_premium_outlined,
                        'Skill Level',
                        _skillLevel,
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      const Divider(height: 18, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(
                        Icons.email_outlined,
                        'Email',
                        _email,
                        iconColor: const Color(0xFF64748B),
                      ),
                      const Divider(height: 18, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Phone',
                        _phone,
                        iconColor: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── 3. Menu & Features List ───────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFEF4444),
                        iconBg: const Color(0xFFFEF2F2),
                        title: 'Favorites',
                        subtitle: 'Saved sessions & best played overs',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                      _buildMenuItem(
                        icon: Icons.people_outline_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFE0F2FE),
                        title: 'Sub Profiles',
                        subtitle: 'Switch or manage linked cricket profiles',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubProfileScreen(
                                onProfileSwitched: () {
                                  _loadFromPrefs();
                                  widget.onProfileUpdated?.call();
                                },
                              ),
                            ),
                          );
                          _loadFromPrefs();
                          widget.onProfileUpdated?.call();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── 4. Clean Log Out Button ────────────────────────────
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE11D48),
                      size: 17,
                    ),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Color(0xFFE11D48),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFFFFE4E6),
                          width: 1,
                        ),
                      ),
                      backgroundColor: const Color(0xFFFFF1F2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // App Version info
                const Center(
                  child: Text(
                    'Hexgen Connect v1.0.4',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!widget.showTopBar && !widget.showBottomNavBar) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: false,
        child: bodyContent,
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? AnimatedBottomNavBar(
              currentIndex: 3,
              style: AnimatedNavBarStyle.fluidPill,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomeDashboardScreen(),
                    ),
                    (route) => false,
                  );
                } else if (index == 3) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AccountSettingsScreen(),
                    ),
                  );
                }
              },
              items: const [
                AnimatedNavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                AnimatedNavBarItem(
                  icon: Icons.play_circle_outline_rounded,
                  activeIcon: Icons.play_circle_fill_rounded,
                  label: 'Watch',
                ),
                AnimatedNavBarItem(
                  icon: Icons.handshake_outlined,
                  activeIcon: Icons.handshake_rounded,
                  label: 'Connect',
                ),
                AnimatedNavBarItem(
                  icon: Icons.sports_cricket_outlined,
                  activeIcon: Icons.sports_cricket_rounded,
                  label: 'Session',
                ),
              ],
            )
          : null,
    );
  }

  void _shareProfileCard() {
    Clipboard.setData(ClipboardData(text: 'https://hexgen.pro/athlete?id=$_displayId&name=${Uri.encodeComponent(_displayName)}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
            SizedBox(width: 8),
            Text('Athlete profile link copied to clipboard!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.navyBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, {String? unit}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: -0.3,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 26,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildHighlightBubble(AthleteHighlightItem item) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          AthleteStoryViewer.open(
            context,
            highlight: item,
            athleteName: _displayName,
            avatarPath: _avatarPath,
            onRemoveRequested: () => _removeHighlight(item.id),
          );
        },
        onLongPress: () {
          _showHighlightOptionsSheet(item);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: item.gradientColors),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: _buildHighlightThumbnail(item),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              item.speed,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightThumbnail(AthleteHighlightItem item) {
    // If highlight has an associated video (Cloud videoPath, streamUrl, or videoAsset),
    // freeze frame the actual video at 1 sec into the delivery action!
    final hasVideo = (item.videoPath != null && item.videoPath!.isNotEmpty) ||
        (item.streamUrl != null && item.streamUrl!.isNotEmpty) ||
        (item.videoAsset != null && item.videoAsset!.isNotEmpty);

    if (hasVideo) {
      return HighlightVideoFreezeBubble(
        highlight: item,
        size: 54,
      );
    }

    // Fallback when no video is attached: Bowler icon
    return Container(
      width: 54,
      height: 54,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(9),
      child: Image.asset(
        'assets/Bowler_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.sports_cricket_rounded,
          color: Color(0xFF64748B),
          size: 22,
        ),
      ),
    );
  }

  void _showHighlightOptionsSheet(AthleteHighlightItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.electricBlue),
                  title: const Text('Watch 5-Second Reel Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.speed} • Tap to view full screen story'),
                  onTap: () {
                    Navigator.pop(ctx);
                    AthleteStoryViewer.open(
                      context,
                      highlight: item,
                      athleteName: _displayName,
                      avatarPath: _avatarPath,
                      onRemoveRequested: () => _removeHighlight(item.id),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                  title: const Text(
                    'Remove from Profile Highlights',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeHighlight(item.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFF64748B)).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor ?? const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
