import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/network/matrix_api_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/services/sessions_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../screens/session_config_screen.dart';
import '../../coach/ask_coach_screen.dart';
import '../../session/simple_over_video_screen.dart';

class SessionsTab extends StatefulWidget {
  final bool isSubscribed;
  final VoidCallback onUnlockSubscription;

  const SessionsTab({
    super.key,
    required this.isSubscribed,
    required this.onUnlockSubscription,
  });

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  // Track which session is expanded to show its overs in Past Sessions
  int? _expandedSessionIndex;
  // Selected segment filter: 'upcoming' or 'past'
  String _selectedTab = 'upcoming';

  final FavoritesService _favoritesService = FavoritesService();
  final SessionsService _sessionsService = SessionsService();

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onStateChanged);
    _sessionsService.addListener(_onStateChanged);
    _sessionsService.fetchCloudSessions();

    // Default to 'upcoming' if there are upcoming sessions, else 'past'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sessionsService.upcomingSessions.isEmpty && _sessionsService.pastSessions.isNotEmpty) {
        setState(() {
          _selectedTab = 'past';
        });
      }
    });
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onStateChanged);
    _sessionsService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  List<SessionItem> get _upcomingSessions => _sessionsService.upcomingSessions;
  List<SessionItem> get _pastSessions => _sessionsService.pastSessions;

  String _formatShortDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return timeStr ?? '';

    // Shorten month names
    String shortDate = dateStr
        .replaceAll('January', 'Jan')
        .replaceAll('February', 'Feb')
        .replaceAll('March', 'Mar')
        .replaceAll('April', 'Apr')
        .replaceAll('June', 'Jun')
        .replaceAll('July', 'Jul')
        .replaceAll('August', 'Aug')
        .replaceAll('September', 'Sep')
        .replaceAll('October', 'Oct')
        .replaceAll('November', 'Nov')
        .replaceAll('December', 'Dec');

    // Remove 4-digit year to keep it short & neat
    shortDate = shortDate.replaceAll(RegExp(r'\s*\b20\d\d\b'), '').trim();

    // Shorten time: e.g. "06:00 PM" -> "6:00 PM"
    String shortTime = (timeStr ?? '').trim();
    if (shortTime.startsWith('0') &&
        shortTime.length > 1 &&
        RegExp(r'^0\d:').hasMatch(shortTime)) {
      shortTime = shortTime.substring(1);
    }

    if (shortTime.isEmpty) return shortDate;
    return '$shortDate • $shortTime';
  }

  void _watchOverVideo(Map<String, dynamic> over, String sessionTitle, String lane) {
    Map<int, String>? ballVideos;
    if (over['ball_videos'] is Map) {
      ballVideos = (over['ball_videos'] as Map).map(
        (key, value) => MapEntry(
          key is int ? key : int.tryParse(key.toString()) ?? 1,
          value.toString(),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleOverVideoScreen(
          sessionTitle: sessionTitle,
          overName: over['over']!,
          overType: over['type'] ?? over['summary'] ?? 'Practice Delivery',
          lane: lane,
          speed: over['speed'] ?? '70 km/h',
          ballsSummary: over['summary'] ?? '6 Balls',
          videoPath: over['video_path'] as String?,
          ballVideos: ballVideos,
          bowlerType: over['bowler_type'] as String?,
          variation: over['variation'] as String?,
          styleDisplay: over['type'] as String?,
          armType: over['session_arm_type'] as String?,
          pitchLine: over['session_line'] as String?,
          pitchLength: over['session_length'] as String?,
          overData: over,
        ),
      ),
    );
  }

  void _showSessionQrCode(SessionItem item) {
    showDialog(
      context: context,
      builder: (ctx) => SessionQrShareDialog(
        sessionItem: item,
        sessionTitle: item.name.isNotEmpty ? item.name : item.title,
        speed: double.tryParse(item.speed.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 140.0,
        armType: item.armType,
        bowlerType: item.bowlerType,
        length: item.length,
        variation: item.variation,
        machineId: 'HEX-${item.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}',
        onDone: () => Navigator.pop(ctx),
      ),
    );
  }

  void _confirmDeleteSession(String sessionId, String sessionTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text(
              'Delete Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete $sessionTitle? All details for this session will be removed.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _sessionsService.deleteSessionById(sessionId);
              setState(() {
                _expandedSessionIndex = null;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$sessionTitle deleted successfully'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.navyBlue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewSession() async {
    final nextNum = _sessionsService.sessions.length + 1;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SessionConfigScreen(
          isCreatingPracticeSession: true,
          initialSessionTitle: 'session $nextNum',
        ),
      ),
    );

    if (created == true && mounted) {
      setState(() {
        _selectedTab = 'upcoming'; // Switch to Upcoming so user immediately sees new session & QR
      });
    }
  }

  Future<void> _editSession(SessionItem item) async {
    int oversCount = item.overs.isNotEmpty ? item.overs.length : 6;
    final match = RegExp(r'\d+').firstMatch(item.oversCount);
    if (match != null) {
      final parsed = int.tryParse(match.group(0)!);
      if (parsed != null && parsed >= 1 && parsed <= 10) {
        oversCount = parsed;
      }
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SessionConfigScreen(
          isCreatingPracticeSession: false,
          initialSessionTitle: item.name,
          initialOversCount: oversCount,
          sessionToEdit: item,
        ),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} updated successfully!'),
          backgroundColor: AppTheme.navyBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // ── Header: Title & New Session Action Button ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sessions & Nets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Configure, view QR and track your cricket practice',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── + New Session Button ────────────────────────────────────
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _createNewSession,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryCtaGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0057FF).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'New Session',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Segment Switcher: [ Upcoming Sessions (X) ] | [ Past Sessions (Y) ] ──
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Tab 1: Upcoming Sessions
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'upcoming';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 'upcoming'
                            ? AppTheme.primaryCtaGradient
                            : null,
                        color: _selectedTab == 'upcoming' ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _selectedTab == 'upcoming'
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0052FF).withValues(alpha: 0.22),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 16,
                            color: _selectedTab == 'upcoming'
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Upcoming Sessions',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: _selectedTab == 'upcoming'
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _selectedTab == 'upcoming'
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          if (_upcomingSessions.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _selectedTab == 'upcoming'
                                    ? Colors.white
                                    : const Color(0xFF0052FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_upcomingSessions.length}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: _selectedTab == 'upcoming'
                                      ? const Color(0xFF0052FF)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Tab 2: Past Sessions
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'past';
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        gradient: _selectedTab == 'past'
                            ? AppTheme.primaryCtaGradient
                            : null,
                        color: _selectedTab == 'past' ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: _selectedTab == 'past'
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0052FF).withValues(alpha: 0.22),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 16,
                            color: _selectedTab == 'past'
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Past Sessions',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: _selectedTab == 'past'
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _selectedTab == 'past'
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          if (_pastSessions.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _selectedTab == 'past'
                                    ? Colors.white
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_pastSessions.length}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: _selectedTab == 'past'
                                      ? const Color(0xFF0052FF)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── TAB CONTENT ──────────────────────────────────────────────────
          if (_selectedTab == 'upcoming')
            _buildUpcomingSessionsList()
          else
            _buildPastSessionsList(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. UPCOMING SESSIONS VIEW (NEW SESSIONS + INSTANT QR CODE ACCESS)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildUpcomingSessionsList() {
    if (_upcomingSessions.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 42,
                color: Color(0xFF0052FF),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Upcoming Sessions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a new session to configure bowling parameters and generate a saved QR code for your practice.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _createNewSession,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryCtaGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0057FF).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Create New Session Now',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _upcomingSessions.map((item) {
        final machineId = 'HEX-${item.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBFDBFE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0052FF).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ready Badge & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF86EFAC),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                              SizedBox(width: 4),
                              Text(
                                'READY TO BOWL',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF16A34A),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Date & Time Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4.5),
                          Text(
                            _formatShortDateTime(item.date, item.time),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Session Name & Title
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.title} • Machine: $machineId',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 12),

                // Specs Chips Row (Speed, Arm, Bowler Type, Length, Overs)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildSpecChip('${item.speed} Pace', Icons.speed_rounded),
                    _buildSpecChip('${item.armType} • ${item.bowlerType}', Icons.sports_cricket_rounded),
                    _buildSpecChip('${item.length} • ${item.variation}', Icons.tune_rounded),
                    _buildSpecChip(item.oversCount, Icons.repeat_rounded),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Action Buttons Row: View QR Code, Edit, Done, Delete
                Row(
                  children: [
                    // Primary Action: View QR Code Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showSessionQrCode(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryCtaGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 5),
                                  Text(
                                    'View QR Code',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Edit Button
                    GestureDetector(
                      onTap: () => _editSession(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Mark as Played
                    GestureDetector(
                      onTap: () async {
                        await _sessionsService.markAsPlayed(item.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.title} moved to Past Sessions!'),
                              backgroundColor: AppTheme.navyBlue,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 16, color: Color(0xFF0F172A)),
                            SizedBox(width: 4),
                            Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Delete Button
                    GestureDetector(
                      onTap: () => _confirmDeleteSession(item.id, item.name),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFE4E6)),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. PAST SESSIONS VIEW (COMPLETED SESSIONS + OVERS + VIDEO HIGHLIGHTS)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPastSessionsList() {
    if (_pastSessions.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.history_rounded, size: 42, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'No Past Sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Sessions you complete will appear here with over-by-over analysis and video playback.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _pastSessions.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isExpanded = _expandedSessionIndex == index;
        final overs = item.overs;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: isExpanded ? 0.06 : 0.03),
                blurRadius: isExpanded ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Session Header Card (Tap to Expand Overs) ───
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedSessionIndex = isExpanded ? null : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Session Badge & Date/Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Session Badge (Blue gradient fill when selected/expanded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: isExpanded ? AppTheme.primaryCtaGradient : null,
                                color: isExpanded ? null : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isExpanded ? Colors.transparent : const Color(0xFFCBD5E1),
                                  width: 0.9,
                                ),
                                boxShadow: isExpanded
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                'session ${_pastSessions.length - index}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isExpanded ? Colors.white : const Color(0xFF0F172A),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            // Shortened Date & Time (Warm Amber/Yellow Mix Pill)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 11,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 4.5),
                                  Text(
                                    _formatShortDateTime(item.date, item.time),
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Session Name
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Bottom Row: Location & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Location Text (Green icon and text)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13.5,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.lane,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),

                            // Actions: Favorite + Overs Pill + Chevron
                            Builder(
                              builder: (context) {
                                final isSessionFav = _favoritesService.isFavorite(item.id);
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Favorite Session Heart
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        final favItem = FavoriteItem(
                                          id: item.id,
                                          title: '${item.title} - ${item.name}',
                                          subtitle: '${item.oversCount} • ${item.speed} • ${item.lane}',
                                          type: 'Session',
                                          date: '${item.date} • ${item.time}',
                                          speed: item.speed,
                                          lane: item.lane,
                                          extraData: {
                                            'sessionTitle': '${item.title} - ${item.name}',
                                            'lane': item.lane,
                                          },
                                        );
                                        final added = await _favoritesService.toggleFavorite(favItem);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                added
                                                    ? 'Saved ${item.title} to Favorites ❤️'
                                                    : 'Removed ${item.title} from Favorites',
                                              ),
                                              duration: const Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: const Color(0xFF0F172A),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isSessionFav
                                              ? const Color(0xFFFEF2F2)
                                              : const Color(0xFFF8FAFC),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSessionFav
                                                ? const Color(0xFFFECACA)
                                                : const Color(0xFFE2E8F0),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Icon(
                                          isSessionFav
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          size: 14,
                                          color: isSessionFav
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Overs Count Pill Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.sports_cricket_rounded,
                                            size: 11,
                                            color: Color(0xFF475569),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.oversCount,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF334155),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // Expand Chevron
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: const Color(0xFF64748B),
                                      size: 18,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Expanded Overs List (Shown on Click) ─────────────────
                if (isExpanded) ...[
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overs Played (${overs.length} Overs)',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _showSessionQrCode(item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.qr_code_2_rounded, size: 13, color: Color(0xFF334155)),
                                        SizedBox(width: 4),
                                        Text(
                                          'QR Code',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _confirmDeleteSession(item.id, item.name),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFFE4E6)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFFE11D48)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE11D48),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // List each over as a sleek interactive row
                        ...overs.map((o) {
                          final overMap = o;
                          final hasVideo = overMap['has_video'] == true &&
                              ((overMap['ball_videos'] is Map && (overMap['ball_videos'] as Map).isNotEmpty) ||
                               (overMap['video_path'] != null && (overMap['video_path'] as String).isNotEmpty));
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (!hasVideo) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No video replay recorded for this over. Video replays are available for overs with recorded deliveries.'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                _watchOverVideo(
                                  {
                                    ...overMap,
                                    'session_arm_type': item.armType,
                                    'session_length': item.length,
                                    'session_variation': item.variation,
                                    'session_bowler_type': item.bowlerType,
                                    'session_speed': item.speed,
                                  },
                                  '${item.title} - ${item.name}',
                                  item.lane,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
                                ),
                                child: Row(
                                  children: [
                                    // Video Action Thumbnail Badge
                                    BowlingActionVectorBadge(
                                      overNumber: (overMap['over'] as String)
                                          .replaceAll('Over ', '')
                                          .padLeft(2, '0'),
                                      thumbnailUrl: overMap['thumbnail'] as String? ??
                                          overMap['thumbnailUrl'] as String?,
                                      hasVideo: hasVideo,
                                      videoPath: overMap['video_path'] as String?,
                                    ),
                                    const SizedBox(width: 12),

                                    // Over Summary
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            overMap['over']!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            overMap['summary']!,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Over Favorite Heart Button
                                    Builder(
                                      builder: (context) {
                                        final overId = '${item.id}_${overMap['over']}';
                                        final isOverFav = _favoritesService.isFavorite(overId);
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () async {
                                            final favItem = FavoriteItem(
                                              id: overId,
                                              title: '${item.title} - ${overMap['over']}',
                                              subtitle: '${overMap['summary']}',
                                              type: 'Over',
                                              date: '${item.date} • ${item.time}',
                                              speed: overMap['speed'] as String? ?? '140 km/h',
                                              lane: item.lane,
                                              extraData: {
                                                'sessionTitle': '${item.title} - ${item.name}',
                                                'overName': overMap['over'] as String? ?? 'Over',
                                                'summary': overMap['summary'] as String? ?? '',
                                              },
                                            );
                                            final added = await _favoritesService.toggleFavorite(favItem);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    added
                                                        ? 'Saved ${overMap['over']} to Favorites ❤️'
                                                        : 'Removed ${overMap['over']} from Favorites',
                                                  ),
                                                  duration: const Duration(seconds: 1),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: const Color(0xFF0F172A),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isOverFav ? const Color(0xFFFEF2F2) : Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isOverFav ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                                                width: 0.9,
                                              ),
                                            ),
                                            child: Icon(
                                              isOverFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                              size: 15,
                                              color: isOverFav ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    // Refined Watch CTA Button or No Video Badge
                                    if (hasVideo)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFCBD5E1),
                                            width: 1.0,
                                          ),
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
                                            Icon(Icons.play_arrow_rounded, color: Color(0xFF0F172A), size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              'Watch',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.videocam_off_outlined, color: Color(0xFF94A3B8), size: 13),
                                            SizedBox(width: 4),
                                            Text(
                                              'No Video',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 8),

                        // ── Ask Coach About This Session (Clean White Banner) ──
                        GestureDetector(
                          onTap: () {
                            AskCoachScreen.open(
                              context,
                              preAttachedSession: '${item.title} - ${item.name}',
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF0F172A)),
                                SizedBox(width: 8),
                                Text(
                                  'Ask Coach About This Session',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Video Action Thumbnail Badge ─────────────────────────────────────────────
class BowlingActionVectorBadge extends StatefulWidget {
  final String overNumber;
  final String? thumbnailUrl;
  final bool hasVideo;
  final String? videoPath;

  const BowlingActionVectorBadge({
    super.key,
    required this.overNumber,
    this.thumbnailUrl,
    this.hasVideo = false,
    this.videoPath,
  });

  @override
  State<BowlingActionVectorBadge> createState() => _BowlingActionVectorBadgeState();
}

class _BowlingActionVectorBadgeState extends State<BowlingActionVectorBadge> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasVideo && widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      _initVideoThumbnail();
    }
  }

  @override
  void didUpdateWidget(BowlingActionVectorBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath || oldWidget.hasVideo != widget.hasVideo) {
      _disposeController();
      if (widget.hasVideo && widget.videoPath != null && widget.videoPath!.isNotEmpty) {
        _initVideoThumbnail();
      } else {
        if (mounted) {
          setState(() {
            _isInitialized = false;
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _initVideoThumbnail() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final playbackUrl = await MatrixApiService().getPlaybackUrl(widget.videoPath!);
      if (playbackUrl == null || playbackUrl.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final controller = VideoPlayerController.networkUrl(Uri.parse(playbackUrl));
      await controller.initialize();
      await controller.setVolume(0);
      await controller.pause();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[BowlingActionVectorBadge] Error loading video thumbnail: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _disposeController() {
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Circular Badge Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9),
              border: Border.all(
                color: widget.hasVideo
                    ? const Color(0xFF0057FF).withValues(alpha: 0.55)
                    : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildThumbnailContent(),
            ),
          ),

          // Over Number Pill Tag (anchored at the bottom center of the circular badge)
          Positioned(
            bottom: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                widget.overNumber,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailContent() {
    // 1. If video is available and controller is ready -> freeze frame of video!
    if (widget.hasVideo && _isInitialized && _videoController != null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    // 2. If video is loading
    if (widget.hasVideo && _isLoading) {
      return Container(
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0057FF),
            ),
          ),
        ),
      );
    }

    // 3. If explicit non-default network thumbnail was provided
    if (widget.thumbnailUrl != null &&
        widget.thumbnailUrl!.isNotEmpty &&
        widget.thumbnailUrl != 'assets/video_thumbnail.png' &&
        widget.thumbnailUrl!.startsWith('http')) {
      return Image.network(
        widget.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildBowlerIconFallback(),
      );
    }

    // 4. Fallback when no video or error -> show assets/Bowler_icon.png!
    return _buildBowlerIconFallback();
  }

  Widget _buildBowlerIconFallback() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(7),
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
}
