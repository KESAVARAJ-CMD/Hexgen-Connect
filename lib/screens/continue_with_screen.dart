import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/matrix_api_service.dart';
import '../core/services/sessions_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/dashboard/player_dashboard_screen.dart';

class ExistingPlayerData {
  final String name;
  final String stance; // e.g. "Beginner • Right Hand • 1 Session"
  final String id; // e.g. "HX-0001"
  final int rawPlayerId; // e.g. 1
  final String? avatarUrl;

  const ExistingPlayerData({
    required this.name,
    required this.stance,
    required this.id,
    this.rawPlayerId = 0,
    this.avatarUrl,
  });
}

class ContinueWithScreen extends StatefulWidget {
  final String? playerName;
  final String? playerId;
  final String? phone;

  const ContinueWithScreen({
    super.key,
    this.playerName,
    this.playerId,
    this.phone,
  });

  @override
  State<ContinueWithScreen> createState() => _ContinueWithScreenState();
}

class _ContinueWithScreenState extends State<ContinueWithScreen> {
  List<ExistingPlayerData> _players = [];
  bool _isLoading = true;
  String _activePhone = '';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<ExistingPlayerData> list = [];
    final Set<String> seenIds = {};

    final activePhone = (widget.phone != null && widget.phone!.trim().isNotEmpty)
        ? widget.phone!.trim()
        : (prefs.getString('player_phone') ?? '');

    _activePhone = activePhone;

    // Strictly Query Real Hexgen Matrix Cloud Backend for registered players on this mobile number!
    // GET /api/matrix/players?mobile_number={mobile_number}
    // No mock data, no local storage fallback profiles, strictly real cloud profiles!
    if (activePhone.isNotEmpty) {
      try {
        final cloudPlayers = await MatrixApiService().fetchPlayersByMobile(activePhone);
        for (final cp in cloudPlayers) {
          final pId = 'HX-${cp.playerId.toString().padLeft(4, '0')}';
          if (!seenIds.contains(pId)) {
            seenIds.add(pId);
            final hand = cp.battingHand.isNotEmpty
                ? (cp.battingHand.toUpperCase() == 'RIGHT'
                    ? 'Right Hand'
                    : (cp.battingHand.toUpperCase() == 'LEFT' ? 'Left Hand' : cp.battingHand))
                : 'Right Hand';
            final skill = cp.skillLevel.isNotEmpty ? cp.skillLevel : 'Beginner';
            final sessionText = '${cp.totalSessions} ${cp.totalSessions == 1 ? "Session" : "Sessions"}';
            list.add(
              ExistingPlayerData(
                name: cp.playerName,
                stance: '$skill • $hand • $sessionText',
                id: pId,
                rawPlayerId: cp.playerId,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[ContinueWithScreen] fetchPlayersByMobile error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _players = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPlayerAndNavigate(ExistingPlayerData player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_profile_completed', true);
    await prefs.setString('user_role', 'player');
    await prefs.setString('player_name', player.name);
    await prefs.setString('player_id', player.id);
    await prefs.setInt('cloud_player_id', player.rawPlayerId);
    final activePhone = _activePhone.isNotEmpty
        ? _activePhone
        : (widget.phone ?? prefs.getString('player_phone') ?? '');
    await prefs.setString('player_phone', activePhone);

    // Clear old sessions and load ONLY this selected player's cloud sessions
    SessionsService().clearAndFetchForPlayer(
      mobileNumber: activePhone,
      playerId: player.id,
      numericPlayerId: player.rawPlayerId,
    );

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

              // ── Cloud Players List Cards ──────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricBlue),
                        ),
                      )
                    : _players.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFBFDBFE),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.cloud_off_rounded,
                                      color: Color(0xFF0052FF),
                                      size: 34,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Cloud Profiles Found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _activePhone.isNotEmpty
                                        ? 'No players registered with +91 $_activePhone on Hexgen Matrix cloud.'
                                        : 'No registered player profiles found for this account.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                    label: const Text('Change Number'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0052FF),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
            // Clean Gradient Avatar Circle with Player's Initial
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _buildAvatarImage(player),
              ),
            ),

            const SizedBox(width: 16),

            // Name and Handedness / Level / Sessions
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildAvatarImage(ExistingPlayerData player) {
    if (player.avatarUrl != null && player.avatarUrl!.isNotEmpty) {
      return Image.network(
        player.avatarUrl!,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        errorBuilder: (context, error, stackTrace) => _fallbackLetterAvatar(player.name),
      );
    }

    return _fallbackLetterAvatar(player.name);
  }

  Widget _fallbackLetterAvatar(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
