import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/hexgen_badge.dart';

enum AnalysisMode { biomechanics, pitchCalibration }

class LiveAnalysisScreen extends StatefulWidget {
  final AnalysisMode mode;
  final Map<String, dynamic>? sessionConfig;
  final String? playerName;

  const LiveAnalysisScreen({
    super.key,
    this.mode = AnalysisMode.biomechanics,
    this.sessionConfig,
    this.playerName,
  });

  @override
  State<LiveAnalysisScreen> createState() => _LiveAnalysisScreenState();
}

class _LiveAnalysisScreenState extends State<LiveAnalysisScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  int _ballCount = 1;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _secondsElapsed = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) {
          setState(() {
            _secondsElapsed++;
            if (_secondsElapsed % 8 == 0 && _ballCount < 36) {
              _ballCount++;
            }
          });
        }
      });
    } else {
      _timer?.cancel();
      _showFinishSessionDialog();
    }
  }

  void _showFinishSessionDialog() {
    final speed = widget.sessionConfig?['speed'] ?? 120;
    final overs = widget.sessionConfig?['overs'] ?? 6;
    final type = widget.sessionConfig?['type'] ?? 'Fast Seam';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_cricket_rounded,
                color: Color(0xFF16A34A),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SESSION TELEMETRY LOGGED!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recorded $_secondsElapsed secs • Ball #$_ballCount\nMachine calibrated at $speed km/h ($type) for $overs Overs.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.slateBlue,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.iceBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.lightBlue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppTheme.electricBlue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI Biomechanics report sent to Coach Madhu for review.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, true); // Pop LiveAnalysis with true -> switch to Sessions Tab!
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.electricBlue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'VIEW IN SESSIONS TAB',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bool isBio = widget.mode == AnalysisMode.biomechanics;
    final int speed = widget.sessionConfig?['speed'] ?? 120;
    final String bowlerType = widget.sessionConfig?['type'] ?? 'Fast Seam';
    final String arm = widget.sessionConfig?['arm'] ?? 'Right Arm';
    final int targetOvers = widget.sessionConfig?['overs'] ?? 6;

    final String title = isBio ? 'BIOMECHANICS POSE ENGINE' : '3D PITCH CALIBRATION';

    return Scaffold(
      backgroundColor: AppTheme.navyBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Simulated Camera / Tracking Surface ───────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF04122E),
                    Color(0xFF08204D),
                    Color(0xFF020B1C),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Tactical Grid Overlay
                  CustomPaint(
                    size: Size.infinite,
                    painter: _TacticalGridPainter(pulseValue: _pulseController.value),
                  ),

                  // Center Pose Tracking Wireframe Graphic
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isRecording ? const Color(0xFF00FF66) : AppTheme.cyanBlue,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: (_isRecording ? const Color(0xFF00FF66) : AppTheme.cyanBlue).withValues(alpha: 0.06),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.accessibility_new_rounded,
                              size: 110,
                              color: (_isRecording ? const Color(0xFF00FF66) : AppTheme.cyanBlue).withValues(alpha: 0.7),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _isRecording ? 'TRACKING' : 'CALIBRATING',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: _isRecording ? const Color(0xFF00FF66) : AppTheme.cyanBlue,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _isRecording ? 'POSE SYNC: 60 FPS • 18 JOINTS ACTIVE' : 'CALIBRATING NEURAL SENSORS...',
                        style: TextStyle(
                          color: _isRecording ? const Color(0xFF00FF66) : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 2. Top Header Bar & Status HUD ────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_isRecording) {
                              _showFinishSessionDialog();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              Text(
                                '$arm • $bowlerType • $targetOvers Overs Target',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        HexgenBadge(
                          label: _isRecording ? 'REC ${_formatTimer(_secondsElapsed)}' : 'READY',
                          variant: _isRecording ? HexgenBadgeVariant.volt : HexgenBadgeVariant.primary,
                          fontSize: 9.5,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Quick Telemetry Stat HUD Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHudMetric('BALL SPEED', '$speed km/h', const Color(0xFF20C9F5)),
                          _buildHudMetric('BALL COUNT', '$_ballCount / ${targetOvers * 6}', const Color(0xFF00FF66)),
                          _buildHudMetric('ELBOW EXT', '142°', Colors.white),
                          _buildHudMetric('BALANCE', '96%', const Color(0xFFF59E0B)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Bottom Controls & Action Bar ───────────────────────────────
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Record / Stop Big Button
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: _isRecording
                                ? const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)])
                                : AppTheme.primaryCtaGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? const Color(0xFFEF4444) : AppTheme.electricBlue).withValues(alpha: 0.5),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRecording ? 'FINISH & LOG SESSION' : 'START RECORDING DRILL',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudMetric(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: valueColor,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}

// ── Tactical HUD Grid Background Painter ─────────────────────────────────────
class _TacticalGridPainter extends CustomPainter {
  final double pulseValue;

  _TacticalGridPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF0075FF).withValues(alpha: 0.08 + (pulseValue * 0.04))
      ..strokeWidth = 1.0;

    const double step = 32.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalGridPainter oldDelegate) =>
      oldDelegate.pulseValue != pulseValue;
}
