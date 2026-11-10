import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/hexgen_colors.dart';
import '../../../core/widgets/hexgen_card.dart';
import '../../../core/widgets/hexgen_hero_card.dart';
import '../../../core/widgets/hexgen_stat_box.dart';
import '../../../services/demo_state.dart';
import '../../coach/coach_connect_hub.dart';
import '../../live_analysis_screen.dart';
import '../../player/player_reviews_screen.dart';
import '../../subscription/subscription_paywall_screen.dart';

class OverviewTab extends StatefulWidget {
  final String playerName;
  final String playerId;
  final bool isSubscribed;
  final Function(int) onNavigateToTab;
  final VoidCallback onUnlockSubscription;

  const OverviewTab({
    super.key,
    required this.playerName,
    required this.playerId,
    required this.isSubscribed,
    required this.onNavigateToTab,
    required this.onUnlockSubscription,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final DemoState _state = DemoState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _showAnalysisChoiceModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha(220),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: HexgenColors.pureWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: HexgenColors.cardShadow(opacity: 0.2),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: HexgenColors.electricBlue.withAlpha(15), shape: BoxShape.circle),
                  child: const Icon(Icons.psychology_rounded, color: HexgenColors.electricBlue, size: 32),
                ),
                const SizedBox(height: 20),
                Text('NEURAL CAMERA ENGINE', style: GoogleFonts.inter(color: HexgenColors.electricBlue, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 6),
                Text('MODE SELECTION', style: GoogleFonts.inter(color: HexgenColors.navyBlue, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 28),

                _choiceItem(
                  context,
                  'BIOMECHANICS',
                  'Full body pose & kinetic chain tracking',
                  Icons.accessibility_new_rounded,
                  () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveAnalysisScreen(mode: AnalysisMode.biomechanics)));
                  },
                ),
                const SizedBox(height: 12),
                _choiceItem(
                  context,
                  '3D PITCH CALIBRATION',
                  '3D perspective surface grid mapping',
                  Icons.grid_view_rounded,
                  () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveAnalysisScreen(mode: AnalysisMode.pitchCalibration)));
                  },
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('CLOSE', style: GoogleFonts.inter(color: HexgenColors.slateBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceItem(BuildContext context, String title, String sub, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HexgenColors.iceBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HexgenColors.cardBorderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: HexgenColors.electricBlue.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: HexgenColors.electricBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(color: HexgenColors.navyBlue, fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(sub, style: GoogleFonts.inter(color: HexgenColors.slateBlue, fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: HexgenColors.slateBlue, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. HERO ATHLETE CARD
          HexgenHeroCard(
            playerName: widget.playerName,
            playerId: widget.playerId,
            isSubscribed: widget.isSubscribed,
            playerLevel: 14,
            currentXp: 3450,
            maxXp: 4000,
            ovrRating: 88,
            onBookTap: () => widget.onNavigateToTab(1),
            onHistoryTap: () {
              if (widget.isSubscribed) {
                widget.onNavigateToTab(2);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionPaywallScreen(
                      onSuccess: widget.onUnlockSubscription,
                    ),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 18),

          // Live Camera Analysis Launcher Banner
          GestureDetector(
            onTap: () => _showAnalysisChoiceModal(context),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryCtaGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: HexgenColors.electricBlue.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                    child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LIVE CAMERA ANALYSIS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text('Pose Biomechanics & 3D Pitch', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 2. TELEMETRY STATS — 2×2 Grid
          Row(
            children: [
              Expanded(
                child: HexgenStatBox(
                  title: 'Sessions',
                  value: '14',
                  icon: Icons.sports_cricket_rounded,
                  iconColor: AppTheme.electricBlue,
                  trend: '+3 Wk',
                  onTap: () => widget.onNavigateToTab(2),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: HexgenStatBox(
                  title: 'Top Speed',
                  value: '142.4 km/h',
                  icon: Icons.speed_rounded,
                  iconColor: AppTheme.royalBlue,
                  trend: 'PR',
                  onTap: () => widget.onNavigateToTab(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: HexgenStatBox(
                  title: 'OVR Index',
                  value: '88',
                  icon: Icons.insights_rounded,
                  iconColor: AppTheme.skyBlue,
                  trend: 'Top 5%',
                  onTap: () => widget.onNavigateToTab(4),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: HexgenStatBox(
                  title: 'Head Coach',
                  value: _state.activeCoachName.replaceAll('Coach ', ''),
                  icon: Icons.verified_user_rounded,
                  iconColor: AppTheme.navyBlue,
                  trend: 'Active',
                  onTap: () => widget.onNavigateToTab(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. MATCH PASS TICKET SECTION HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPCOMING CRICKET NET PASS',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab(1),
                child: Text(
                  'ALL SLOTS ➔',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.electricBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3b. MATCH PASS TICKET CARD
          Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navyBlue.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.iceBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.cardBorderColor),
                        ),
                        child: const Icon(Icons.sports_cricket_rounded, color: AppTheme.electricBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hexgen Turf • Right-Hand Lane 3',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Tomorrow  06:00 – 07:00 PM',
                              style: tt.bodySmall?.copyWith(
                                color: AppTheme.slateBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7F0),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          'CONFIRMED',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF047857),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 14), color: AppTheme.cardBorderColor),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 14, color: AppTheme.slateBlue),
                          const SizedBox(width: 5),
                          Text(
                            _state.activeCoachName,
                            style: tt.bodySmall?.copyWith(
                              color: AppTheme.navyBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => widget.onNavigateToTab(1),
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryCtaGradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'CHECK-IN',
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
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
            ),
          ),

          const SizedBox(height: 20),

          // 4. COACHING CORNER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR COACHING CORNER',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab(3),
                child: Text(
                  'CHANGE ➔',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.electricBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          HexgenCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: HexgenColors.electricBlue,
                      child: Text(
                        _state.activeCoachName.replaceAll('Coach ', '')[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_state.activeCoachName, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold, color: HexgenColors.navyBlue)),
                          Text('${_state.activeCoachHandle} • Batting & Telemetry Expert', style: GoogleFonts.dmSans(fontSize: 11, color: HexgenColors.slateBlue)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF00E676).withAlpha(15), borderRadius: BorderRadius.circular(6)),
                      child: Text('CONNECTED', style: GoogleFonts.dmSans(color: const Color(0xFF00E676), fontSize: 8, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: HexgenColors.iceBlue, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "“High elbow alignment on front foot drive. Maintain brace leg firmness on release.”",
                    style: GoogleFonts.dmSans(fontSize: 12, color: HexgenColors.navyBlue, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerReviewsScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: HexgenColors.iceBlue,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: HexgenColors.lightBlue),
                          ),
                          child: Center(
                            child: Text(
                              'Feedback Archive',
                              style: GoogleFonts.inter(color: HexgenColors.navyBlue, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachConnectHub()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryCtaGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Connect Live',
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                                ),
                              ],
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

          const SizedBox(height: 20),

          // 5. 30-DAY KINEMATIC MATRIX
          Text(
            '30-DAY KINEMATIC MATRIX',
            style: tt.labelSmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.navyBlue,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          HexgenCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('30-DAY ROLLING VELO', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w900, color: HexgenColors.electricBlue, letterSpacing: 1.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF00E676).withAlpha(20), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Color(0xFF00E676), size: 10),
                          const SizedBox(width: 4),
                          Text('+3.1% vs prev', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF00E676))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('142.4', style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: HexgenColors.navyBlue)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('PEAK VELO KM/H', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: HexgenColors.electricBlue)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50, width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(20, (i) => Container(
                      width: 4, height: 10 + (i % 7 * 6).toDouble(),
                      decoration: BoxDecoration(
                        color: i == 18 ? const Color(0xFF00E676) : HexgenColors.electricBlue.withAlpha(100),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
