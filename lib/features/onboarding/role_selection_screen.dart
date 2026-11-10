import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/onboarding_screen.dart';
import 'coach_setup_sheet.dart';

class RoleSelectionScreen extends StatefulWidget {
  static bool isFirstTimePlayer = true;

  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _selectedRoleIndex = 0; // 0: Player (Pro Athlete), 1: Coach (Academy Coach)
  int _selectedSportIndex = 0; // 0: Cricket by default

  static const String _bgPatternUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAdOdv4w8HJWhCfumwKzqU2omAHxpNWqqFdfDDPm74pdBwmpZJVjLcqiT-YtGmRxGIbhruVNdqHqxmPBmsUTUrQiWTlKeKuR8dXXF4FEl6A2P5rhjl9sU1S0A9DNNC7XeF3AkQRbtaJCSaaUPn54vdJ-lTYCzXZqamQ8zB5BaLeozqkAnwBReA2P4ipcukVOpQf2S8w6c42lTlKvwbBbAXRb3ViZiobzFzx0NsxHtzZife0qivtGH67';

  final List<Map<String, dynamic>> _sports = const [
    {'name': 'Cricket', 'icon': Icons.sports_cricket_rounded, 'emoji': '🏏'},
    {'name': 'Football', 'icon': Icons.sports_soccer_rounded, 'emoji': '⚽'},
    {'name': 'Badminton', 'icon': Icons.sports_tennis_rounded, 'emoji': '🏸'},
    {'name': 'Tennis', 'icon': Icons.sports_tennis_rounded, 'emoji': '🎾'},
    {'name': 'Pickleball', 'icon': Icons.sports_baseball_rounded, 'emoji': '🏓'},
    {'name': 'Basketball', 'icon': Icons.sports_basketball_rounded, 'emoji': '🏀'},
  ];

  void _openCoachSetupBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: const CoachSetupBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlayer = _selectedRoleIndex == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Stack(
        children: [
          // ── 1. Crisp Background Image Backdrop with Radial Gradient ────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.80, -0.90),
                  radius: 0.95,
                  colors: [
                    const Color(0xFF0066FF).withValues(alpha: 0.25),
                    const Color(0xFFE2EDFF).withValues(alpha: 0.85),
                    const Color(0xFFF3F7FF),
                  ],
                ),
              ),
              child: Image.network(
                _bgPatternUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ── 2. Glowing Ambient Orbs (Matching Other App Screens) ───────────
          // Cyber Cyan Glow Overlay (Top Right)
          Positioned(
            top: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0099FF).withValues(alpha: 0.28),
                ),
              ),
            ),
          ),

          // Cyber Cyan Glow Overlay (Bottom Right)
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0099FF).withValues(alpha: 0.28),
                ),
              ),
            ),
          ),

          // Cyber Blue Glow Overlay (Bottom Left)
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0066FF).withValues(alpha: 0.28),
                ),
              ),
            ),
          ),

          // ── 3. Main Screen Scrollable Content ──────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top Brand Header Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1C3E78).withValues(alpha: 0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'HEXGEN CONNECT',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                              letterSpacing: 0.8,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryCtaGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withValues(alpha: 0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'STEP 1 OF 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Section matching AppTheme
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppTheme.electricBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Select Your Arena Role',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.navyBlue,
                                letterSpacing: -0.4,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'Tailors smart court sensors, live ball radar & telemetry HUD.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.slateBlue,
                              fontFamily: 'Roboto',
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── 4. Role Selection Cards with Cyber Frosted Glass ──
                        // Card 1: Pro Athlete
                        _buildRoleCard(
                          index: 0,
                          title: 'Pro Athlete',
                          badge: 'PLAYER',
                          subtitle: 'Train, book smart lanes & analyze performance.',
                          imageAsset: 'assets/player.png',
                          features: const [
                            {'icon': Icons.speed_rounded, 'label': '60FPS\nBall Speed'},
                            {'icon': Icons.track_changes_rounded, 'label': 'Spin Radar'},
                            {'icon': Icons.insights_rounded, 'label': 'Live Leaderboards\n& Skill XP'},
                          ],
                          isSelected: isPlayer,
                        ),

                        const SizedBox(height: 14),

                        // Card 2: Academy Coach
                        _buildRoleCard(
                          index: 1,
                          title: 'Academy Coach',
                          badge: 'MENTOR',
                          subtitle: 'Manage athletes, drills & telemetry feedback.',
                          imageAsset: 'assets/coach.png',
                          features: const [
                            {'icon': Icons.groups_rounded, 'label': 'Team Roster &\nLive Tracking'},
                            {'icon': Icons.play_circle_filled_rounded, 'label': 'Custom Drills &\nRoutine Builder'},
                            {'icon': Icons.analytics_rounded, 'label': '60FPS Video\nTelemetry Analysis'},
                          ],
                          isSelected: !isPlayer,
                        ),

                        const SizedBox(height: 22),

                        // ── 5. Primary Sport Selection ─────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.electricBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CHOOSE PRIMARY SPORT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.navyBlue,
                                letterSpacing: 0.6,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Horizontal Scrolling Sports Pills
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _sports.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final sport = _sports[index];
                              final isSelected = _selectedSportIndex == index;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedSportIndex = index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                                        color: isSelected ? null : Colors.white.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : Colors.white.withValues(alpha: 0.85),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? AppTheme.electricBlue.withValues(alpha: 0.30)
                                                : const Color(0xFF1C3E78).withValues(alpha: 0.05),
                                            blurRadius: isSelected ? 8 : 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            sport['emoji'] as String,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            sport['name'] as String,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected ? Colors.white : AppTheme.navyBlue,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── 6. Autonomous Arena Calibration Banner (Cyber Frosted) ──
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.60),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1C3E78).withValues(alpha: 0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE).withValues(alpha: 0.80),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.sensors_rounded,
                                      color: AppTheme.electricBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Autonomous Arena Calibration',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.navyBlue,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: Color(0xFF10B981),
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '60FPS cameras & speed sensors automatically sync to your profile upon lane entry.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.slateBlue,
                                            height: 1.3,
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
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── 7. Primary Action Button ───────────────────────────
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: AppTheme.primaryCtaGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue.withValues(alpha: 0.38),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (isPlayer) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OnboardingScreen(),
                                  ),
                                );
                              } else {
                                _openCoachSetupBottomSheet(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isPlayer ? 'CONTINUE AS PRO ATHLETE' : 'CONTINUE AS ACADEMY COACH',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Role Card Builder with Cyber Frosted Glass & Theme Sync ─────────────────
  Widget _buildRoleCard({
    required int index,
    required String title,
    required String badge,
    required String subtitle,
    required String imageAsset,
    required List<Map<String, dynamic>> features,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRoleIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.electricBlue
                : Colors.white.withValues(alpha: 0.85),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.electricBlue.withValues(alpha: 0.25),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              )
            else
              BoxShadow(
                color: const Color(0xFF1C3E78).withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.60),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section: Left character image + Right info & selection radio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Character 3D Asset
                      Container(
                        width: 95,
                        height: 110,
                        alignment: Alignment.center,
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              index == 0 ? Icons.sports_cricket_rounded : Icons.sports_rounded,
                              size: 42,
                              color: AppTheme.electricBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Info Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    gradient: index == 0 ? AppTheme.primaryCtaGradient : null,
                                    color: index == 0 ? null : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: index == 0 ? Colors.white : AppTheme.slateBlue,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                                // Radio Check Circle
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppTheme.electricBlue : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.electricBlue : const Color(0xFFCBD5E1),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.navyBlue,
                                letterSpacing: -0.3,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.slateBlue,
                                height: 1.3,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Subtle horizontal divider line
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.70),
                  ),

                  const SizedBox(height: 10),

                  // 3 Feature items in a row
                  Row(
                    children: [
                      for (int i = 0; i < features.length; i++) ...[
                        if (i > 0)
                          Container(
                            width: 1,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: const Color(0xFFE2E8F0).withValues(alpha: 0.80),
                          ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                features[i]['icon'] as IconData,
                                size: 15,
                                color: AppTheme.electricBlue,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  features[i]['label'] as String,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.navyBlue,
                                    height: 1.2,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
