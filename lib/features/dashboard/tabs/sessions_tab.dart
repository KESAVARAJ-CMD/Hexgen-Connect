import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/hexgen_badge.dart';
import '../../../core/widgets/hexgen_button.dart';
import '../../../core/widgets/hexgen_card.dart';
import '../../../widgets/session_setup_dialog.dart';
import '../../live_analysis_screen.dart';
import '../../session/session_detail_screen.dart';

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
  int _selectedIndex = 1; // 0 = Upcoming, 1 = History

  static const _upcomingList = [
    {
      'id': 'BK-CRIC-77492',
      'title': 'Hexgen Sports Arena • Lane 1',
      'laneInfo': 'Right-Hand Lane 1, Shanthinagar, Bangalore',
      'dateTime': 'Tomorrow • 09:00 AM - 10:00 AM',
      'price': '₹ 1,830',
      'coach': 'Coach Madhu (Assigned)',
      'status': 'CONFIRMED',
      'laneStatus': 'Hardware Radar Ready',
    },
    {
      'id': 'BK-CRIC-77510',
      'title': 'Hexgen Sports Arena • Lane 2',
      'laneInfo': 'Lane 2, Shanthinagar, Bangalore',
      'dateTime': '22 Sep 2025 • 07:00 AM - 08:30 AM',
      'price': '₹ 1,830',
      'coach': 'Autonomous AI Machine Sync',
      'status': 'CONFIRMED',
      'laneStatus': 'Calibration Passed',
    },
  ];

  static const _historyList = [
    {
      'id': 'SES-U15S125',
      'title': 'Finding My Rhythm & High Elbow Drive',
      'date': 'Today • 06:00 PM',
      'lane': 'Right-Hand Lane 3 (Hexgen Turf)',
      'duration': '60 Mins',
      'coach': 'Coach Madhu',
      'clipsCount': '4 Telemetry Clips',
      'status': 'FEEDBACK READY',
      'peakVelo': '142.4 km/h',
      'accuracy': '94%',
      'formRating': '9.6',
    },
    {
      'id': 'SES-U15S121',
      'title': 'Pace Attack & Line Alignment',
      'date': '12 Sep 2025 • 07:00 AM',
      'lane': 'Lane 1 (Hexgen Turf)',
      'duration': '45 Mins',
      'coach': 'Coach Rahul Menon',
      'clipsCount': '2 Telemetry Clips',
      'status': 'REVIEWED',
      'peakVelo': '138.8 km/h',
      'accuracy': '89%',
      'formRating': '9.1',
    },
    {
      'id': 'SES-U15S120',
      'title': 'Front-Foot Foundations & Balance',
      'date': '10 Sep 2025 • 06:30 PM',
      'lane': 'Lane 2 (Synthetic Turf)',
      'duration': '60 Mins',
      'coach': 'Coach Priya Sharma',
      'clipsCount': '3 Telemetry Clips',
      'status': 'REVIEWED',
      'peakVelo': '134.2 km/h',
      'accuracy': '86%',
      'formRating': '8.8',
    },
  ];

  void _launchLiveSession() async {
    final result = await SessionSetupDialog.show(context);
    if (result != null && mounted) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => LiveAnalysisScreen(
            mode: AnalysisMode.biomechanics,
            sessionConfig: result,
            playerName: 'Athlete',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = _selectedIndex == 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── 1. Top Segmented Selector (Upcoming / History) ─────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C3E78).withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          gradient: isUpcoming ? AppTheme.primaryCtaGradient : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isUpcoming
                              ? [
                                  BoxShadow(
                                    color: AppTheme.royalBlue.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: isUpcoming ? Colors.white : AppTheme.navyBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'UPCOMING (${_upcomingList.length})',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  color: isUpcoming ? Colors.white : AppTheme.navyBlue,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          gradient: !isUpcoming ? AppTheme.primaryCtaGradient : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: !isUpcoming
                              ? [
                                  BoxShadow(
                                    color: AppTheme.royalBlue.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 15,
                                color: !isUpcoming ? Colors.white : AppTheme.navyBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'SESSION HISTORY',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  color: !isUpcoming ? Colors.white : AppTheme.navyBlue,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

          // ── 2. Content List with Quick Launch Live Card & Metrics ──────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: isUpcoming
                  ? _buildUpcomingList(key: const ValueKey('upcoming'))
                  : _buildHistoryList(key: const ValueKey('history')),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Live Session HUD Action Banner ────────────────────────────────────
  Widget _buildLiveLaunchCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0038B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0057FF).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar_rounded, size: 12, color: Color(0xFF00E676)),
                    SizedBox(width: 4),
                    Text(
                      'AI POSE SENSOR READY',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E676),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '60 FPS TELEMETRY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Quick Launch Live Practice HUD ⚡',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Connect in-lane cameras for instant bat velocity, sweet spot index & pose alignment.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFFCBD5E1),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _launchLiveSession,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryCtaGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'CALIBRATE & LAUNCH SESSION',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.4,
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

  // ── Telemetry KPI Snapshot Bar ──────────────────────────────────────────────
  Widget _buildTelemetryKpiBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyBlue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildKpiItem('PEAK SPEED', '142.4', 'km/h', const Color(0xFF0057FF)),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          _buildKpiItem('ACCURACY', '94%', 'Sweet Spot', const Color(0xFF10B981)),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          _buildKpiItem('FORM RATING', '9.6', 'out of 10', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, String unit, Color accent) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.slateBlue,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.slateBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Upcoming Sessions List ─────────────────────────────────────────────────
  Widget _buildUpcomingList({required Key key}) {
    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        _buildLiveLaunchCard(),
        ..._upcomingList.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: HexgenCard(
              hasGlow: true,
              hasTopAccent: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['id']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: AppTheme.slateBlue,
                          letterSpacing: 0.6,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['laneStatus']!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.slateBlue),
                      const SizedBox(width: 4),
                      Text(
                        item['dateTime']!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.slateBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.slateBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['laneInfo']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.slateBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['coach']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: HexgenButton(
                          text: 'Start Practice ⚡',
                          height: 38,
                          fontSize: 11,
                          onPressed: _launchLiveSession,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: HexgenButton(
                          text: item['price']!,
                          isOutlined: true,
                          height: 38,
                          fontSize: 11,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── History Sessions List with Telemetry Metrics ───────────────────────────
  Widget _buildHistoryList({required Key key}) {
    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        _buildLiveLaunchCard(),
        _buildTelemetryKpiBar(),
        ..._historyList.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: HexgenCard(
              hasGlow: true,
              hasTopAccent: index == 0,
              onTap: () => _openSession(context, item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HexgenBadge(
                        label: item['id']!,
                        variant: HexgenBadgeVariant.primary,
                        fontSize: 9,
                      ),
                      HexgenBadge(
                        label: item['status']!,
                        variant: index == 0
                            ? HexgenBadgeVariant.volt
                            : HexgenBadgeVariant.gold,
                        fontSize: 8.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['date']} • ${item['lane']}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.slateBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── AI Telemetry Snapshot Badges ───────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.iceBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD6E8FD)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 13, color: AppTheme.electricBlue),
                            const SizedBox(width: 3),
                            Text(
                              item['peakVelo']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.adjust_rounded, size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 3),
                            Text(
                              '${item['accuracy']} Sweet Spot',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              item['formRating']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.navyBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: HexgenButton(
                          text: 'Replay 60FPS Video 🎥',
                          height: 38,
                          fontSize: 11,
                          onPressed: () => _openSession(context, item),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: HexgenButton(
                          text: 'View Telemetry 📊',
                          isOutlined: true,
                          height: 38,
                          fontSize: 11,
                          onPressed: () => _openSession(context, item),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _openSession(BuildContext context, Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionDetailScreen(
          sessionId: item['id']!,
          title: item['title']!,
          date: item['date']!,
          court: item['lane']!,
          coach: item['coach']!,
          videos: const [
            {
              'title': 'Over 01 - Cover Drive High Elbow',
              'duration': '02:45',
              'angle': 'Stumps Cam',
            },
            {
              'title': 'Over 02 - In-Swing Defense',
              'duration': '01:30',
              'angle': 'Side Cam',
            },
          ],
          config: const {
            'courtType': 'Turf Pitch',
            'cameraAngles': '3 Hardware HexCams',
            'ballType': 'Kookaburra Red Leather',
            'aiTracking': 'Active',
          },
        ),
      ),
    );
  }
}
