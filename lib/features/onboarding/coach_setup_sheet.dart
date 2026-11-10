import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../coach/coach_dashboard_screen.dart';

class CoachSetupBottomSheet extends StatefulWidget {
  const CoachSetupBottomSheet({super.key});

  @override
  State<CoachSetupBottomSheet> createState() => _CoachSetupBottomSheetState();
}

class _CoachSetupBottomSheetState extends State<CoachSetupBottomSheet> {
  final _coachNameController = TextEditingController(text: 'Coach Ken');
  final _academyNameController = TextEditingController(text: 'HexGen Sports Academy');
  final _coachIdController = TextEditingController(text: 'CH-4092');
  bool _isVerifying = false;
  bool _isVerified = false;

  @override
  void dispose() {
    _coachNameController.dispose();
    _academyNameController.dispose();
    _coachIdController.dispose();
    super.dispose();
  }

  void _confirmAndEnter() async {
    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _isVerified = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 650));

    final coachName = _coachNameController.text.trim().isEmpty ? 'Coach Madhu' : _coachNameController.text.trim();
    final academyName = _academyNameController.text.trim().isEmpty ? 'HexGen Sports Academy' : _academyNameController.text.trim();
    final coachId = _coachIdController.text.trim().isEmpty ? 'CH-4092' : _coachIdController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'coach');
    await prefs.setString('coach_name', coachName);
    await prefs.setString('coach_academy', academyName);
    await prefs.setString('coach_id', coachId);

    if (mounted) {
      Navigator.pop(context); // Close bottom sheet modal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CoachDashboardScreen(
            coachName: coachName,
            academyName: academyName,
            coachId: coachId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HexgenColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle Pill
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: HexgenColors.lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: HexgenColors.electricBlue, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'MENTOR & ACADEMY ONBOARDING',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: HexgenColors.navyBlue,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'HexGen Academy credentials verification',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: HexgenColors.slateBlue,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: HexgenColors.slateBlue),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // FIELD 1: ENTER COACH NAME
          const Text(
            'MENTOR FULL NAME',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HexgenColors.navyBlue, letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          HexgenCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: _coachNameController,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: HexgenColors.navyBlue),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.person_rounded, color: HexgenColors.electricBlue, size: 20),
                hintText: 'e.g. Coach Ken',
              ),
            ),
          ),

          const SizedBox(height: 14),

          // FIELD 2: ACADEMY
          const Text(
            'ACADEMY / CLUB AFFILIATION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HexgenColors.navyBlue, letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          HexgenCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: _academyNameController,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: HexgenColors.navyBlue),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.stadium_rounded, color: HexgenColors.royalBlue, size: 20),
                hintText: 'HexGen Sports Academy',
              ),
            ),
          ),

          const SizedBox(height: 14),

          // FIELD 3: COACH ID
          const Text(
            'CERTIFIED COACH ID',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HexgenColors.navyBlue, letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          HexgenCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: _coachIdController,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: HexgenColors.electricBlue),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.badge_outlined, color: HexgenColors.royalBlue, size: 20),
                hintText: 'CH-4092',
              ),
            ),
          ),

          const SizedBox(height: 22),

          HexgenButton(
            text: _isVerifying
                ? 'VERIFYING CREDENTIALS...'
                : (_isVerified ? 'VERIFICATION COMPLETE!' : 'VERIFY & ENTER PORTAL'),
            icon: _isVerifying ? null : Icons.verified_user_rounded,
            onPressed: (_isVerifying || _isVerified) ? null : _confirmAndEnter,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
