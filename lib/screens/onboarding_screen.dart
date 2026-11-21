import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'register_sheet.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      badge: 'SMART CRICKET ARENAS',
      badgeIcon: Icons.stadium_rounded,
      titlePrefix: 'Discover & Book ',
      titleHighlight: 'Turf Venues',
      subtitle:
          'Find top-tier cricket grounds & automated net lanes near you with instant QR check-in.',
      cardType: SlideCardType.venues,
    ),
    OnboardingSlideData(
      badge: 'CONNECTED IOT LANES',
      badgeIcon: Icons.speed_rounded,
      titlePrefix: 'Control The ',
      titleHighlight: 'Bowling Machine',
      subtitle:
          'Dial match-level speeds up to 150 km/h, custom swing, yorkers, and bouncers right from your phone.',
      cardType: SlideCardType.machine,
    ),
    OnboardingSlideData(
      badge: 'PRO AI PERFORMANCE',
      badgeIcon: Icons.auto_graph_rounded,
      titlePrefix: 'Track Every Ball ',
      titleHighlight: 'With AI Vision',
      subtitle:
          'Analyze ball trajectory, pitching maps, bat speeds, and review HD video replays ball-by-ball.',
      cardType: SlideCardType.analytics,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _handleGetStarted();
    }
  }

  void _handleGetStarted() {
    RegisterBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // ── 1. Top Navigation Bar ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryCtaGradient,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.sports_cricket_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HEXGEN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CONNECT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0052FF),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Skip Button
                    GestureDetector(
                      onTap: _handleGetStarted,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0052FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Carousel of Slides ────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // Dynamic Visual Showcase Card (Expanded & Prominent)
                          Expanded(
                            flex: 11,
                            child: _buildVisualCard(slide.cardType),
                          ),

                          const SizedBox(height: 16),

                          // Category Badge Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0052FF).withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  slide.badgeIcon,
                                  size: 14,
                                  color: const Color(0xFF0052FF),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  slide.badge,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0052FF),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // High Impact Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                height: 1.2,
                                letterSpacing: -0.4,
                              ),
                              children: [
                                TextSpan(text: slide.titlePrefix),
                                TextSpan(
                                  text: slide.titleHighlight,
                                  style: const TextStyle(
                                    color: Color(0xFF0052FF),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Feature Highlights Strip (Attracts Players & Coaches)
                          _buildSlideHighlightsStrip(index),

                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── 3. Page Indicators & Social Proof ─────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 7,
                      width: isActive ? 26 : 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: isActive ? AppTheme.primaryCtaGradient : null,
                        color: isActive ? null : const Color(0xFFCBD5E1),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              // ── 4. High-Conversion Action Button ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: GestureDetector(
                  onTap: _onNextPressed,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppTheme.primaryCtaGradient,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLastPage) ...[
                          CustomPaint(
                            size: const Size(22, 22),
                            painter: WhiteCricketBatButtonPainter(),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          isLastPage ? 'Ready. Set. Bat' : 'Continue',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
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
              ),

              // ── 5. Secondary Quick Action / Tagline ───────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 14, top: 4),
                child: GestureDetector(
                  onTap: _handleGetStarted,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Sign In',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0052FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dynamic Visual Hero Cards ───────────────────────────────────────────────

  Widget _buildVisualCard(SlideCardType type) {
    switch (type) {
      case SlideCardType.venues:
        return _buildImageHeroCard(
          assetPath: 'assets/cricket_turf_booking.png',
          fallbackAssetPath: 'assets/Cricket Turf Booking .png',
          topBadgeText: 'QR Check-In',
          topBadgeIcon: Icons.qr_code_2_rounded,
          bottomBadgeText: '24+ Arenas Active Nearby',
          statusColor: const Color(0xFF10B981),
          fallbackIcon: Icons.stadium_rounded,
        );
      case SlideCardType.machine:
        return _buildImageHeroCard(
          assetPath: 'assets/cricket_bowling_machine.png',
          fallbackAssetPath: 'assets/Cricket Bowling Machine.png',
          topBadgeText: '150 KM/H Bot V4',
          topBadgeIcon: Icons.speed_rounded,
          bottomBadgeText: 'Connected & Ready • Lane 01',
          statusColor: const Color(0xFF0052FF),
          fallbackIcon: Icons.precision_manufacturing_rounded,
        );
      case SlideCardType.analytics:
        return _buildImageHeroCard(
          assetPath: 'assets/cricket_analytics_arena.png',
          fallbackAssetPath: 'assets/Cricket Analytics Arena.png',
          topBadgeText: '1080P HD Replay',
          topBadgeIcon: Icons.videocam_rounded,
          bottomBadgeText: 'AI Vision • Sweet Spot 94%',
          statusColor: const Color(0xFF8B5CF6),
          fallbackIcon: Icons.auto_graph_rounded,
        );
    }
  }

  Widget _buildImageHeroCard({
    required String assetPath,
    required String fallbackAssetPath,
    required String topBadgeText,
    required IconData topBadgeIcon,
    required String bottomBadgeText,
    required Color statusColor,
    required IconData fallbackIcon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052FF).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Generated Image from assets with full responsive fit
            Positioned.fill(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    fallbackAssetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: Center(
                        child: Icon(fallbackIcon, size: 54, color: const Color(0xFF0052FF)),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top-Right Live Glass Badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(topBadgeIcon, size: 14, color: const Color(0xFF38BDF8)),
                    const SizedBox(width: 4),
                    Text(
                      topBadgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-Left Status Pill
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bottomBadgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Slide Feature Highlights (Attracting Players & Coaches) ────────────────
  Widget _buildSlideHighlightsStrip(int slideIndex) {
    final List<List<Map<String, dynamic>>> highlights = [
      // Slide 1: Arenas
      [
        {'icon': Icons.flash_on_rounded, 'label': 'Instant Booking', 'color': Color(0xFF0052FF)},
        {'icon': Icons.qr_code_scanner_rounded, 'label': 'Zero-Wait QR', 'color': Color(0xFF10B981)},
        {'icon': Icons.verified_user_rounded, 'label': 'Pro Turfs', 'color': Color(0xFF8B5CF6)},
      ],
      // Slide 2: Machine
      [
        {'icon': Icons.speed_rounded, 'label': '150 KM/H Pace', 'color': Color(0xFF0052FF)},
        {'icon': Icons.sync_alt_rounded, 'label': 'Late Swing & Seam', 'color': Color(0xFF0284C7)},
        {'icon': Icons.phone_android_rounded, 'label': 'App Controlled', 'color': Color(0xFF10B981)},
      ],
      // Slide 3: Analytics
      [
        {'icon': Icons.videocam_rounded, 'label': 'HD Video Replay', 'color': Color(0xFF0052FF)},
        {'icon': Icons.auto_graph_rounded, 'label': 'Bat Speed Metric', 'color': Color(0xFF10B981)},
        {'icon': Icons.psychology_rounded, 'label': 'AI Coach Advice', 'color': Color(0xFF8B5CF6)},
      ],
    ];

    final currentItems = highlights[slideIndex.clamp(0, highlights.length - 1)];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: currentItems.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0052FF).withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 13,
                color: item['color'] as Color,
              ),
              const SizedBox(width: 5),
              Text(
                item['label'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Slide Data Models ─────────────────────────────────────────────────────────

enum SlideCardType {
  venues,
  machine,
  analytics,
}

class OnboardingSlideData {
  final String badge;
  final IconData badgeIcon;
  final String titlePrefix;
  final String titleHighlight;
  final String subtitle;
  final SlideCardType cardType;

  const OnboardingSlideData({
    required this.badge,
    required this.badgeIcon,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.subtitle,
    required this.cardType,
  });
}

// ── Custom Cricket Bat & Ball Painter ─────────────────────────────────────────

class WhiteCricketBatButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.75); // ~45 deg slant

    // Bat Blade
    final bladePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-3.5, -11, 7, 14),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(rrect, bladePaint);

    // Bat Handle
    final handlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 3), const Offset(0, 9), handlePaint);

    // Ball 1 (Main ball)
    final ballPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(8, -5), 2.8, ballPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
