import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/dashboard/player_dashboard_screen.dart';

class ExistingPlayerData {
  final String name;
  final String stance; // e.g. "Right-handed", "Left-handed"
  final String id;
  final String avatarUrl;

  const ExistingPlayerData({
    required this.name,
    required this.stance,
    required this.id,
    required this.avatarUrl,
  });
}

class ContinueWithScreen extends StatefulWidget {
  final String? playerName;
  final String? playerId;

  const ContinueWithScreen({
    super.key,
    this.playerName,
    this.playerId,
  });

  @override
  State<ContinueWithScreen> createState() => _ContinueWithScreenState();
}

class _ContinueWithScreenState extends State<ContinueWithScreen> {
  static const String subProfilesPrefsKey = 'hexgen_sub_profiles_list_v1';

  List<ExistingPlayerData> _players = [];
  bool _isLoading = true;

  // Preset default players matching the exact UI in the screenshot
  final List<ExistingPlayerData> _defaultPlayers = const [
    ExistingPlayerData(
      name: 'Rahul kumar',
      stance: 'Right-handed',
      id: 'HX-9011',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    ),
    ExistingPlayerData(
      name: 'Mahesh',
      stance: 'Left-handed',
      id: 'HX-9012',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    ExistingPlayerData(
      name: 'vaishnav',
      stance: 'Right-handed',
      id: 'HX-9013',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    ),
    ExistingPlayerData(
      name: 'karthi',
      stance: 'Left-handed',
      id: 'HX-9014',
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&auto=format&fit=crop&q=80',
    ),
    ExistingPlayerData(
      name: 'John',
      stance: 'Right-handed',
      id: 'HX-9015',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80',
    ),
    ExistingPlayerData(
      name: 'Arjun',
      stance: 'Left-handed',
      id: 'HX-9016',
      avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<ExistingPlayerData> list = [];

    // 1. If user just completed their profile, show them at the top!
    final savedName = widget.playerName ?? prefs.getString('player_name');
    final savedId = widget.playerId ?? prefs.getString('player_id') ?? 'HX-9821';
    if (savedName != null && savedName.trim().isNotEmpty) {
      list.add(
        ExistingPlayerData(
          name: savedName.trim(),
          stance: 'Right-handed',
          id: savedId,
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        ),
      );
    }

    // 2. Load created sub profiles
    final rawSubProfiles = prefs.getString(subProfilesPrefsKey);
    if (rawSubProfiles != null && rawSubProfiles.isNotEmpty) {
      try {
        final List<dynamic> subList = jsonDecode(rawSubProfiles);
        for (var sp in subList) {
          final sName = sp['name'] as String? ?? 'Sub Player';
          final sId = sp['id'] as String? ?? 'SUB-${sName.hashCode % 9000 + 1000}';
          list.add(
            ExistingPlayerData(
              name: sName,
              stance: 'Left-handed',
              id: sId,
              avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
            ),
          );
        }
      } catch (_) {}
    }

    // 3. Add screenshot demo profiles (Rahul kumar, Mahesh, vaishnav, karthi, John, Arjun)
    for (var def in _defaultPlayers) {
      if (!list.any((p) => p.name.toLowerCase() == def.name.toLowerCase())) {
        list.add(def);
      }
    }

    setState(() {
      _players = list;
      _isLoading = false;
    });
  }

  Future<void> _selectPlayerAndNavigate(ExistingPlayerData player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_profile_completed', true);
    await prefs.setString('user_role', 'player');
    await prefs.setString('player_name', player.name);
    await prefs.setString('player_id', player.id);

    if (!mounted) return;

    // Navigate to PlayerDashboardScreen with default Sessions Tab (initialIndex = 0)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerDashboardScreen(
          playerName: player.name,
          playerId: player.id,
          initialIndex: 0,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: false,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header Row: < Continue with ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.navyBlue,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

            // ── Existing Players List Cards ──────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricBlue),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      itemCount: _players.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return _buildPlayerCard(player);
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPlayerCard(ExistingPlayerData player) {
    return GestureDetector(
      onTap: () => _selectPlayerAndNavigate(player),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar Circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF7ED),
                border: Border.all(
                  color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  player.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name and Handedness
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    player.stance,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Right Arrow Icon →
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF475569),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
