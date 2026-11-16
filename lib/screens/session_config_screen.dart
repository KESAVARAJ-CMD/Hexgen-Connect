import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/services/sessions_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../core/widgets/cyber_glass_backdrop.dart';

class OverConfig {
  double ballSpeed;
  String selectedArm;
  String selectedBowlerType;
  String selectedLength;
  String selectedVariation;
  String selectedDirection;
  String selectedLevel;
  bool randomSpin;
  bool randomLength;
  bool randomSpeed;

  OverConfig({
    this.ballSpeed = 90.0,
    this.selectedArm = 'Right Arm',
    this.selectedBowlerType = 'Pace',
    this.selectedLength = 'Good',
    this.selectedVariation = 'Swing',
    this.selectedDirection = 'In',
    this.selectedLevel = 'Medium',
    this.randomSpin = true,
    this.randomLength = false,
    this.randomSpeed = false,
  });

  OverConfig clone() {
    return OverConfig(
      ballSpeed: ballSpeed,
      selectedArm: selectedArm,
      selectedBowlerType: selectedBowlerType,
      selectedLength: selectedLength,
      selectedVariation: selectedVariation,
      selectedDirection: selectedDirection,
      selectedLevel: selectedLevel,
      randomSpin: randomSpin,
      randomLength: randomLength,
      randomSpeed: randomSpeed,
    );
  }
}

class SessionConfigScreen extends StatefulWidget {
  final bool isCreatingPracticeSession;
  final String? initialSessionTitle;

  const SessionConfigScreen({
    super.key,
    this.isCreatingPracticeSession = true,
    this.initialSessionTitle,
  });

  @override
  State<SessionConfigScreen> createState() => _SessionConfigScreenState();
}

class _SessionConfigScreenState extends State<SessionConfigScreen> {
  int _selectedOver = 1;
  final TextEditingController _sessionNameController = TextEditingController();

  final Map<int, OverConfig> _overConfigs = {
    for (int i = 1; i <= 6; i++) i: OverConfig(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialSessionTitle != null && widget.initialSessionTitle!.isNotEmpty) {
      _sessionNameController.text = widget.initialSessionTitle!;
    }
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  OverConfig get _currentConfig => _overConfigs[_selectedOver]!;

  double get _ballSpeed => _currentConfig.ballSpeed;
  set _ballSpeed(double val) => _currentConfig.ballSpeed = val;

  String get _selectedArm => _currentConfig.selectedArm;
  set _selectedArm(String val) => _currentConfig.selectedArm = val;

  String get _selectedBowlerType => _currentConfig.selectedBowlerType;
  set _selectedBowlerType(String val) => _currentConfig.selectedBowlerType = val;

  String get _selectedLength => _currentConfig.selectedLength;
  set _selectedLength(String val) => _currentConfig.selectedLength = val;

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

  bool get _randomSpeed => _currentConfig.randomSpeed;
  set _randomSpeed(bool val) => _currentConfig.randomSpeed = val;

  Future<void> _onSave() async {
    final sessionTitle = _sessionNameController.text.trim().isNotEmpty
        ? _sessionNameController.text.trim()
        : 'Session Practice';

    final List<Map<String, dynamic>> generatedOvers = [];
    for (int i = 1; i <= 6; i++) {
      final config = _overConfigs[i] ?? _currentConfig;
      generatedOvers.add({
        'over': 'Over 0$i',
        'summary': '6 Balls • ${config.ballSpeed.toStringAsFixed(1)} km/h • ${config.selectedVariation}',
        'speed': '${config.ballSpeed.toStringAsFixed(1)} km/h',
        'type': '${config.selectedBowlerType} - ${config.selectedVariation} (${config.selectedDirection})',
      });
    }

    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final timeStr = '${hour.toString().padLeft(2, '0')}:$minuteStr $ampm';

    final nextIndex = SessionsService().sessions.length + 1;
    final machineId = 'HEX-${(sessionTitle.hashCode.abs() % 9000 + 1000)}';

    final newSession = SessionItem(
      id: 'SES-${nextIndex.toString().padLeft(2, '0')}',
      title: sessionTitle.toLowerCase().startsWith('session')
          ? sessionTitle
          : 'Session $nextIndex',
      name: sessionTitle,
      date: dateStr,
      time: timeStr,
      lane: 'Hexgen Turf',
      coach: 'Self Practice',
      oversCount: '6 Overs',
      speed: '${_ballSpeed.toStringAsFixed(1)} km/h',
      armType: _selectedArm,
      bowlerType: _selectedBowlerType,
      length: _selectedLength,
      variation: _selectedVariation,
      direction: _selectedDirection,
      level: _selectedLevel,
      overs: generatedOvers,
    );

    // Save temporarily and persistently into SessionsService
    await SessionsService().addSession(newSession);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SessionQrShareDialog(
        sessionItem: newSession,
        machineId: machineId,
        onDone: () {
          Navigator.pop(ctx); // Close dialog
          Navigator.pop(context, true); // Close SessionConfigScreen
        },
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
        showOrbs: false,
        child: SafeArea(
          child: Column(
            children: [
              // ── 1. Top Header Bar: < SESSION 1 CONFIGURATION 🗑️ ───────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.navyBlue,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.initialSessionTitle ?? 'SESSION 1 CONFIGURATION',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 24,
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
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── 2. Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Session Name Card ────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Session Name'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                controller: _sessionNameController,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.navyBlue,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Evening Batting Practice, Cover Drive Drill',
                                  hintStyle: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.normal,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.edit_note_rounded,
                                    color: AppTheme.electricBlue,
                                    size: 22,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Over Selector Row ────────────────────────────────────
                      const Text(
                        'Over',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Over Number Chips (1 - 6)
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
                                gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.2,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.electricBlue.withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
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
                                    color: isSelected ? Colors.white : AppTheme.navyBlue,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 1: Arm Type ─────────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Arm Type'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Right Arm',
                                    icon: Icons.sports_cricket_rounded,
                                    isSelected: _selectedArm == 'Right Arm',
                                    onTap: () => setState(() => _selectedArm = 'Right Arm'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Left Arm',
                                    icon: Icons.sports_cricket_outlined,
                                    isSelected: _selectedArm == 'Left Arm',
                                    onTap: () => setState(() => _selectedArm = 'Left Arm'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 2: Bowler Type ──────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Bowler Type'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Pace',
                                    icon: Icons.bolt_rounded,
                                    isSelected: _selectedBowlerType == 'Pace',
                                    onTap: () => setState(() => _selectedBowlerType = 'Pace'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Off Spin',
                                    icon: Icons.sync_rounded,
                                    isSelected: _selectedBowlerType == 'Off Spin',
                                    onTap: () => setState(() => _selectedBowlerType = 'Off Spin'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Wrist Spin',
                                    icon: Icons.autorenew_rounded,
                                    isSelected: _selectedBowlerType == 'Wrist Spin',
                                    onTap: () => setState(() => _selectedBowlerType = 'Wrist Spin'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 3: Length (Slot, Full, Good, Short) ─────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Length'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Slot',
                                    icon: Icons.rocket_launch_rounded,
                                    isSelected: _selectedLength == 'Slot',
                                    onTap: () => setState(() => _selectedLength = 'Slot'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Full',
                                    icon: Icons.adjust_rounded,
                                    isSelected: _selectedLength == 'Full',
                                    onTap: () => setState(() => _selectedLength = 'Full'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Good',
                                    icon: Icons.terrain_rounded,
                                    isSelected: _selectedLength == 'Good',
                                    onTap: () => setState(() => _selectedLength = 'Good'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Short',
                                    icon: Icons.directions_run_rounded,
                                    isSelected: _selectedLength == 'Short',
                                    onTap: () => setState(() => _selectedLength = 'Short'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 4: Speed Setting ────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Speed Setting'),
                            const SizedBox(height: 4),
                            Text(
                              'Speed: ${_ballSpeed.toInt()} kmph',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.electricBlue,
                                inactiveTrackColor: const Color(0xFFE2E8F0),
                                thumbColor: AppTheme.electricBlue,
                                overlayColor: AppTheme.electricBlue.withValues(alpha: 0.15),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _ballSpeed,
                                min: 50,
                                max: 150,
                                divisions: 10,
                                onChanged: (val) => setState(() => _ballSpeed = val),
                              ),
                            ),
                            // Speed Tick Markers: 50 70 90 100 130 150
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('50', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  Text('70', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  Text('90', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.electricBlue)),
                                  Text('100', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  Text('130', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  Text('150', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 5: Variation & Direction ────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Variation & Direction'),
                            const SizedBox(height: 12),
                            // Variation (Swing | Seam)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Swing',
                                    icon: Icons.air_rounded,
                                    isSelected: _selectedVariation == 'Swing',
                                    onTap: () => setState(() => _selectedVariation = 'Swing'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Seam',
                                    icon: Icons.trending_up_rounded,
                                    isSelected: _selectedVariation == 'Seam',
                                    onTap: () => setState(() => _selectedVariation = 'Seam'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Choose Direction (In | Out)
                            _buildCardTitle('Choose Direction'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'In',
                                    icon: Icons.south_west_rounded,
                                    isSelected: _selectedDirection == 'In',
                                    onTap: () => setState(() => _selectedDirection = 'In'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Out',
                                    icon: Icons.north_east_rounded,
                                    isSelected: _selectedDirection == 'Out',
                                    onTap: () => setState(() => _selectedDirection = 'Out'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Levels (Basic | Medium | High)
                            _buildCardTitle('Levels'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Basic',
                                    isSelected: _selectedLevel == 'Basic',
                                    onTap: () => setState(() => _selectedLevel = 'Basic'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'Medium',
                                    isSelected: _selectedLevel == 'Medium',
                                    onTap: () => setState(() => _selectedLevel = 'Medium'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSelectableButton(
                                    label: 'High',
                                    isSelected: _selectedLevel == 'High',
                                    onTap: () => setState(() => _selectedLevel = 'High'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Card 6: Randomization ────────────────────────────────
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardTitle('Randomization'),
                            const SizedBox(height: 10),
                            _buildToggleRow(
                              title: 'Random Spin/Swing',
                              value: _randomSpin,
                              onChanged: (val) => setState(() => _randomSpin = val),
                            ),
                            const SizedBox(height: 8),
                            _buildToggleRow(
                              title: 'Random Length',
                              value: _randomLength,
                              onChanged: (val) => setState(() => _randomLength = val),
                            ),
                            const SizedBox(height: 8),
                            _buildToggleRow(
                              title: 'Random Speed',
                              value: _randomSpeed,
                              onChanged: (val) => setState(() => _randomSpeed = val),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ── 3. Bottom Action Buttons: Save | Copy to All Overs ───────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _onSave,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: AppTheme.primaryCtaGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue.withAlpha(80),
                                blurRadius: 12,
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
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: AppTheme.primaryCtaGradient,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.5),
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppTheme.primaryCtaGradient.createShader(bounds),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
        fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryCtaGradient : null,
          color: isSelected ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.electricBlue.withAlpha(50),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppTheme.navyBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.navyBlue,
          ),
        ),
        CyberGradientSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// ── Session QR Code View & Share Dialog ─────────────────────────────────────
class SessionQrShareDialog extends StatelessWidget {
  final SessionItem? sessionItem;
  final String? sessionTitle;
  final double? speed;
  final String? armType;
  final String bowlerType;
  final String length;
  final String variation;
  final String? machineId;
  final VoidCallback onDone;

  const SessionQrShareDialog({
    super.key,
    this.sessionItem,
    this.sessionTitle,
    this.speed,
    this.armType,
    this.bowlerType = 'Pace',
    this.length = 'Good',
    this.variation = 'Swing',
    this.machineId,
    required this.onDone,
  });

  String get _title => sessionItem?.name ?? sessionTitle ?? 'Cricket Session';
  String get _speedStr => sessionItem?.speed ?? '${speed?.toStringAsFixed(1) ?? '140.0'} km/h';
  String get _arm => sessionItem?.armType ?? armType ?? 'Right Arm';
  String get _bowler => sessionItem?.bowlerType ?? bowlerType;
  String get _len => sessionItem?.length ?? length;
  String get _var => sessionItem?.variation ?? variation;
  String get _dir => sessionItem?.direction ?? 'In';
  String get _lvl => sessionItem?.level ?? 'Medium';
  String get _oversCount => sessionItem?.oversCount ?? '6 Overs';
  String get _lane => sessionItem?.lane ?? 'Hexgen Turf';
  String get _date => sessionItem?.date ?? '14 November 2026';
  String get _time => sessionItem?.time ?? 'Practice Session';
  String get _code => machineId ?? 'HEX-${(_title.hashCode.abs() % 9000 + 1000)}';

  String get qrDataText => '''
🏏 HEXGEN CONNECT • PRACTICE SESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 Session: $_title
⚡ Speed: $_speedStr
👤 Bowler: $_bowler ($_arm)
📏 Pitch Length: $_len Length
🌀 Delivery: $_var ($_dir - $_lvl)
🔢 Total Overs: $_oversCount
🆔 Machine ID: $_code
📅 Date: $_date • $_time
📍 Turf: $_lane
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: Configured & Ready to Bowl
'''.trim();

  void _copyShareDetails(BuildContext context) {
    Clipboard.setData(ClipboardData(text: qrDataText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Session details copied to clipboard!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.navyBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Save Tag & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF86EFAC),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 14),
                        SizedBox(width: 5),
                        Text(
                          'SAVED IN APP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16A34A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onDone,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title & Subtitle
              Text(
                _title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Scan this QR code from any other phone camera or Google Lens to view full session details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 16),

              // ── REAL SCANNABLE QR CODE CONTAINER ──────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052FF).withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: QrImageView(
                        data: qrDataText,
                        version: QrVersions.auto,
                        size: 185.0,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0F172A),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F172A),
                        ),
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Machine pairing ID tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ID: $_code • $_speedStr',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0052FF),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Session Quick Spec Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _buildSpecChip('$_bowler • $_arm'),
                  _buildSpecChip('$_len Length'),
                  _buildSpecChip('$_var Delivery'),
                ],
              ),

              const SizedBox(height: 18),

              // ── Action Buttons: Copy Details & Done ─────────────────────────
              Row(
                children: [
                  // Copy Details / Share
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _copyShareDetails(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_rounded, size: 16, color: Color(0xFF0052FF)),
                            SizedBox(width: 6),
                            Text(
                              'Share Details',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0052FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Done Button
                  Expanded(
                    child: GestureDetector(
                      onTap: onDone,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryCtaGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}


