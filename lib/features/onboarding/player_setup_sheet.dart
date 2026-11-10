import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/player_dashboard_screen.dart';

class PlayerSetupBottomSheet extends StatefulWidget {
  final String selectedRoleTitle;
  final String? initialName;
  final String? initialId;

  const PlayerSetupBottomSheet({
    super.key,
    required this.selectedRoleTitle,
    this.initialName,
    this.initialId,
  });

  @override
  State<PlayerSetupBottomSheet> createState() => _PlayerSetupBottomSheetState();
}

class _PlayerSetupBottomSheetState extends State<PlayerSetupBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  bool _isCalibrating = false;
  bool _isLinked = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _idController = TextEditingController(
      text: (widget.initialId != null && widget.initialId!.isNotEmpty)
          ? widget.initialId!
          : 'HX-${1000 + Random().nextInt(9000)}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _confirmAndEnter() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Athlete Name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final id = _idController.text.trim().isEmpty
        ? 'HX-${1000 + Random().nextInt(9000)}'
        : _idController.text.trim();

    setState(() {
      _isCalibrating = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isCalibrating = false;
        _isLinked = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_profile_completed', true);
    await prefs.setString('user_role', 'player');
    await prefs.setString('player_name', name);
    await prefs.setString('player_id', id);

    if (mounted) {
      Navigator.pop(context); // Close bottom sheet
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerDashboardScreen(
            playerName: name,
            playerId: id,
          ),
        ),
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
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Clean Header (Munnadi iruntha maathiri)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.electricBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Player Setup & Calibration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'HexGen Telemetry profile link',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.slateBlue,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.slateBlue, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. FIELD 1: ENTER NAME (Clean single-box, no double borders!)
          const Text(
            'ENTER NAME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.navyBlue,
              letterSpacing: 0.8,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.royalBlue.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: AppTheme.navyBlue,
                fontFamily: 'Roboto',
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.person_rounded, color: AppTheme.electricBlue, size: 20),
                hintText: 'Enter your full name',
                hintStyle: TextStyle(color: AppTheme.slateBlue, fontSize: 13.5),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),

          const SizedBox(height: 14),

          // 4. FIELD 2: ENTER PLAYER ID (Clean single-box)
          const Text(
            'ENTER PLAYER ID',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.navyBlue,
              letterSpacing: 0.8,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.royalBlue.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _idController,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: AppTheme.electricBlue,
                letterSpacing: 0.8,
                fontFamily: 'Roboto',
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.royalBlue, size: 20),
                hintText: 'e.g. HX-9821',
                hintStyle: TextStyle(color: AppTheme.slateBlue, fontSize: 13.5),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),

          const SizedBox(height: 20),

          // 5. SIGNATURE GRADIENT BUTTON (No "READY. SET. BAT", pure clean CTA)
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: (_isCalibrating || _isLinked)
                  ? const LinearGradient(colors: [Color(0xFF047857), Color(0xFF10B981)])
                  : AppTheme.primaryCtaGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: (_isCalibrating || _isLinked) ? null : _confirmAndEnter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCalibrating) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CALIBRATING SENSOR...',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ] else if (_isLinked) ...[
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'SENSOR LINKED! ENTERING ARENA...',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Confirm & Enter HexGen Arena',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
