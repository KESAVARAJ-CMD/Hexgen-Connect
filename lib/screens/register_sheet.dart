import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../features/dashboard/player_dashboard_screen.dart';
import 'complete_profile_screen.dart';

class RegisterBottomSheet extends StatefulWidget {
  const RegisterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const RegisterBottomSheet(),
      ),
    );
  }

  @override
  State<RegisterBottomSheet> createState() => _RegisterBottomSheetState();
}

class _RegisterBottomSheetState extends State<RegisterBottomSheet> {
  final TextEditingController _phoneController = TextEditingController(text: '');
  bool _whatsappUpdates = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('is_profile_completed') ?? false;

    // Auto-generate unique Player ID for this athlete
    String playerId = prefs.getString('player_id') ?? '';
    if (playerId.isEmpty) {
      playerId = 'HX-${1000 + Random().nextInt(9000)}';
      await prefs.setString('player_id', playerId);
    }
    await prefs.setString('player_phone', phone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context); // Close Register Sheet

    if (!isCompleted) {
      // First time user: navigate directly to CompleteProfileScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(
            initialPhone: phone,
            initialPlayerId: playerId,
          ),
        ),
      );
    } else {
      // Returning user: grant direct login access to PlayerDashboardScreen
      final name = prefs.getString('player_name') ?? 'Karthik Raja';
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_role', 'player');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerDashboardScreen(
            playerName: name,
            playerId: playerId,
          ),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _onGoogleContinue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('is_profile_completed') ?? false;

    String playerId = prefs.getString('player_id') ?? '';
    if (playerId.isEmpty) {
      playerId = 'HX-${1000 + Random().nextInt(9000)}';
      await prefs.setString('player_id', playerId);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pop(context);

    if (!isCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(
            initialPlayerId: playerId,
          ),
        ),
      );
    } else {
      final name = prefs.getString('player_name') ?? 'Karthik Raja';
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_role', 'player');

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerDashboardScreen(
            playerName: name,
            playerId: playerId,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar: Let's Register + Close X ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Let's Register",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.navyBlue, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Enter Mobile No Label ─────────────────────────────────────────
          const Text(
            'Enter Mobile No',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateBlue,
            ),
          ),
          const SizedBox(height: 8),

          // ── Mobile Number Input Box ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.skyBlue, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue.withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 24,
                  color: AppTheme.cardBorderColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter 10-digit mobile number',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Continue CTA Button ───────────────────────────────────────────
          GestureDetector(
            onTap: _isLoading ? null : _onContinue,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: AppTheme.primaryCtaGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // ── WhatsApp Agreement Checkbox ──────────────────────────────────
          Row(
            children: [
              CyberGradientCheckbox(
                value: _whatsappUpdates,
                onChanged: (val) {
                  setState(() => _whatsappUpdates = val);
                },
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'I agree to receive updates on whatsapp',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navyBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Terms & Conditions text ───────────────────────────────────────
          const Center(
            child: Text(
              'By signing up, you agree to\nterm of service and privacy policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.slateBlue,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Divider: Or ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 50, height: 1, color: AppTheme.cardBorderColor),
              const SizedBox(width: 12),
              const Text(
                'Or',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.slateBlue,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 50, height: 1, color: AppTheme.cardBorderColor),
            ],
          ),

          const SizedBox(height: 16),

          // ── Google Login Circle Button ───────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : _onGoogleContinue,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      width: 24,
                      height: 24,
                      child: CustomPaint(painter: _GoogleGLogoPainter()),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final double radius = w / 2;

    // Blue Bar & Arc
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0, -3.14 * 0.4, false)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Red Top Arc
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), -3.14 * 0.4, -3.14 * 0.55, false)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow Left Arc
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), -3.14 * 0.95, -3.14 * 0.35, false)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green Bottom Arc
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), -3.14 * 1.30, -3.14 * 0.45, false)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Inner White Hole
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.52, whitePaint);

    // Inner Blue Horizontal Rect Line
    final blueLinePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.22, radius * 0.95, radius * 0.44),
      blueLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
