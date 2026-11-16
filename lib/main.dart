import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/network/api_service.dart';
import 'core/theme/hexgen_theme.dart';
import 'screens/onboarding_screen.dart';

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
    // Apply GoogleFonts Inter as the global unified text theme (matching modern iOS/Instagram clean style)
    final textTheme = GoogleFonts.interTextTheme(
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
    // Slight delay so the branded HexGen splash emblem displays smoothly
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    // Development Mode: Always start screen-by-screen from OnboardingScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
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
            Text(
              'HEXGEN CONNECT',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: const Color(0xFF0B192C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI SPORTS TELEMETRY & SMART ARENAS',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: const Color(0xFF0066FF),
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
