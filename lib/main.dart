import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_service.dart';
import 'core/theme/hexgen_theme.dart';
import 'features/coach/coach_dashboard_screen.dart';
import 'features/dashboard/player_dashboard_screen.dart';
import 'features/onboarding/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const HexgenConnectApp());
}

class HexgenConnectApp extends StatelessWidget {
  const HexgenConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Apply GoogleFonts Roboto as the global text theme
    final textTheme = GoogleFonts.robotoTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      title: 'Hexgen Connect',
      debugShowCheckedModeBanner: false,
      theme: HexgenTheme.lightTheme.copyWith(textTheme: textTheme),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final role = prefs.getString('user_role');

    // Slight delay so the branded HexGen splash emblem displays smoothly
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    if (isLoggedIn) {
      if (role == 'coach') {
        final coachName = prefs.getString('coach_name') ?? 'Coach Ken';
        final academy = prefs.getString('coach_academy') ?? 'HexGen Sports Academy';
        final coachId = prefs.getString('coach_id') ?? 'CH-4092';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CoachDashboardScreen(
              coachName: coachName,
              academyName: academy,
              coachId: coachId,
            ),
          ),
        );
        return;
      } else {
        // Player / Athlete
        final playerName = prefs.getString('player_name') ?? 'Karthik Raja';
        final playerId = prefs.getString('player_id') ?? 'HX-9821';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerDashboardScreen(
              playerName: playerName,
              playerId: playerId,
            ),
          ),
        );
        return;
      }
    }

    // First time or logged out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.12),
                    blurRadius: 30,
                    spreadRadius: 6,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.sports_cricket_rounded,
                  size: 60,
                  color: Color(0xFF0066FF),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'HEXGEN CONNECT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Color(0xFF0B192C),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'AI SPORTS TELEMETRY & SMART ARENAS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Color(0xFF0066FF),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
