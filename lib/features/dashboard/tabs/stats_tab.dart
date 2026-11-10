import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/hexgen_colors.dart';
import '../../../core/widgets/hexgen_card.dart';
import '../../../services/demo_state.dart';
import '../../coach/coach_feedback_screen.dart';

class StatsTab extends StatefulWidget {
  final bool isSubscribed;
  final VoidCallback onUnlockSubscription;

  const StatsTab({
    super.key,
    required this.isSubscribed,
    required this.onUnlockSubscription,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  final DemoState _state = DemoState();
  final TextEditingController _aiPromptController = TextEditingController();
  bool _hasAsked = false;
  bool _isAnalyzing = false;
  String _aiResponseText = '';

  @override
  void dispose() {
    _aiPromptController.dispose();
    super.dispose();
  }

  void _handleAskAi() {
    final query = _aiPromptController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question for the AI Assistant.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasAsked = true;
      _aiResponseText = '';
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        final q = query.toLowerCase();
        if (q.contains('focus') || q.contains('work') || q.contains('summary')) {
          _aiResponseText =
              "Based on recent sessions, ${_state.playerName.split(' ')[0]} excels at executing the Yorker (85% consistency) and maintaining peak velocity (142 km/h). His In-Swing deliveries are also highly effective. Focus areas should be the brace leg alignment to prevent falling away in the delivery stride, which occasionally affects his Out-Swing consistency.";
        } else if (q.contains('speed') || q.contains('velo') || q.contains('fast')) {
          _aiResponseText =
              "Peak Delivery Speed: 142.4 km/h (+2.4% vs previous rolling 30-day average). Hip-shoulder separation sequence is operating in top 5% elite professional range.";
        } else if (q.contains('spin') || q.contains('rotation') || q.contains('turn')) {
          _aiResponseText =
              "Spin Variations: Off-spin revolutions average 2,150 RPM with high drift angle. Focus on maintaining consistent release wrist flex to maximize dip.";
        } else {
          _aiResponseText =
              "AI Performance Analysis for ${_state.playerName}: Consistently hitting target length areas across Yorker & In-Swing variations with 85% accuracy. Focus on front-leg brace stability during delivery release.";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : HexgenColors.navyBlue;
    final Color subTextColor = isDark ? Colors.white38 : HexgenColors.slateBlue;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Assistant Banner Card
          _buildAiAssistantCard(isDark, textColor, subTextColor),
          const SizedBox(height: 24),

          // Ball Types Executed Progress Bars
          _buildBallTypesExecutedCard(isDark, textColor, subTextColor),
          const SizedBox(height: 20),

          // Execution Consistency Donut Ring
          _buildExecutionConsistencyCard(isDark, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildAiAssistantCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: HexgenColors.navyBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: HexgenColors.cardShadow(opacity: 0.15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  color: HexgenColors.electricBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Performance Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ask anything about your stats, performance trends, or coach feedback.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          // Prompt Input Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _aiPromptController,
                    style: GoogleFonts.inter(color: HexgenColors.navyBlue, fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "e.g., 'What works well and what needs focus?'",
                      hintStyle: GoogleFonts.inter(color: HexgenColors.slateBlue.withAlpha(120), fontSize: 11),
                    ),
                    onSubmitted: (_) => _handleAskAi(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _handleAskAi,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: HexgenColors.electricBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isAnalyzing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Ask',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          if (_hasAsked && _aiResponseText.isNotEmpty) ...[
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: _isAnalyzing
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Analyzing biomechanics & telemetry data...', style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic)),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Summary for Player (${_state.playerName})',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFACC15),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _aiResponseText,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withAlpha(230),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CoachFeedbackScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Technical Evolution',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: HexgenColors.navyBlue,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 12, color: HexgenColors.navyBlue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBallTypesExecutedCard(bool isDark, Color textColor, Color subTextColor) {
    final ballTypes = [
      {'name': 'Yorker', 'percent': 0.35, 'valStr': '35%', 'color': HexgenColors.electricBlue},
      {'name': 'In-Swing', 'percent': 0.25, 'valStr': '25%', 'color': const Color(0xFF10B981)},
      {'name': 'Out-Swing', 'percent': 0.20, 'valStr': '20%', 'color': const Color(0xFFF59E0B)},
      {'name': 'Bouncer', 'percent': 0.15, 'valStr': '15%', 'color': const Color(0xFFEF4444)},
      {'name': 'Spin (Off/Leg variations)', 'percent': 0.05, 'valStr': '5%', 'color': const Color(0xFF8B5CF6)},
    ];

    return HexgenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ball Types Executed',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          ...ballTypes.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b['name'] as String,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: subTextColor),
                    ),
                    Text(
                      b['valStr'] as String,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: b['color'] as Color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: b['percent'] as double,
                    minHeight: 6,
                    backgroundColor: HexgenColors.iceBlue,
                    color: b['color'] as Color,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExecutionConsistencyCard(bool isDark, Color textColor, Color subTextColor) {
    return HexgenCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 120, height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 110, height: 110,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 10,
                    color: HexgenColors.electricBlue,
                    backgroundColor: HexgenColors.iceBlue,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '85%',
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
                    ),
                    Text(
                      'ACCURACY',
                      style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w900, color: subTextColor, letterSpacing: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Execution Consistency',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Consistently hitting target areas based on trajectory data from the last 5 practice sessions.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 11, color: subTextColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}
