import 'package:flutter/material.dart';
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
  // Track which session is expanded to show its overs
  int? _expandedSessionIndex;
  final FavoritesService _favoritesService = FavoritesService();
  final SessionsService _sessionsService = SessionsService();

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onStateChanged);
    _sessionsService.addListener(_onStateChanged);
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

  List<Map<String, dynamic>> get _sessions =>
      _sessionsService.sessions.map((s) => s.toMap()).toList();

  String _formatShortDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || dateStr.isEmpty) return timeStr ?? '';

    // Shorten month names (e.g. October -> Oct, September -> Sep)
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

    // Remove 4-digit year to keep it short & neat (e.g. "12 Oct 2025" -> "12 Oct")
    shortDate = shortDate.replaceAll(RegExp(r'\s*\b20\d\d\b'), '').trim();

    // Shorten time: e.g. "06:00 PM" -> "6:00 PM", "07:30 AM" -> "7:30 AM"
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleOverVideoScreen(
          sessionTitle: sessionTitle,
          overName: over['over']!,
          overType: over['summary'] ?? 'Practice Delivery',
          lane: lane,
          speed: over['speed'] ?? '140 km/h',
          ballsSummary: over['summary'] ?? '6 Balls',
        ),
      ),
    );
  }

  void _showSessionQrCode(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => SessionQrShareDialog(
        sessionTitle: item['name'] ?? item['title'] ?? 'Session Practice',
        speed: double.tryParse((item['speed'] as String? ?? '140').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 140.0,
        armType: item['armType'] as String? ?? 'Right Arm',
        bowlerType: item['bowlerType'] as String? ?? 'Pace',
        length: item['length'] as String? ?? 'Good',
        variation: item['variation'] as String? ?? 'Swing',
        machineId: 'HEX-${(item['id'] ?? 'SES-01').toString().replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}',
        onDone: () => Navigator.pop(ctx),
      ),
    );
  }

  void _confirmDeleteSession(int index, String sessionTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
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
          'Are you sure you want to delete $sessionTitle? All overs and video data for this session will be removed.',
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
              await _sessionsService.deleteSession(index);
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
    final nextNumber = _sessionsService.sessions.length + 1;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SessionConfigScreen(
          isCreatingPracticeSession: true,
          initialSessionTitle: 'Session $nextNumber Practice',
        ),
      ),
    );

    if (created == true && mounted) {
      setState(() {
        _expandedSessionIndex = 0; // Auto-expand newly created session
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // ── Header: Previous Sessions & New Session Action ───────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap a session to see overs played & watch video',
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

          // ── List of Played Sessions ──────────────────────────────────────
          if (_sessions.isEmpty) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_cricket_rounded,
                      size: 48,
                      color: AppTheme.electricBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Sessions Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'No practice sessions recorded yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _createNewSession,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryCtaGradient,
                        borderRadius: BorderRadius.circular(14),
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
                          Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Create First Session',
                            style: TextStyle(
                              fontSize: 14,
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
            ),
          ] else ...[
            ..._sessions.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isExpanded = _expandedSessionIndex == index;
              final overs = (item['overs'] as List<dynamic>?) ?? [];

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
                                      item['title']!,
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
                                          _formatShortDateTime(item['date'], item['time']),
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
                                item['name']!,
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
                                        item['lane']!,
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
                                      final sessionId = item['id'] as String? ?? '';
                                      final isSessionFav = _favoritesService.isFavorite(sessionId);
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Favorite Session Heart
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () async {
                                              final favItem = FavoriteItem(
                                                id: sessionId,
                                                title: '${item['title']} - ${item['name']}',
                                                subtitle: '${item['oversCount']} • ${item['speed']} • ${item['lane']}',
                                                type: 'Session',
                                                date: '${item['date']} • ${item['time']}',
                                                speed: item['speed'] as String? ?? '140 km/h',
                                                lane: item['lane'] as String? ?? 'Hexgen Turf',
                                                extraData: {
                                                  'sessionTitle': '${item['title']} - ${item['name']}',
                                                  'lane': item['lane'],
                                                },
                                              );
                                              final added = await _favoritesService.toggleFavorite(favItem);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      added
                                                          ? 'Saved ${item['title']} to Favorites ❤️'
                                                          : 'Removed ${item['title']} from Favorites',
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
                                                  item['oversCount']!,
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
                                        onTap: () => _confirmDeleteSession(index, item['title'] ?? 'Session'),
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
                                final overMap = o as Map<String, dynamic>;
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _watchOverVideo(
                                      overMap,
                                      '${item['title']} - ${item['name']}',
                                      item['lane']!,
                                    ),
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
                                              final overId = '${item['id']}_${overMap['over']}';
                                              final isOverFav = _favoritesService.isFavorite(overId);
                                              return GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () async {
                                                  final favItem = FavoriteItem(
                                                    id: overId,
                                                    title: '${item['title']} - ${overMap['over']}',
                                                    subtitle: '${overMap['summary']}',
                                                    type: 'Over',
                                                    date: '${item['date']} • ${item['time']}',
                                                    speed: overMap['speed'] as String? ?? '140 km/h',
                                                    lane: item['lane'] as String? ?? 'Hexgen Turf',
                                                    extraData: {
                                                      'sessionTitle': '${item['title']} - ${item['name']}',
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

                                          // Refined Clean White Watch CTA Button
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
                                    preAttachedSession: '${item['title']} - ${item['name']}',
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
            }),
          ],
        ],
      ),
    );
  }
}

/// ── Video Action Thumbnail Badge ─────────────────────────────────────────────
class BowlingActionVectorBadge extends StatelessWidget {
  final String overNumber;
  final String? thumbnailUrl;

  const BowlingActionVectorBadge({
    super.key,
    required this.overNumber,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = thumbnailUrl ?? 'assets/video_thumbnail.png';
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Circular Badge Container with Real Video Action Thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
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
              child: thumb.startsWith('http')
                  ? Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/video_thumbnail.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/player.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Image.asset(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/player.png',
                        fit: BoxFit.cover,
                      ),
                    ),
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
                overNumber,
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
}

/// ── Realistic Cricket Fast Bowler Action Vector Painter ─────────────────────
class BowlingActionPainter extends CustomPainter {
  final Color primaryColor;
  final Color ballColor;

  const BowlingActionPainter({
    this.primaryColor = const Color(0xFF0052FF),
    this.ballColor = const Color(0xFFEF4444),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Normalized viewBox: 32x32
    final scale = size.width / 32.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fillPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final limbStroke = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final ballPaint = Paint()
      ..color = ballColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final whiteDetail = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final creasePaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final motionPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 0. Popping Crease Ground Line
    canvas.drawLine(const Offset(3.0, 29.5), const Offset(14.0, 29.5), creasePaint);

    // 1. Head & Cricket Cap
    canvas.drawCircle(const Offset(13.8, 8.5), 2.8, fillPaint);
    // Cap visor projecting forward toward batsman
    final capVisor = Path()
      ..moveTo(12.5, 6.8)
      ..quadraticBezierTo(9.5, 6.5, 8.5, 8.0)
      ..lineTo(12.5, 8.5)
      ..close();
    canvas.drawPath(capVisor, fillPaint);

    // 2. Muscular Torso (Filled anatomical path in delivery arch)
    final torso = Path()
      ..moveTo(14.2, 11.0)
      ..quadraticBezierTo(17.5, 14.0, 16.5, 18.5)
      ..lineTo(12.5, 19.5)
      ..quadraticBezierTo(11.0, 15.5, 9.8, 12.8)
      ..lineTo(12.5, 10.8)
      ..close();
    canvas.drawPath(torso, fillPaint);

    // 3. Left Non-Bowling Arm (Tucked chest drive / gathering arm)
    final leftArm = Path()
      ..moveTo(10.5, 12.5)
      ..lineTo(7.0, 13.5)
      ..lineTo(8.5, 16.5);
    canvas.drawPath(leftArm, limbStroke);

    // 4. Right Bowling Arm (High vertical delivery arm extending overhead to 1 o'clock)
    final rightArm = Path()
      ..moveTo(15.0, 12.0)
      ..quadraticBezierTo(18.0, 8.0, 20.5, 3.5);
    canvas.drawPath(rightArm, limbStroke);

    // Hand/wrist cocked at release point
    canvas.drawCircle(const Offset(20.8, 3.0), 1.3, fillPaint);

    // 5. Red Cricket Ball at Release Point
    const ballCenter = Offset(24.2, 2.2);
    canvas.drawCircle(ballCenter, 2.4, ballPaint);
    // White seam stitch
    canvas.drawLine(
      const Offset(22.8, 1.2),
      const Offset(25.6, 3.2),
      whiteDetail,
    );
    // Dynamic release motion arc
    final motionArc = Path()
      ..moveTo(18.5, 1.0)
      ..quadraticBezierTo(21.0, -0.5, 23.5, 0.0);
    canvas.drawPath(motionArc, motionPaint);

    // 6. Front Landing Leg (Planted firmly at popping crease)
    final frontLeg = Path()
      ..moveTo(13.0, 19.0)
      ..lineTo(9.5, 23.5)
      ..lineTo(7.5, 28.5);
    canvas.drawPath(frontLeg, limbStroke);

    // Front Cricket Spike Shoe
    final frontShoe = Path()
      ..moveTo(5.5, 28.5)
      ..lineTo(10.5, 28.5)
      ..lineTo(8.5, 29.5)
      ..lineTo(5.0, 29.5)
      ..close();
    canvas.drawPath(frontShoe, fillPaint);

    // 7. Back Right Leg (Airborne trail with high knee follow-through)
    final backLeg = Path()
      ..moveTo(15.5, 19.0)
      ..quadraticBezierTo(20.5, 21.0, 22.8, 22.5)
      ..lineTo(26.5, 21.0);
    canvas.drawPath(backLeg, limbStroke);

    // Back shoe trailing in air
    final backShoe = Path()
      ..moveTo(26.0, 20.2)
      ..lineTo(28.5, 20.0)
      ..lineTo(27.5, 21.8)
      ..close();
    canvas.drawPath(backShoe, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BowlingActionPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.ballColor != ballColor;
}