import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'checkout_screen.dart';

class OverConfig {
  double ballSpeed;
  String selectedArm;
  String selectedBowlerType;
  String selectedVariation;
  String selectedDirection;
  String selectedLevel;
  bool randomSpin;
  bool randomLength;

  OverConfig({
    this.ballSpeed = 150.0,
    this.selectedArm = 'Right Arm',
    this.selectedBowlerType = 'Off Spin',
    this.selectedVariation = 'Swing',
    this.selectedDirection = 'In',
    this.selectedLevel = 'Medium',
    this.randomSpin = true,
    this.randomLength = false,
  });

  OverConfig clone() {
    return OverConfig(
      ballSpeed: ballSpeed,
      selectedArm: selectedArm,
      selectedBowlerType: selectedBowlerType,
      selectedVariation: selectedVariation,
      selectedDirection: selectedDirection,
      selectedLevel: selectedLevel,
      randomSpin: randomSpin,
      randomLength: randomLength,
    );
  }
}

class SessionConfigScreen extends StatefulWidget {
  const SessionConfigScreen({super.key});

  @override
  State<SessionConfigScreen> createState() => _SessionConfigScreenState();
}

class _SessionConfigScreenState extends State<SessionConfigScreen> {
  int _selectedOver = 1;

  final Map<int, OverConfig> _overConfigs = {
    for (int i = 1; i <= 6; i++) i: OverConfig(),
  };

  OverConfig get _currentConfig => _overConfigs[_selectedOver]!;

  double get _ballSpeed => _currentConfig.ballSpeed;
  set _ballSpeed(double val) => _currentConfig.ballSpeed = val;

  String get _selectedArm => _currentConfig.selectedArm;
  set _selectedArm(String val) => _currentConfig.selectedArm = val;

  String get _selectedBowlerType => _currentConfig.selectedBowlerType;
  set _selectedBowlerType(String val) => _currentConfig.selectedBowlerType = val;

  String get _selectedVariation => _currentConfig.selectedVariation;
  set _selectedVariation(String val) => _currentConfig.selectedVariation = val;

  String get _selectedDirection => _currentConfig.selectedDirection;
  set _selectedDirection(String val) => _currentConfig.selectedDirection = val;

  String get _selectedLevel => _currentConfig.selectedLevel;
  set _selectedLevel(String val) => _currentConfig.selectedLevel = val;

  bool get _randomSpin => _currentConfig.randomSpin;
  set _randomSpin(bool val) => _currentConfig.randomSpin = val;

  bool get _randomLength => _currentConfig.randomLength;
  set _randomLength(bool val) => _currentConfig.randomLength = val;

  void _onSave() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  void _onCopyToAllOvers() {
    final current = _currentConfig;
    setState(() {
      for (int i = 1; i <= 6; i++) {
        _overConfigs[i] = current.clone();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Over $_selectedOver settings copied to all 6 overs!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.navyBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Header Bar: < SESSION 1 CONFIGURATION 🗑️ ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cardBorderColor,
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppTheme.navyBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const Text(
                      'SESSION 1 CONFIGURATION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: 0.6,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _overConfigs[_selectedOver] = OverConfig();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Over $_selectedOver reset to default configuration'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.navyBlue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ──────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Over Selector Row ────────────────────────────────────
                      const Text(
                        'Over',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          final overNum = index + 1;
                          final isSelected = _selectedOver == overNum;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOver = overNum;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppTheme.primaryCtaGradient
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppTheme.cardBorderColor,
                                        width: 1.2,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.electricBlue.withValues(alpha: 0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF0F2B5C).withValues(alpha: 0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Text(
                                  '$overNum',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.navyBlue,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      // ── Pitch Trajectory Visualizer Card ─────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF86EFAC),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 7,
                                        color: Color(0xFF16A34A),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Live Trajectory',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16A34A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Pitch Green Turf Box
                            Container(
                              height: 170,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B4F31),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  // White Crease Lines
                                  Positioned(
                                    top: 25,
                                    left: 40,
                                    right: 80,
                                    child: Container(
                                        height: 1.5, color: Colors.white70),
                                  ),
                                  Positioned(
                                    bottom: 25,
                                    left: 40,
                                    right: 80,
                                    child: Container(
                                        height: 1.5, color: Colors.white70),
                                  ),

                                  // Pitch Markers Text
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: _buildPitchText('Short'),
                                  ),
                                  Positioned(
                                    top: 55,
                                    right: 20,
                                    child: _buildPitchText('Good Length'),
                                  ),
                                  Positioned(
                                    top: 90,
                                    right: 20,
                                    child: _buildPitchText('Full Length'),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    right: 20,
                                    child: _buildPitchText('Yorker / Slot'),
                                  ),

                                  // Trajectory Arc Custom Paint
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _PitchTrajectoryPainter(),
                                    ),
                                  ),

                                  // Stumps
                                  Positioned(
                                    bottom: 18,
                                    left: 130,
                                    child: Row(
                                      children: List.generate(
                                        3,
                                        (_) => Container(
                                          margin:
                                              const EdgeInsets.only(right: 3),
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFACC15),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Target Ball Speed Controls ───────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFBAE6FD),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${_ballSpeed.toInt()} KMPH',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Speed Slider
                            SliderTheme(
                              data: SliderThemeData(
                                trackShape: const GradientSliderTrackShape(),
                                inactiveTrackColor: const Color(0xFFE2EEFF),
                                thumbColor: Colors.white,
                                overlayColor: const Color(0xFF0066FF).withValues(alpha: 0.15),
                                trackHeight: 8,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                  elevation: 3,
                                ),
                              ),
                              child: Slider(
                                value: _ballSpeed,
                                min: 80,
                                max: 160,
                                divisions: 16,
                                onChanged: (val) {
                                  setState(() {
                                    _ballSpeed = val;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Ball Selector Pills
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                5,
                                (index) => Container(
                                  width: 50,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: const Color(0xFFE2EEFF),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Arm Type ─────────────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Arm Type'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Right Arm',
                                    icon: Icons.electric_bolt_rounded,
                                    isSelected: _selectedArm == 'Right Arm',
                                    onTap: () => setState(
                                        () => _selectedArm = 'Right Arm'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Left Arm',
                                    icon: Icons.sanitizer_rounded,
                                    isSelected: _selectedArm == 'Left Arm',
                                    onTap: () => setState(
                                        () => _selectedArm = 'Left Arm'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Bowler Type ──────────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Bowler Type'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Pace',
                                    icon: Icons.bolt_rounded,
                                    isSelected: _selectedBowlerType == 'Pace',
                                    onTap: () => setState(
                                        () => _selectedBowlerType = 'Pace'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Off Spin',
                                    icon: Icons.sync_rounded,
                                    isSelected:
                                        _selectedBowlerType == 'Off Spin',
                                    onTap: () => setState(
                                        () => _selectedBowlerType = 'Off Spin'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Wrist Spin',
                                    icon: Icons.autorenew_rounded,
                                    isSelected:
                                        _selectedBowlerType == 'Wrist Spin',
                                    onTap: () => setState(() =>
                                        _selectedBowlerType = 'Wrist Spin'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Variation & Direction ────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Variation & Direction'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Swing',
                                    icon: Icons.air_rounded,
                                    isSelected: _selectedVariation == 'Swing',
                                    onTap: () => setState(
                                        () => _selectedVariation = 'Swing'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Seam',
                                    icon: Icons.trending_up_rounded,
                                    isSelected: _selectedVariation == 'Seam',
                                    onTap: () => setState(
                                        () => _selectedVariation = 'Seam'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Choose Direction ─────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Choose Direction'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'In',
                                    icon: Icons.south_west_rounded,
                                    isSelected: _selectedDirection == 'In',
                                    onTap: () => setState(
                                        () => _selectedDirection = 'In'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Out',
                                    icon: Icons.north_east_rounded,
                                    isSelected: _selectedDirection == 'Out',
                                    onTap: () => setState(
                                        () => _selectedDirection = 'Out'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Levels ───────────────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Levels'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Basic',
                                    isSelected: _selectedLevel == 'Basic',
                                    onTap: () =>
                                        setState(() => _selectedLevel = 'Basic'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Medium',
                                    isSelected: _selectedLevel == 'Medium',
                                    onTap: () => setState(
                                        () => _selectedLevel = 'Medium'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'High',
                                    isSelected: _selectedLevel == 'High',
                                    onTap: () =>
                                        setState(() => _selectedLevel = 'High'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Randomization ────────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Randomization'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Random Spin/Swing',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                CyberGradientSwitch(
                                  value: _randomSpin,
                                  onChanged: (val) {
                                    setState(() {
                                      _randomSpin = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Random Length',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                CyberGradientSwitch(
                                  value: _randomLength,
                                  onChanged: (val) {
                                    setState(() {
                                      _randomLength = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Dual Bottom Action Buttons: Save | Copy to All Overs ─────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _onSave,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: AppTheme.primaryCtaGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _onCopyToAllOvers,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0052FF), // Royal Deep Blue
                                Color(0xFF00D4FF), // Electric Cyan
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0066FF).withValues(alpha: 0.16),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.5),
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFF0052FF),
                                    Color(0xFF00A6FF),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Copy to All Overs',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.cardBorderColor,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: AppTheme.navyBlue,
      ),
    );
  }

  Widget _buildSelectableButton({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.primaryCtaGradient
              : null,
          color: isSelected
              ? null
              : const Color(0xFFEBF3FE), // Soft light blue fill
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.electricBlue.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.navyBlue,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.navyBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPitchText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }
}

// ── Pitch Trajectory Painter ──────────────────────────────────────────────────
class _PitchTrajectoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Curved Cyan Trajectory Line
    final path = Path()
      ..moveTo(w * 0.48, h * 0.15)
      ..cubicTo(w * 0.42, h * 0.4, w * 0.43, h * 0.65, w * 0.48, h * 0.85);

    final linePaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, linePaint);

    // Bounce Spot Blue Dot
    final dotPaint = Paint()
      ..color = const Color(0xFF0057FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.44, h * 0.55), 5.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
