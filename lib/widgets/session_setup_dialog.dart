import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';

class SessionSetupDialog extends StatefulWidget {
  const SessionSetupDialog({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const SessionSetupDialog(),
      ),
    );
  }

  @override
  State<SessionSetupDialog> createState() => _SessionSetupDialogState();
}

class _SessionSetupDialogState extends State<SessionSetupDialog> {
  String _selectedArm = 'Right Arm';
  String _selectedBowlerType = 'Fast Seam';
  int _selectedOvers = 6;
  double _ballSpeed = 120.0;

  final List<String> _bowlerTypes = [
    'Fast Seam',
    'Out-Swinger',
    'In-Swinger',
    'Off-Spin',
    'Leg-Spin',
    'Slower Ball',
  ];

  final List<int> _overOptions = [2, 4, 6, 10, 15];

  void _onConfirm() {
    final result = {
      'arm': _selectedArm,
      'type': _selectedBowlerType,
      'overs': _selectedOvers,
      'speed': _ballSpeed.round(),
    };
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag Handle ──────────────────────────────────────────────────
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

            // ── Header Bar ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program Practice Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    Text(
                      'Bowling Machine & Camera Tracking Preset',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.slateBlue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.navyBlue, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Bowler Arm ───────────────────────────────────────────────────
            const Text(
              'Bowling Arm',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildArmTile(
                    title: 'Right Arm',
                    icon: Icons.back_hand_rounded,
                    isSelected: _selectedArm == 'Right Arm',
                    onTap: () => setState(() => _selectedArm = 'Right Arm'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildArmTile(
                    title: 'Left Arm',
                    icon: Icons.front_hand_rounded,
                    isSelected: _selectedArm == 'Left Arm',
                    onTap: () => setState(() => _selectedArm = 'Left Arm'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Delivery Style ───────────────────────────────────────────────
            const Text(
              'Delivery Style / Variation',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bowlerTypes.map((type) {
                final isSelected = _selectedBowlerType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBowlerType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.electricBlue : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.electricBlue
                            : AppTheme.cardBorderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.navyBlue,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // ── Target Ball Speed ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Target Ball Speed',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navyBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.badgePurpleBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_ballSpeed.toInt()} KM/H',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.electricBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: const GradientSliderTrackShape(),
                trackHeight: 6,
                inactiveTrackColor: const Color(0xFFE2EEFF),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF0066FF).withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 3,
                ),
              ),
              child: Slider(
                value: _ballSpeed,
                min: 80,
                max: 150,
                divisions: 14,
                onChanged: (val) => setState(() => _ballSpeed = val),
              ),
            ),

            const SizedBox(height: 14),

            // ── Number of Overs ──────────────────────────────────────────────
            const Text(
              'Overs to Program',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _overOptions.map((overs) {
                final isSelected = _selectedOvers == overs;
                return GestureDetector(
                  onTap: () => setState(() => _selectedOvers = overs),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.electricBlue
                            : AppTheme.cardBorderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$overs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : AppTheme.navyBlue,
                          ),
                        ),
                        Text(
                          'OVERS',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white70 : AppTheme.slateBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Confirm CTA ──────────────────────────────────────────────────
            GestureDetector(
              onTap: _onConfirm,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: AppTheme.primaryCtaGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'CALIBRATE & LAUNCH SESSION',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildArmTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.iceBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.electricBlue : AppTheme.cardBorderColor,
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.electricBlue : AppTheme.slateBlue,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.navyBlue : AppTheme.slateBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
