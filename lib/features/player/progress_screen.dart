import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../services/demo_state.dart';
import '../coach/coach_feedback_screen.dart';
import 'player_reviews_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.iceBlue,
        elevation: 0,
        title: const Text(
          'Progress & Journey',
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
            _sectionLabel('LATEST COACH FEEDBACK & PRESCRIPTION'),
            const SizedBox(height: 10),
            _buildLatestCoachFeedbackCard(),
            const SizedBox(height: 24),

            _sectionLabel('ASSIGNED PRACTICE DRILLS'),
            const SizedBox(height: 10),
            _buildAssignedDrillsList(),
            const SizedBox(height: 24),

            _sectionLabel('TECHNICAL EVOLUTION TIMELINE'),
            const SizedBox(height: 10),
            _buildJourneyTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCoachFeedbackCard() {
    final Map<String, dynamic>? latestReview = _state.allReviews.isNotEmpty ? _state.allReviews.first : null;
    final String coachName = latestReview?['coachName'] ?? _state.activeCoachName;
    final String coachHandle = latestReview?['coachHandle'] ?? _state.activeCoachHandle;
    final String focusText = latestReview?['focus'] ?? 'Aim to finish your drive in a position you can hold comfortably.';
    final String sessionStr = latestReview?['session'] ?? 'SESSION U15S125';
    final String dateStr = latestReview?['date'] ?? 'Today';

    return HexgenCard(
      hasGlow: true,
      hasTopAccent: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: HexgenColors.voltGreen.withAlpha(15), shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_rounded, color: HexgenColors.voltGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coachName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
                    Text('$coachHandle • $dateStr • $sessionStr', style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
                  ],
                ),
              ),
              const HexgenBadge(
                label: 'FEEDBACK READY',
                variant: HexgenBadgeVariant.volt,
                fontSize: 8.5,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.iceBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TECHNICAL FOCUS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, letterSpacing: 0.8, fontFamily: 'Roboto')),
                const SizedBox(height: 4),
                Text('“$focusText”', style: const TextStyle(fontSize: 12.5, color: AppTheme.navyBlue, fontStyle: FontStyle.italic, height: 1.4, fontFamily: 'Roboto')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HexgenButton(
            text: 'View All Coach Reviews Archive',
            icon: Icons.history_edu_rounded,
            isOutlined: true,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerReviewsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedDrillsList() {
    if (_state.assignedCustomDrills.isEmpty) {
      return HexgenCard(
        padding: const EdgeInsets.all(20),
        child: const Text('No custom drills assigned yet.', style: TextStyle(fontSize: 12, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
      );
    }

    return Column(
      children: _state.assignedCustomDrills.map((d) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: HexgenCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.electricBlue.withAlpha(15), shape: BoxShape.circle),
                  child: const Icon(Icons.fitness_center_rounded, color: AppTheme.electricBlue, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
                      Text('${d['reps']} • Assigned by ${d['coach']}', style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontFamily: 'Roboto')),
                    ],
                  ),
                ),
                const HexgenBadge(
                  label: 'ACTIVE',
                  variant: HexgenBadgeVariant.volt,
                  fontSize: 8.5,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildJourneyTimeline() {
    final journey = [
      {'id': 125, 'title': 'Finding my rhythm', 'desc': 'Coach feedback ready & published'},
      {'id': 121, 'title': 'Pace attack & line alignment', 'desc': 'Coach feedback published • 6 Slow Shadow Drives'},
      {'id': 120, 'title': 'Front-foot foundations', 'desc': 'Settled starting routine & trigger timing'},
    ];

    return HexgenCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: journey.map((item) {
          int idx = journey.indexOf(item);
          bool isLast = idx == journey.length - 1;
          return IntrinsicHeight(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachFeedbackScreen()));
              },
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(width: 12, height: 12, decoration: const BoxDecoration(color: HexgenColors.voltGreen, shape: BoxShape.circle)),
                      if (!isLast) Expanded(child: Container(width: 2, color: AppTheme.cardBorderColor)),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SESSION ${item['id']}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, letterSpacing: 0.8, fontFamily: 'Roboto')),
                          const SizedBox(height: 3),
                          Text(item['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto')),
                          Text(item['desc'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.slateBlue, fontWeight: FontWeight.w500, fontFamily: 'Roboto')),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.slateBlue, size: 14),
                ],
              ),
            ),
          );
        }).toList(),
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
