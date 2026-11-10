import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../models/pose_data.dart';
import '../../widgets/session_video_stage.dart';

const String _sessionVideoAsset = 'assets/U15S125O3B1.mp4';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId, title, date, court, coach;
  final List<Map<String, String>> videos;
  final Map<String, String> config;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.title,
    required this.date,
    required this.court,
    required this.coach,
    required this.videos,
    required this.config,
  });

  static const _pace = [
    {
      'over': 'OVER 01',
      'summary': '6 Balls • 112 km/h • Off stump',
      'speed': '112 km/h',
      'line': 'Off stump',
      'length': 'Good length',
      'swing': '2.4° away',
    },
    {
      'over': 'OVER 02',
      'summary': '6 Balls • 108 km/h • Middle & off',
      'speed': '108 km/h',
      'line': 'Middle & off',
      'length': 'Full',
      'swing': '1.8° in',
    },
  ];

  static const _spin = [
    {
      'over': 'OVER 03',
      'summary': '6 Balls • 78 km/h • Flighted',
      'speed': '78 km/h',
      'line': 'Outside off',
      'length': 'Flighted',
      'swing': '5.2° turn',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.pop(context), title: title),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    _QuickStats(date: date, clips: videos.length),
                    const SizedBox(height: 16),
                    const _SectionLabel('DELIVERY BREAKDOWN', trailing: '03 OVERS'),
                    const SizedBox(height: 10),
                    const _CategoryLabel(
                      icon: Icons.bolt_rounded,
                      title: 'PACE ATTACK',
                      count: '2 OVERS',
                      color: AppTheme.electricBlue,
                    ),
                    ..._pace.map((o) => _OverCard(
                          over: o,
                          accent: AppTheme.electricBlue,
                        )),
                    const SizedBox(height: 12),
                    const _CategoryLabel(
                      icon: Icons.rotate_right_rounded,
                      title: 'SPIN ATTACK',
                      count: '1 OVER',
                      color: AppTheme.royalBlue,
                    ),
                    ..._spin.map((o) => _OverCard(
                          over: o,
                          accent: AppTheme.royalBlue,
                        )),
                    const SizedBox(height: 16),
                    const _SectionLabel('SESSION SETUP'),
                    const SizedBox(height: 10),
                    _SessionSetupGrid(config: config),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverDetailScreen extends StatelessWidget {
  final Map<String, String> over;
  final Color accent;

  const OverDetailScreen({
    super.key,
    required this.over,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final overName = over['over'] ?? 'OVER';
    final balls = [
      {'ball': 'Ball 1', 'title': '$overName - Ball 1 (Defended)', 'duration': '00:24', 'angle': 'Stumps Cam'},
      {'ball': 'Ball 2', 'title': '$overName - Ball 2 (Leave)', 'duration': '00:20', 'angle': 'Side Cam'},
      {'ball': 'Ball 3', 'title': '$overName - Ball 3 (Cover Drive)', 'duration': '00:32', 'angle': 'Stumps Cam'},
      {'ball': 'Ball 4', 'title': '$overName - Ball 4 (Beaten)', 'duration': '00:25', 'angle': 'Side Cam'},
      {'ball': 'Ball 5', 'title': '$overName - Ball 5 (Single)', 'duration': '00:22', 'angle': 'Stumps Cam'},
      {'ball': 'Ball 6', 'title': '$overName - Ball 6 (Defended)', 'duration': '00:30', 'angle': 'Side Cam'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.pop(context), title: overName),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.sports_cricket_rounded, color: accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  overName,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '6 Balls • 0 Wickets • 4 Runs',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.slateBlue,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppTheme.cardBorderColor, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _metricItem('SPEED', over['speed'] ?? '112 km/h'),
                          _metricItem('LINE', over['line'] ?? 'Off stump'),
                          _metricItem('LENGTH', over['length'] ?? 'Good length'),
                          _metricItem('SWING', over['swing'] ?? '2.4° away'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionLabel('DELIVERIES', trailing: '6 BALLS'),
                const SizedBox(height: 10),
                ...balls.asMap().entries.map((e) {
                  final ball = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClipAnalysisScreen(
                              title: ball['title']!,
                              duration: ball['duration']!,
                              angle: ball['angle']!,
                              metrics: over,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${e.key + 1}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: accent,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ball['title']!,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.navyBlue,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ball['angle']}  •  ${ball['duration']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.slateBlue,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.play_circle_fill_rounded,
                                color: AppTheme.electricBlue, size: 28),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _metricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppTheme.slateBlue,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}

class ClipAnalysisScreen extends StatefulWidget {
  final String title, duration, angle;
  final Map<String, String> metrics;

  const ClipAnalysisScreen({
    super.key,
    required this.title,
    required this.duration,
    required this.angle,
    required this.metrics,
  });

  @override
  State<ClipAnalysisScreen> createState() => _ClipAnalysisScreenState();
}

class _ClipAnalysisScreenState extends State<ClipAnalysisScreen> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('RELEASE SPEED', widget.metrics['speed'] ?? '112 km/h', Icons.speed_rounded),
      ('LINE', widget.metrics['line'] ?? 'Off stump', Icons.align_horizontal_left_rounded),
      ('LENGTH', widget.metrics['length'] ?? 'Good length', Icons.straighten_rounded),
      ('SWING / TURN', widget.metrics['swing'] ?? '2.4° away', Icons.trending_up_rounded),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.pop(context), title: 'Clip Analysis'),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    SessionVideoStage(
                      assetPath: _sessionVideoAsset,
                      keypoints: sampleSessionPose(),
                      title: widget.title,
                      subtitle: '${widget.angle.toUpperCase()}  •  ${widget.duration}',
                      height: 200,
                      compact: true,
                    ),
                    const SizedBox(height: 16),
                    const _SectionLabel('BIOMECHANICS'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                  child: Column(
                    children: rows
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.iceBlue,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.cardBorderColor),
                                  ),
                                  child: Icon(r.$3, color: AppTheme.electricBlue, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    r.$1,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.slateBlue,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                                Text(
                                  r.$2,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryCtaGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _requested = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Coach review requested for “${widget.title}”.')),
                      );
                    },
                    icon: Icon(
                      _requested ? Icons.check_circle_rounded : Icons.rate_review_rounded,
                    ),
                    label: Text(
                      _requested ? 'REVIEW REQUESTED' : 'REQUEST COACH REVIEW',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final String title;

  const _Header({required this.onBack, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.navyBlue.withAlpha(12),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.navyBlue,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.navyBlue,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontFamily: 'Roboto',
                  ),
                ),
                const Text(
                  'TELEMETRY & HUD BREAKDOWN',
                  style: TextStyle(
                    color: AppTheme.slateBlue,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final String date;
  final int clips;

  const _QuickStats({required this.date, required this.clips});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _stat(Icons.event_rounded, date, 'Date')),
        const SizedBox(width: 8),
        Expanded(child: _stat(Icons.videocam_rounded, '$clips Telemetry', 'Captured')),
        const SizedBox(width: 8),
        Expanded(child: _stat(Icons.timer_rounded, '60 Mins', 'On Pitch')),
      ],
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.electricBlue),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.navyBlue,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppTheme.slateBlue,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;

  const _SectionLabel(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppTheme.navyBlue,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.iceBlue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.lightBlue),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.electricBlue,
                fontFamily: 'Roboto',
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color color;

  const _CategoryLabel({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count,
            style: const TextStyle(
              color: AppTheme.slateBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

class _OverCard extends StatelessWidget {
  final Map<String, String> over;
  final Color accent;

  const _OverCard({
    required this.over,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OverDetailScreen(
                over: over,
                accent: accent,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sports_cricket_rounded, color: accent, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      over['over']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        fontSize: 13.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      over['summary'] ?? '6 Balls • Tap to view deliveries',
                      style: const TextStyle(
                        color: AppTheme.slateBlue,
                        fontSize: 11.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.electricBlue, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean 2×2 organization of the session config fields only.
class _SessionSetupGrid extends StatelessWidget {
  final Map<String, String> config;

  const _SessionSetupGrid({required this.config});

  static const _order = [
    ('courtType', 'COURT TYPE', Icons.sports_cricket_rounded),
    ('cameraAngles', 'CAMERAS', Icons.videocam_rounded),
    ('ballType', 'BALL', Icons.sports_baseball_rounded),
    ('aiTracking', 'AI TRACKING', Icons.auto_awesome_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: _order.map((item) {
        final value = config[item.$1] ?? '—';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.$3, size: 18, color: AppTheme.electricBlue),
              const Spacer(),
              Text(
                item.$2,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppTheme.slateBlue,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Map<String, Keypoint> sampleSessionPose() => const {
      'nose': Keypoint(x: .5095, y: .3881, z: 1, score: 1),
      'l_shoulder': Keypoint(x: .5316, y: .4211, z: 1, score: 1),
      'r_shoulder': Keypoint(x: .5265, y: .3921, z: 1, score: 1),
      'l_elbow': Keypoint(x: .5382, y: .4792, z: 1, score: .8),
      'r_elbow': Keypoint(x: .5357, y: .4322, z: 1, score: .01),
      'l_wrist': Keypoint(x: .5185, y: .4604, z: 1, score: .54),
      'r_wrist': Keypoint(x: .5226, y: .4352, z: 1, score: .05),
      'l_hip': Keypoint(x: .5531, y: .4856, z: 1, score: 1),
      'r_hip': Keypoint(x: .5479, y: .4732, z: 1, score: 1),
      'l_knee': Keypoint(x: .5339, y: .5505, z: 1, score: .91),
      'r_knee': Keypoint(x: .5273, y: .5229, z: 1, score: .09),
      'l_ankle': Keypoint(x: .5418, y: .6224, z: 1, score: .96),
      'r_ankle': Keypoint(x: .5293, y: .5834, z: 1, score: .37),
      'l_heel': Keypoint(x: .5471, y: .6324, z: 1, score: .89),
      'r_heel': Keypoint(x: .5333, y: .5938, z: 1, score: .42),
      'l_foot': Keypoint(x: .5224, y: .6341, z: 1, score: .96),
      'r_foot': Keypoint(x: .513, y: .5933, z: 1, score: .45),
      'l_ear': Keypoint(x: .5194, y: .3801, z: 1, score: 1),
      'r_ear': Keypoint(x: .5132, y: .3789, z: 1, score: 1),
    };
