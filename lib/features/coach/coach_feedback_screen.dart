import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../services/demo_state.dart';

class CoachFeedbackScreen extends StatefulWidget {
  const CoachFeedbackScreen({super.key});

  @override
  State<CoachFeedbackScreen> createState() => _CoachFeedbackScreenState();
}

class _CoachFeedbackScreenState extends State<CoachFeedbackScreen> {
  final DemoState _state = DemoState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> f = _state.published ?? _state.draft ?? {};

    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.iceBlue,
        elevation: 0,
        title: const Text(
          'Coach Feedback Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            fontFamily: 'Roboto',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.navyBlue, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            // Executive Summary Card
            _buildExecutiveSummaryCard(f),
            const SizedBox(height: 20),

            // Shot-by-shot Technical Observations
            _sectionLabel('SHOT-BY-SHOT TECHNICAL OBSERVATIONS'),
            const SizedBox(height: 10),
            _buildFormattedNotesList(f['note'] ?? ''),
            const SizedBox(height: 24),

            // Captured Frame Snapshots & Media Gallery
            _sectionLabel('CAPTURED FRAME SNAPSHOTS & MEDIA'),
            const SizedBox(height: 10),
            _buildMediaGallery(),
            const SizedBox(height: 24),

            // Voice Memo Player
            _sectionLabel('COACH AUDIO MEMO'),
            const SizedBox(height: 10),
            _buildVoiceMemoSection(),
            const SizedBox(height: 24),

            // Recommended YouTube Drill Link
            _sectionLabel('RECOMMENDED REFERENCE DRILL'),
            const SizedBox(height: 10),
            _buildYouTubeLinkCard(),
            const SizedBox(height: 24),

            // Practice Plan Card
            _buildDrillBanner(f['drill'] ?? '6 Slow Shadow Drives'),
            const SizedBox(height: 24),

            // Full Technical Report Button
            HexgenButton(
              text: 'OPEN FULL TECHNICAL REPORT & WAGON WHEEL',
              icon: Icons.analytics_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Wagon Wheel & Trajectory Telemetry...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveSummaryCard(Map<String, String> f) {
    return HexgenCard(
      hasGlow: true,
      hasTopAccent: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.electricBlue,
                child: Text(
                  _state.activeCoachName.replaceAll('Coach ', '')[0],
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_state.activeCoachName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
                    Text(_state.activeCoachHandle, style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
                  ],
                ),
              ),
              const HexgenBadge(
                label: 'VERIFIED',
                variant: HexgenBadgeVariant.volt,
                fontSize: 8.5,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _feedbackBlock('YOUR STRENGTH', f['strength'] ?? 'High elbow alignment on front foot drive with stable body posture.', Icons.check_circle_outline_rounded, HexgenColors.voltGreen),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: AppTheme.cardBorderColor)),
          _feedbackBlock('YOUR NEXT FOCUS', f['focus'] ?? 'Maintain brace leg firmness on release to avoid falling over to off-side.', Icons.track_changes_rounded, AppTheme.electricBlue),
        ],
      ),
    );
  }

  Widget _feedbackBlock(String label, String val, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.2, fontFamily: 'Roboto')),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.navyBlue, height: 1.4, fontFamily: 'Roboto')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormattedNotesList(String notes) {
    final lines = notes.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return HexgenCard(
        padding: const EdgeInsets.all(16),
        child: const Text('Watch the highlighted moments and complete six slow shadow drives.', style: TextStyle(fontSize: 12, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
      );
    }

    return Column(
      children: lines.map((line) {
        final cleanLine = line.replaceAll('•', '').trim();
        final parts = cleanLine.split(':');
        final String title = parts.length > 1 ? parts[0].replaceAll('Focus on', '').trim() : 'Observation';
        final String detail = parts.length > 1 ? parts[1].trim() : cleanLine;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: HexgenCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.electricBlue.withAlpha(15), shape: BoxShape.circle),
                  child: const Icon(Icons.analytics_rounded, color: AppTheme.electricBlue, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, letterSpacing: 0.8, fontFamily: 'Roboto')),
                      const SizedBox(height: 2),
                      Text(detail, style: const TextStyle(fontSize: 12.5, color: AppTheme.navyBlue, height: 1.4, fontFamily: 'Roboto')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMediaGallery() {
    return Row(
      children: [
        Expanded(
          child: HexgenCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.iceBlue,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorderColor),
                  ),
                  child: const Center(child: Icon(Icons.camera_alt_rounded, color: AppTheme.electricBlue, size: 24)),
                ),
                const SizedBox(height: 8),
                const Text('FRAME 42 • IMPACT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: HexgenCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.iceBlue,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardBorderColor),
                  ),
                  child: const Icon(Icons.sports_cricket_rounded, color: AppTheme.royalBlue, size: 24),
                ),
                const SizedBox(height: 8),
                const Text('BALL RELEASE SNAP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMemoSection() {
    return HexgenCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.electricBlue.withAlpha(15), shape: BoxShape.circle),
            child: const Icon(Icons.mic_rounded, color: AppTheme.electricBlue, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COACH VOICE MEMO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, letterSpacing: 0.8, fontFamily: 'Roboto')),
                Text('Listen to coach analysis (01:15)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playing Coach Voice Memo...')),
              );
            },
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.electricBlue, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeLinkCard() {
    return HexgenCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill_rounded, color: Colors.redAccent, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECOMMENDED YOUTUBE REFERENCE DRILL', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.redAccent, letterSpacing: 0.8, fontFamily: 'Roboto')),
                Text('https://youtu.be/cricket_high_elbow_drive_drill', style: TextStyle(fontSize: 11, color: AppTheme.navyBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontFamily: 'Roboto')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillBanner(String drillTitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HexgenColors.voltGreen.withAlpha(100), width: 1.2),
        boxShadow: HexgenColors.cardShadow(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YOUR PRACTICE PLAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: HexgenColors.voltGreen, letterSpacing: 1.2, fontFamily: 'Roboto')),
                const SizedBox(height: 6),
                Text(drillTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
                const SizedBox(height: 2),
                const Text('A short, focused drill assigned by your coach.', style: TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.fitness_center_rounded, color: HexgenColors.voltGreen, size: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 12, decoration: BoxDecoration(color: AppTheme.electricBlue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.slateBlue, letterSpacing: 1.2, fontFamily: 'Roboto')),
      ],
    );
  }
}
