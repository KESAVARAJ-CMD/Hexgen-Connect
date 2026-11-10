import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../services/demo_state.dart';
import '../session/session_detail_screen.dart';
import 'coach_feedback_screen.dart';
import '../onboarding/role_selection_screen.dart';

class CoachDashboardScreen extends StatefulWidget {
  final String coachName;
  final String academyName;
  final String coachId;

  const CoachDashboardScreen({
    super.key,
    this.coachName = 'Coach Madhu',
    this.academyName = 'HexGen Sports Academy',
    this.coachId = 'CH-4092',
  });

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  int _selectedTab = 0; // 0: Pending Reviews, 1: Athletes, 2: Drills

  final List<Map<String, dynamic>> _pendingSubmissions = [
    {
      'id': 'SES-U15S125',
      'athlete': 'Arjun Kumar',
      'sessionTitle': 'High Elbow Front Foot Drive Analysis',
      'lane': 'Right-Hand Lane 3 (Hexgen Turf Arena)',
      'time': 'Today • 06:00 PM',
      'speed': '112 km/h Fast Seam',
      'status': 'PENDING REVIEW',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
    },
    {
      'id': 'SES-U15S128',
      'athlete': 'Rahul Kumar',
      'sessionTitle': 'Pace Defense & Stance Stability Hold',
      'lane': 'Lane 1 • Hybrid Synthetic Track',
      'time': 'Yesterday • 07:30 PM',
      'speed': '124 km/h In-Swinger',
      'status': 'PENDING REVIEW',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
    },
  ];

  final List<Map<String, dynamic>> _myAthletes = [
    {
      'name': 'Rahul Kumar',
      'handle': '@rahul.k',
      'level': 'Pro Athlete',
      'sessions': '14 Sessions',
      'avgSpeed': '124 km/h',
      'lastActive': 'Yesterday',
    },
    {
      'name': 'Arjun Kumar',
      'handle': '@arjun.crick',
      'level': 'Master Athlete',
      'sessions': '22 Sessions',
      'avgSpeed': '132 km/h',
      'lastActive': 'Today',
    },
    {
      'name': 'Dev Patel',
      'handle': '@dev.pace',
      'level': 'Pro Athlete',
      'sessions': '9 Sessions',
      'avgSpeed': '121 km/h',
      'lastActive': '2 days ago',
    },
    {
      'name': 'Rohan V.',
      'handle': '@rohan.strike',
      'level': 'Master Athlete',
      'sessions': '31 Sessions',
      'avgSpeed': '138 km/h',
      'lastActive': 'Today',
    },
  ];

  final List<Map<String, String>> _drillsLibrary = [
    {
      'title': '6 Slow Shadow Drives with High Elbow Focus',
      'focus': 'Maintain leading elbow extension pointed high towards mid-off during drive.',
      'reps': '3 Sets • 12 Reps',
      'target': 'Batting Biomechanics',
    },
    {
      'title': 'Brace Leg Stability Hold at Impact',
      'focus': 'Keep front leg firm on crease entry to prevent falling over to the off side.',
      'reps': '4 Sets • 10 Reps',
      'target': 'Balance & Kinetic Chain',
    },
    {
      'title': 'Cone Target In-Swing Defense',
      'focus': 'Drive hands through the ball with soft bottom wrist to control lateral movement.',
      'reps': '3 Sets • 15 Reps',
      'target': 'Pace Reaction',
    },
    {
      'title': 'Stationary Tee Striking & Head Stability',
      'focus': 'Ensure head stays directly vertically above impact point until follow-through.',
      'reps': '4 Sets • 8 Reps',
      'target': 'Core Balance',
    },
  ];

  void _openSessionReview(Map<String, dynamic> sub) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          sessionId: sub['id'] as String,
          title: sub['sessionTitle'] as String,
          date: sub['time'] as String,
          court: sub['lane'] as String,
          coach: widget.coachName,
          videos: const [
            {'angle': 'SIDE KINETIC CAM', 'resolution': '1080p 60fps'},
            {'angle': 'FRONT ANGLE CAM', 'resolution': '4K 60fps'},
          ],
          config: {
            'Speed': sub['speed'] as String,
            'Bowler': 'Autonomous Machine',
            'Telemetry': '60fps AI Pose Stream',
          },
        ),
      ),
    );
  }

  void _openGiveFeedback(Map<String, dynamic> sub) {
    _showFeedbackSubmissionModal(context, sub);
  }

  void _showFeedbackSubmissionModal(BuildContext context, Map<String, dynamic> sub) {
    final athleteName = sub['athlete'] ?? 'Athlete';
    final TextEditingController strengthCtrl = TextEditingController(
      text: 'Solid footwork transfer and high bat backlift cadence.',
    );
    final TextEditingController focusCtrl = TextEditingController(
      text: 'Keep leading elbow firmly elevated towards mid-off upon ball contact.',
    );
    final TextEditingController notesCtrl = TextEditingController(
      text: '• Impact Alignment: Maintain wrist brace firmly.\n• Follow-through: Do not pull bottom hand across the body prematurely.',
    );
    double rating = 4.8;
    String selectedDrill = '6 Slow Shadow Drives with High Elbow Focus';
    bool isAudioRecorded = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COACH FEEDBACK & RATING',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                            letterSpacing: 0.6,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          'Reviewing submission for $athleteName',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slateBlue,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Star Rating Slider
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.iceBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.lightBlue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Score: ${rating.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: rating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 8,
                          activeColor: const Color(0xFFF59E0B),
                          onChanged: (val) => setModalState(() => rating = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Strength Field
                const Text(
                  'OBSERVED STRENGTH',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF10B981), letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: strengthCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF0FDF4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navyBlue),
                ),
                const SizedBox(height: 14),

                // Primary Focus Area
                const Text(
                  'PRIMARY FOCUS & CORRECTION',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: focusCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.iceBlue,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navyBlue),
                ),
                const SizedBox(height: 14),

                // Audio Voice Note Simulation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAudioRecorded ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isAudioRecorded ? const Color(0xFF6EE7B7) : AppTheme.cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAudioRecorded ? Icons.check_circle_rounded : Icons.mic_rounded,
                        color: isAudioRecorded ? const Color(0xFF10B981) : AppTheme.electricBlue,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isAudioRecorded ? 'Voice Note Attached (0:48)' : 'Attach 60s Coach Audio Note',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isAudioRecorded ? const Color(0xFF065F46) : AppTheme.navyBlue,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => isAudioRecorded = !isAudioRecorded);
                        },
                        child: Text(
                          isAudioRecorded ? 'REMOVE' : 'RECORD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isAudioRecorded ? const Color(0xFFEF4444) : AppTheme.electricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Assigned Drill Dropdown
                const Text(
                  'ASSIGN SPECIFIC DRILL PLAN',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDrill,
                      isExpanded: true,
                      items: _drillsLibrary.map((d) {
                        return DropdownMenuItem<String>(
                          value: d['title']!,
                          child: Text(d['title']!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.navyBlue)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedDrill = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action CTA
                HexgenButton(
                  text: 'SUBMIT FEEDBACK & PUBLISH REPORT',
                  icon: Icons.send_rounded,
                  height: 48,
                  borderRadius: 16,
                  onPressed: () {
                    // Update state cleanly via DemoState
                    DemoState().publishFeedback(
                      strength: strengthCtrl.text.trim(),
                      focus: focusCtrl.text.trim(),
                      note: notesCtrl.text.trim(),
                      drill: selectedDrill,
                    );

                    // Remove from pending list
                    setState(() {
                      _pendingSubmissions.removeWhere((item) => item['id'] == sub['id']);
                    });

                    Navigator.pop(modalCtx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Feedback successfully published to $athleteName!'),
                        backgroundColor: AppTheme.navyBlue,
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'VIEW REPORT',
                          textColor: HexgenColors.voltGreen,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CoachFeedbackScreen()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MENTOR PORTAL',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.6,
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              widget.academyName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.slateBlue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.electricBlue),
            label: const Text(
              'EXIT PORTAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.electricBlue,
              ),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CyberGlassBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Coach Dossier Banner Card ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: HexgenCard(
                  hasGlow: true,
                  hasTopAccent: true,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.electricBlue,
                        child: Text(
                          widget.coachName.isNotEmpty ? widget.coachName[0].toUpperCase() : 'C',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.coachName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const HexgenBadge(
                                  label: 'VERIFIED MENTOR',
                                  variant: HexgenBadgeVariant.volt,
                                  fontSize: 8.5,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${widget.coachId} • Batting & Bowling Biomechanics',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.slateBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Mentor KPI Stat Strip ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: _buildKpiBox('2', 'Pending\nReviews', const Color(0xFFEF4444))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKpiBox('18', 'Enrolled\nAthletes', AppTheme.electricBlue)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKpiBox('6', 'Active\nDrills', const Color(0xFF10B981))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKpiBox('4.9★', 'Mentor\nRating', const Color(0xFFF59E0B))),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Segment Tab Selector ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(22),
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
                          Expanded(child: _buildTabButton(0, 'PENDING (${_pendingSubmissions.length})')),
                          Expanded(child: _buildTabButton(1, 'ATHLETES (${_myAthletes.length})')),
                          Expanded(child: _buildTabButton(2, 'DRILLS (${_drillsLibrary.length})')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Tab Body Content ──────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedTab == 0
                      ? _buildPendingSubmissionsList()
                      : (_selectedTab == 1 ? _buildAthletesList() : _buildDrillsLibraryList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiBox(String count, String label, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: accentColor,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateBlue,
              height: 1.2,
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryCtaGradient : null,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppTheme.slateBlue,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingSubmissionsList() {
    return ListView.builder(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _pendingSubmissions.length,
      itemBuilder: (context, index) {
        final sub = _pendingSubmissions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: HexgenCard(
            hasGlow: true,
            hasTopAccent: true,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(sub['avatar'] as String),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sub['athlete'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    const HexgenBadge(
                      label: 'IN REVIEW QUEUE',
                      variant: HexgenBadgeVariant.primary,
                      fontSize: 8.5,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sub['sessionTitle'] as String,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sub['time']}  •  ${sub['lane']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.slateBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                        label: const Text('WATCH 60FPS REPLAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        onPressed: () => _openSessionReview(sub),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.navyBlue,
                          side: const BorderSide(color: AppTheme.cardBorderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HexgenButton(
                        text: 'GIVE NOTES & DRILL',
                        icon: Icons.edit_note_rounded,
                        height: 40,
                        borderRadius: 12,
                        fontSize: 10.5,
                        onPressed: () => _openGiveFeedback(sub),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAthletesList() {
    return ListView.builder(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _myAthletes.length,
      itemBuilder: (context, index) {
        final a = _myAthletes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: HexgenCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.iceBlue,
                  child: Text(
                    a['name']![0],
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.electricBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            a['name']!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.iceBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              a['level']!,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.electricBlue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${a['sessions']}  •  Avg Speed: ${a['avgSpeed']}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _openGiveFeedback({'athlete': a['name']}),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.electricBlue,
                    side: const BorderSide(color: AppTheme.lightBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('ASSIGN DRILL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrillsLibraryList() {
    return ListView.builder(
      key: const ValueKey(2),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _drillsLibrary.length,
      itemBuilder: (context, index) {
        final drill = _drillsLibrary[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: HexgenCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        drill['title']!,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                      ),
                    ),
                    HexgenBadge(
                      label: drill['reps']!,
                      variant: HexgenBadgeVariant.volt,
                      fontSize: 8.5,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  drill['focus']!,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.slateBlue, height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target: ${drill['target']}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slateBlue),
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Drill "${drill['title']}" assigned to active squad!'),
                            backgroundColor: AppTheme.navyBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.iceBlue,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.lightBlue),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send_rounded, size: 12, color: AppTheme.electricBlue),
                            SizedBox(width: 4),
                            Text(
                              'ASSIGN TO ATHLETE',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppTheme.electricBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
