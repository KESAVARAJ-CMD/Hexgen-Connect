import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../widgets/map_header_widget.dart';
import '../features/onboarding/player_setup_sheet.dart';
import 'complete_profile_screen.dart';

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
      icon: Icons.groups_rounded,
      titlePrefix: 'Play with ',
      titleHighlight: 'Your friends',
      subtitle:
          'Get your friends together and enjoy\nhassle – free cricket sessions.',
    ),
    OnboardingSlideData(
      icon: Icons.location_on_rounded,
      titlePrefix: 'Discover Venues ',
      titleHighlight: 'Near You',
      subtitle: 'Find the best cricket grounds\njust around the corner.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleReadySetBat() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('is_profile_completed') ?? false;

    if (!mounted) return;

    if (!isCompleted) {
      // First time user: navigate to CompleteProfileScreen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CompleteProfileScreen(),
        ),
      );
    } else {
      // Returning user: open PlayerSetupBottomSheet (Enter Name & Player ID)
      final savedName = prefs.getString('player_name') ?? '';
      final savedId = prefs.getString('player_id') ?? '';

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.35),
        builder: (context) => BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: PlayerSetupBottomSheet(
            selectedRoleTitle: savedName.isNotEmpty ? savedName : 'Athlete',
            initialName: savedName,
            initialId: savedId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        child: SafeArea(
          top: true,
          bottom: true,
          child: Column(
              children: [
                // 1. Top Section: Realistic City Map with Landmarks
                const MapHeaderWidget(),

                const SizedBox(height: 14),

                // 2. Carousel Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF0075FF)
                            : const Color(0xFFBFDBFE),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // 3. PageView Carousel for Slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // Icon + Highlighted Title Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF00D2FF),
                                      Color(0xFF0066FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Icon(
                                    slide.icon,
                                    size: 42,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0B2545),
                                      letterSpacing: -0.6,
                                      fontFamily: 'Roboto',
                                    ),
                                    children: [
                                      TextSpan(text: slide.titlePrefix),
                                      TextSpan(
                                        text: slide.titleHighlight,
                                        style: const TextStyle(
                                          color: Color(0xFF0075FF),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Subtitle
                            Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5A6E85),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 4. "Play Starts Here" with Flanking Accent Lines
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0075FF).withAlpha(0),
                              const Color(0xFF0075FF),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Play Starts Here',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0075FF),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 52,
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0075FF),
                              const Color(0xFF0075FF).withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 5. Pill Stadium Action Button ("Ready. Set. Bat →")
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: GestureDetector(
                    onTap: _handleReadySetBat,
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0052FF), // Royal Blue
                            Color(0xFF00B4F4), // Cyan-Blue
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withAlpha(90),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cricket Bat + Ball Icon in White
                          CustomPaint(
                            size: const Size(26, 26),
                            painter: WhiteCricketBatButtonPainter(),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Ready. Set. Bat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

// ── Slide Model ───────────────────────────────────────────────────────────────
class OnboardingSlideData {
  final IconData icon;
  final String titlePrefix;
  final String titleHighlight;
  final String subtitle;

  const OnboardingSlideData({
    required this.icon,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.subtitle,
  });
}

// ── Button Cricket Bat & Ball Painter ─────────────────────────────────────────
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
      const Rect.fromLTWH(-4, -13, 8, 17),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(rrect, bladePaint);

    // Bat Handle
    final handlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 4), const Offset(0, 11), handlePaint);

    // Ball 1 (Main ball)
    final ballPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(9, -7), 3.2, ballPaint);

    // Ball 2 / Motion Dot
    canvas.drawCircle(const Offset(9, 1), 2.0, ballPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Bottom Ambient Waves Painter ──────────────────────────────────────────────
class BottomAmbientWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft ambient blue wave 1 (bottom left)
    final wave1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD6EDFD).withAlpha(150),
          const Color(0xFFE8F4FE).withAlpha(0),
        ],
        center: const Alignment(-0.9, 0.8),
        radius: 0.9,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path1 = Path()
      ..moveTo(0, h * 0.3)
      ..cubicTo(w * 0.25, h * 0.2, w * 0.4, h * 0.7, 0, h)
      ..close();
    canvas.drawPath(path1, wave1Paint);

    // Soft ambient blue wave 2 (bottom right)
    final wave2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD8ECFD).withAlpha(170),
          const Color(0xFFE8F4FE).withAlpha(0),
        ],
        center: const Alignment(0.9, 0.9),
        radius: 0.9,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path2 = Path()
      ..moveTo(w, h * 0.2)
      ..cubicTo(w * 0.7, h * 0.35, w * 0.6, h * 0.85, w, h)
      ..close();
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
