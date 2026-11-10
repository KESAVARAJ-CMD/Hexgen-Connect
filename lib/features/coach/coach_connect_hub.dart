import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../models/pose_data.dart';
import '../../screens/my_bookings_screen.dart';
import '../../services/demo_state.dart';
import '../../widgets/skeleton_painter.dart';
import 'view_coach_profile_screen.dart';
import 'coach_feedback_screen.dart';

class CoachConnectHub extends StatefulWidget {
  final bool showBackButton;
  const CoachConnectHub({super.key, this.showBackButton = true});

  @override
  State<CoachConnectHub> createState() => _CoachConnectHubState();
}

class _CoachConnectHubState extends State<CoachConnectHub> {
  final DemoState _state = DemoState();
  int _selectedTab = 0; // 0: Coaches List, 1: Coach Feedback
  final TextEditingController _handleController = TextEditingController();
  String _searchHandle = '';

  void _openCoachBookingModal(BuildContext context, Map<String, dynamic> coach) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CoachBookingBottomSheet(coach: coach),
    );
  }

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _handleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      children: [
        // Header Selector (Rendered on iceBlue when embedded, or inside Dark Canopy when standalone)
        if (!widget.showBackButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navyBlue.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: _selectedTab == 0 ? AppTheme.primaryCtaGradient : null,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Center(
                            child: Text(
                              'COACHES LIST',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: _selectedTab == 0 ? Colors.white : AppTheme.navyBlue,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: _selectedTab == 1 ? AppTheme.primaryCtaGradient : null,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Center(
                            child: Text(
                              'COACH FEEDBACK',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: _selectedTab == 1 ? Colors.white : AppTheme.navyBlue,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryCtaGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'HEXGEN CONNECT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 2-Tab Segmented Selector
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(19),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'COACHES LIST',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                        color: _selectedTab == 0 ? AppTheme.navyBlue : Colors.white,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(19),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'COACH FEEDBACK',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                        color: _selectedTab == 1 ? AppTheme.navyBlue : Colors.white,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
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
            ),

          // Body Content based on selected tab
          Expanded(
            child: _selectedTab == 0 ? _buildCoachesListTab() : _buildCoachFeedbackTab(),
          ),
        ],
      );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.showBackButton ? CyberGlassBackdrop(child: content) : content,
    );
  }

  Widget _buildCoachesListTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        // Search Box
        Container(
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
            boxShadow: HexgenColors.cardShadow(opacity: 0.06),
          ),
          child: TextField(
            controller: _handleController,
            onChanged: (v) => setState(() => _searchHandle = v),
            style: const TextStyle(color: AppTheme.navyBlue, fontSize: 13, fontFamily: 'Roboto'),
            decoration: const InputDecoration(
              hintText: 'Search Coach ID e.g. @coach.madhu...',
              hintStyle: TextStyle(color: AppTheme.slateBlue, fontSize: 12, fontFamily: 'Roboto'),
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.electricBlue, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'AVAILABLE COACHES',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            letterSpacing: 0.8,
            fontFamily: 'Roboto',
          ),
        ),

        const SizedBox(height: 12),

        // Directory List
        Builder(
          builder: (context) {
            final filtered = _state.verifiedCoaches.where((c) {
              final h = (c['handle'] as String).toLowerCase();
              final n = (c['name'] as String).toLowerCase();
              final q = _searchHandle.toLowerCase();
              return h.contains(q) || n.contains(q);
            }).toList();

            if (filtered.isEmpty) {
              return HexgenCard(
                padding: const EdgeInsets.all(32),
                child: const Center(
                  child: Text(
                    'NO VERIFIED COACH FOUND WITH THAT HANDLE',
                    style: TextStyle(
                      color: AppTheme.slateBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: filtered.map((coach) {
                final String cName = coach['name'] as String;
                final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: HexgenCard(
                    hasGlow: true,
                    hasTopAccent: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewCoachProfileScreen(coach: coach),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.electricBlue,
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          cName,
                                          style: const TextStyle(
                                            color: AppTheme.navyBlue,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        Text(
                                          coach['rating'],
                                          style: const TextStyle(
                                            color: AppTheme.navyBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${coach['handle']} • ${coach['role']} (Tap to View Profile)',
                                      style: const TextStyle(
                                        color: AppTheme.slateBlue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: HexgenColors.voltGreen, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  coach['status'],
                                  style: const TextStyle(
                                    color: HexgenColors.voltGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              coach['experience'],
                              style: const TextStyle(
                                color: AppTheme.slateBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewCoachProfileScreen(coach: coach),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.electricBlue),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'VIEW PROFILE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.electricBlue,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: HexgenButton(
                                text: 'BOOK 1-ON-1 ⚡',
                                icon: Icons.calendar_month_rounded,
                                onPressed: () => _openCoachBookingModal(context, coach),
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
          },
        ),
      ],
    );
  }

  Widget _buildCoachFeedbackTab() {
    final reviews = List<Map<String, dynamic>>.from(_state.allReviews);
    if (_state.status == ReviewStatus.pending) {
      reviews.insert(0, {
        'coachName': _state.activeCoachName,
        'coachHandle': _state.activeCoachHandle,
        'date': 'PENDING • JUST NOW',
        'session': 'SESSION NEW • IN QUEUE',
        'status': 'PENDING',
        'focus': 'Awaiting biomechanical pose telemetry review by ${_state.activeCoachName}.',
        'drill': 'Shadow Practice & Stance Hold',
      });
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        // Header info about review requests
        HexgenCard(
          hasGlow: true,
          hasTopAccent: true,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorderColor),
                ),
                child: const Icon(Icons.rate_review_rounded, color: AppTheme.electricBlue, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUBMITTED REVIEW REQUESTS',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap any request to open full technical feedback report.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.slateBlue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              HexgenBadge(
                label: '${reviews.length} TOTAL',
                variant: HexgenBadgeVariant.volt,
                fontSize: 8.5,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ...reviews.map((r) {
          final bool isPending = r['status'] == 'PENDING';
          final String cName = r['coachName'] ?? 'Coach';
          final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: HexgenCard(
              hasGlow: true,
              hasTopAccent: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoachFeedbackScreen()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.electricBlue,
                        child: Text(
                          initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Roboto'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
                            Text('${r['coachHandle']} • ${r['session']}', style: const TextStyle(fontSize: 10.5, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
                          ],
                        ),
                      ),
                      HexgenBadge(
                        label: r['status'] ?? 'PUBLISHED',
                        variant: isPending ? HexgenBadgeVariant.volt : HexgenBadgeVariant.volt,
                        fontSize: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    r['focus'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppTheme.navyBlue, height: 1.4, fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r['date'] ?? '', style: const TextStyle(fontSize: 9.5, color: AppTheme.slateBlue, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                      const Row(
                        children: [
                          Text('Open Report', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, fontFamily: 'Roboto')),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.electricBlue),
                        ],
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

}

// QUEUING & PIPELINE CONNECTING SCREEN
class CoachQueueScreen extends StatefulWidget {
  final Map<String, dynamic> coach;
  const CoachQueueScreen({super.key, required this.coach});

  @override
  State<CoachQueueScreen> createState() => _CoachQueueScreenState();
}

class _CoachQueueScreenState extends State<CoachQueueScreen> {
  int _step = 0;
  final List<String> _steps = [
    'QUEUING IN NEURAL LINE...',
    'PROCESSING SESSION METRICS...',
    'ESTABLISHING SECURE LINK...',
    'LINK ESTABLISHED! CONNECTING...'
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPipeline();
  }

  void _startPipeline() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      if (_step < _steps.length - 1) {
        setState(() => _step++);
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LiveCoachVideoCallScreen(coach: widget.coach)),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String cName = widget.coach['name'] as String;
    final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120, height: 120,
                    child: CircularProgressIndicator(
                      value: (_step + 1) / _steps.length,
                      strokeWidth: 4,
                      color: AppTheme.electricBlue,
                      backgroundColor: AppTheme.lightBlue,
                    ),
                  ),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.electricBlue,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                cName,
                style: const TextStyle(color: AppTheme.navyBlue, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.coach['handle']} • ${widget.coach['role']}',
                style: const TextStyle(color: AppTheme.slateBlue, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
              ),
              const SizedBox(height: 36),

              HexgenBadge(
                label: _steps[_step],
                variant: HexgenBadgeVariant.primary,
                fontSize: 11,
              ),

              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL REQUEST',
                  style: TextStyle(color: AppTheme.slateBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, fontFamily: 'Roboto'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// LIVE VIDEO CALL WITH COACH
class LiveCoachVideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> coach;
  const LiveCoachVideoCallScreen({super.key, required this.coach});

  @override
  State<LiveCoachVideoCallScreen> createState() => _LiveCoachVideoCallScreenState();
}

class _LiveCoachVideoCallScreenState extends State<LiveCoachVideoCallScreen> {
  bool _isMuted = false;
  bool _isCamOn = true;

  final Map<String, Keypoint> _mockKeypoints = const {
    'nose': Keypoint(x: .5, y: .16, z: 0, score: .95),
    'l_shoulder': Keypoint(x: .43, y: .28, z: 0, score: .95),
    'r_shoulder': Keypoint(x: .57, y: .28, z: 0, score: .95),
    'l_elbow': Keypoint(x: .34, y: .42, z: 0, score: .9),
    'r_elbow': Keypoint(x: .66, y: .42, z: 0, score: .9),
    'l_wrist': Keypoint(x: .3, y: .54, z: 0, score: .9),
    'r_wrist': Keypoint(x: .7, y: .54, z: 0, score: .9),
    'l_hip': Keypoint(x: .46, y: .53, z: 0, score: .95),
    'r_hip': Keypoint(x: .54, y: .53, z: 0, score: .95),
    'l_knee': Keypoint(x: .44, y: .68, z: 0, score: .9),
    'r_knee': Keypoint(x: .56, y: .68, z: 0, score: .9),
    'l_ankle': Keypoint(x: .42, y: .84, z: 0, score: .9),
    'r_ankle': Keypoint(x: .58, y: .84, z: 0, score: .9),
    'l_heel': Keypoint(x: .4, y: .86, z: 0, score: .9),
    'r_heel': Keypoint(x: .56, y: .86, z: 0, score: .9),
    'l_foot': Keypoint(x: .34, y: .87, z: 0, score: .9),
    'r_foot': Keypoint(x: .64, y: .87, z: 0, score: .9),
  };

  @override
  Widget build(BuildContext context) {
    final String cName = widget.coach['name'] as String;
    final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: AppTheme.navyBlue,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.sports_cricket_rounded,
                      size: 100,
                      color: AppTheme.cyanBlue.withValues(alpha: 0.4),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SkeletonPainter(keypoints: _mockKeypoints, color: HexgenColors.voltGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 6),
                          Text(
                            'LIVE REVIEW • 02:45',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 90, height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.electricBlue, width: 2),
                        boxShadow: HexgenColors.cardShadow(opacity: 0.2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            initials,
                            style: const TextStyle(color: AppTheme.navyBlue, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
                          ),
                          Positioned(
                            bottom: 6, left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.navyBlue, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                cName.split(' ')[0],
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
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
          ),
          Positioned(
            left: 18, right: 18, bottom: 20,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HexgenCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.record_voice_over_rounded, color: HexgenColors.voltGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(widget.coach['handle'] as String).toUpperCase()} AUDIO FEED',
                                style: const TextStyle(color: AppTheme.electricBlue, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '"Watch your front shoulder on release. Keep your head centered over ball line."',
                                style: TextStyle(color: AppTheme.navyBlue, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Roboto'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                      boxShadow: HexgenColors.cardShadow(opacity: 0.15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded, color: AppTheme.navyBlue),
                          onPressed: () => setState(() => _isMuted = !_isMuted),
                        ),
                        IconButton(
                          icon: Icon(_isCamOn ? Icons.videocam_rounded : Icons.videocam_off_rounded, color: AppTheme.navyBlue),
                          onPressed: () => setState(() => _isCamOn = !_isCamOn),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session ended. Feedback saved to Dashboard.')));
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.call_end_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'END LINK',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// ── Coach 1-on-1 Booking Bottom Sheet Modal ──────────────────────────────────
class _CoachBookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> coach;
  const _CoachBookingBottomSheet({required this.coach});

  @override
  State<_CoachBookingBottomSheet> createState() => _CoachBookingBottomSheetState();
}

class _CoachBookingBottomSheetState extends State<_CoachBookingBottomSheet> {
  int _selectedFocusIndex = 0;
  int _selectedSlotIndex = 0;
  bool _isBooking = false;

  final List<String> _focusOptions = const [
    '🏏 Bat Swing Arc & High Elbow Drive',
    '⚡ Fast Bowling Seam & Kinetic Chain',
    '🎯 Spin Rotation & Trajectory Analysis',
    '📊 Match Situation Biomechanics Strategy',
  ];

  final List<Map<String, String>> _slots = const [
    {'date': 'Today', 'time': '06:00 PM - 07:00 PM', 'label': 'Evening Slot'},
    {'date': 'Tomorrow', 'time': '09:30 AM - 10:30 AM', 'label': 'Morning Slot'},
    {'date': 'Tomorrow', 'time': '05:00 PM - 06:00 PM', 'label': 'Prime Slot'},
    {'date': '24 Sep', 'time': '07:00 PM - 08:00 PM', 'label': 'Night Radar'},
  ];

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);
    final coachName = widget.coach['name'] as String? ?? 'Coach Madhu';
    final coachHandle = widget.coach['handle'] as String? ?? '@coach.madhu';
    final coachRole = widget.coach['role'] as String? ?? 'Mentor';
    final slot = _slots[_selectedSlotIndex];
    final focus = _focusOptions[_selectedFocusIndex];

    final res = await ApiService().createBooking(
      venueId: 'v1_coach',
      date: '${slot['date']} • ${slot['time']}',
      timeSlots: [slot['time']!],
      totalAmount: 800.0,
      paymentMethod: 'UPI',
      athleteDetails: {
        'coach': '$coachName ($coachRole)',
        'coachHandle': coachHandle,
        'focus': focus,
        'lane': 'Private Mentorship Lane • 60FPS AI Camera',
      },
    );

    if (!mounted) return;
    setState(() => _isBooking = false);
    Navigator.pop(context); // Close sheet

    final bookingId = res['booking']?['bookingId'] ?? 'HEX-CH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Show Confirmed Success Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '1-on-1 Session Confirmed!',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.iceBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.electricBlue,
                        child: Text(
                          coachName.replaceAll('Coach ', '')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coachName,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.navyBlue),
                            ),
                            Text(
                              coachHandle,
                              style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Text('• Pass ID: $bookingId', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.electricBlue)),
                  const SizedBox(height: 3),
                  Text('• Timing: ${slot['date']} • ${slot['time']}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.navyBlue)),
                  const SizedBox(height: 3),
                  Text('• Topic: $focus', style: const TextStyle(fontSize: 11.5, color: AppTheme.slateBlue)),
                  const SizedBox(height: 3),
                  const Text('• Arena: Hexgen Sports Arena (Private Bay 01)', style: TextStyle(fontSize: 11.5, color: AppTheme.slateBlue)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss', style: TextStyle(color: AppTheme.slateBlue, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.electricBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View in My Bookings ⚡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachName = widget.coach['name'] as String? ?? 'Coach Madhu';
    final coachRole = widget.coach['role'] as String? ?? 'Mentor';
    final coachRating = widget.coach['rating'] as String? ?? '4.9 ★';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.electricBlue,
                      child: Text(
                        coachName.replaceAll('Coach ', '')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coachName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                        ),
                        Text(
                          '$coachRole • $coachRating',
                          style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              '1. SELECT SESSION FOCUS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            ...List.generate(_focusOptions.length, (idx) {
              final isSel = _selectedFocusIndex == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedFocusIndex = idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFE0F2FE) : AppTheme.iceBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? AppTheme.electricBlue : AppTheme.cardBorderColor, width: isSel ? 1.5 : 1.0),
                  ),
                  child: Row(
                    children: [
                      Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: isSel ? AppTheme.electricBlue : AppTheme.slateBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _focusOptions[idx],
                          style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: AppTheme.navyBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            const Text(
              '2. SELECT TIME SLOT',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_slots.length, (idx) {
                final isSel = _selectedSlotIndex == idx;
                final slot = _slots[idx];
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlotIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.electricBlue : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? AppTheme.electricBlue : AppTheme.cardBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['date']!,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSel ? Colors.white70 : AppTheme.slateBlue),
                        ),
                        Text(
                          slot['time']!,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: isSel ? Colors.white : AppTheme.navyBlue),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorderColor),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1-on-1 Mentorship Fee', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.navyBlue)),
                      Text('Includes 60fps AI Pose report', style: TextStyle(fontSize: 9.5, color: AppTheme.slateBlue)),
                    ],
                  ),
                  Text('₹ 800', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.electricBlue)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HexgenButton(
              text: _isBooking ? 'CONFIRMING WITH COACH...' : 'CONFIRM 1-ON-1 BOOKING ⚡',
              icon: _isBooking ? null : Icons.flash_on_rounded,
              onPressed: _isBooking ? null : _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}
