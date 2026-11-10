import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/onboarding/player_setup_sheet.dart';
import 'complete_profile_screen.dart';
import 'register_sheet.dart';

class ContinueWithScreen extends StatefulWidget {
  const ContinueWithScreen({super.key});

  @override
  State<ContinueWithScreen> createState() => _ContinueWithScreenState();
}

class _ContinueWithScreenState extends State<ContinueWithScreen> {
  void _openPlayerSetupBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('is_profile_completed') ?? false;

    if (!mounted) return;

    if (!isCompleted) {
      String playerId = prefs.getString('player_id') ?? '';
      if (playerId.isEmpty) {
        playerId = 'HX-${1000 + Random().nextInt(9000)}';
        await prefs.setString('player_id', playerId);
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(initialPlayerId: playerId),
        ),
      );
    } else {
      final name = prefs.getString('player_name') ?? '';
      final id = prefs.getString('player_id') ?? '';
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withAlpha(90),
        builder: (context) => BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: PlayerSetupBottomSheet(
            selectedRoleTitle: name.isNotEmpty ? name : 'Athlete',
            initialName: name,
            initialId: id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: CyberGlassBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppTheme.navyBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Setup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        Text(
                          'Step 3 of 3 • Link Login',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slateBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      const Center(
                        child: Text(
                          'Connect Your Account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Center(
                        child: Text(
                          'Link your account to save telemetry stats and match replays',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.slateBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Google Option
                      _buildAuthOptionCard(
                        icon: Icons.g_mobiledata_rounded,
                        title: 'Continue with Google',
                        subtitle: 'Quick sign-in with Google account',
                        color: const Color(0xFFEA4335),
                        onTap: _openPlayerSetupBottomSheet,
                      ),

                      const SizedBox(height: 12),

                      // Phone Option
                      _buildAuthOptionCard(
                        icon: Icons.phone_iphone_rounded,
                        title: 'Continue with Mobile Number',
                        subtitle: 'Instant Mobile Login & Auto-ID',
                        color: AppTheme.electricBlue,
                        onTap: () => RegisterBottomSheet.show(context),
                      ),

                      const SizedBox(height: 12),

                      // Guest Option
                      _buildAuthOptionCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Continue as Guest',
                        subtitle: 'Quick setup with local profile',
                        color: AppTheme.navyBlue,
                        onTap: _openPlayerSetupBottomSheet,
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _openPlayerSetupBottomSheet,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: AppTheme.primaryCtaGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.electricBlue.withAlpha(90),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'COMPLETE SETUP & CALIBRATE',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
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

  Widget _buildAuthOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C3E78).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.slateBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.navyBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
