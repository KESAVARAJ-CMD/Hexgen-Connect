import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../services/demo_state.dart';
import '../coach/coach_feedback_screen.dart';

class PlayerReviewsScreen extends StatefulWidget {
  const PlayerReviewsScreen({super.key});

  @override
  State<PlayerReviewsScreen> createState() => _PlayerReviewsScreenState();
}

class _PlayerReviewsScreenState extends State<PlayerReviewsScreen> {
  final DemoState _state = DemoState();
  String _selectedDateFilter = 'ALL DATES';

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
    final dates = ['ALL DATES', 'TODAY', '12 SEP 2023', '10 SEP 2023'];

    final filtered = _state.allReviews.where((rev) {
      if (_selectedDateFilter == 'ALL DATES') return true;
      final d = (rev['date'] as String).toUpperCase();
      if (_selectedDateFilter == 'TODAY') return d.contains('TODAY');
      if (_selectedDateFilter == '12 SEP 2023') return d.contains('12 SEP');
      if (_selectedDateFilter == '10 SEP 2023') return d.contains('10 SEP');
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: Stack(
        children: [
          // 1. Top Soft Canopy Header
          Positioned(
            top: 0, left: 0, right: 0,
            height: 170,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryCtaGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'COACH FEEDBACK ARCHIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const HexgenBadge(
                            label: 'ARCHIVE',
                            variant: HexgenBadgeVariant.volt,
                            fontSize: 9,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Text(
                          'Date-wise technical prescriptions & reports',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          Positioned.fill(
            top: 125,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Filter Pills Row
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        bool active = _selectedDateFilter == date;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDateFilter = date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: active ? AppTheme.primaryCtaGradient : null,
                              color: !active ? AppTheme.pureWhite : null,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? Colors.transparent : AppTheme.cardBorderColor,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.navyBlue.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              date,
                              style: TextStyle(
                                color: active ? Colors.white : AppTheme.navyBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Reviews List
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'NO REVIEWS FOUND FOR THIS DATE',
                              style: TextStyle(
                                color: AppTheme.slateBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final rev = filtered[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                child: HexgenCard(
                                  hasGlow: true,
                                  hasTopAccent: index == 0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.iceBlue,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppTheme.cardBorderColor),
                                            ),
                                            child: const Icon(Icons.verified_user_rounded, color: AppTheme.electricBlue, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        rev['coachName'] ?? 'Coach',
                                                        style: const TextStyle(
                                                          color: AppTheme.navyBlue,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w900,
                                                          fontFamily: 'Roboto',
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const HexgenBadge(
                                                      label: 'PUBLISHED',
                                                      variant: HexgenBadgeVariant.volt,
                                                      fontSize: 8.5,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${rev['coachHandle']} • ${rev['date']}',
                                                  style: const TextStyle(
                                                    color: AppTheme.slateBlue,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.iceBlue,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppTheme.lightBlue),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'TECHNICAL FOCUS',
                                              style: TextStyle(
                                                color: AppTheme.electricBlue,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              rev['focus'] ?? '',
                                              style: const TextStyle(
                                                color: AppTheme.navyBlue,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                height: 1.3,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              'ASSIGNED DRILL',
                                              style: TextStyle(
                                                color: AppTheme.electricBlue,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                const Icon(Icons.fitness_center_rounded, color: AppTheme.electricBlue, size: 14),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    rev['drill'] ?? '',
                                                    style: const TextStyle(
                                                      color: AppTheme.navyBlue,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      HexgenButton(
                                        text: 'OPEN FULL ANALYSIS SHEET (${rev['session']})',
                                        icon: Icons.analytics_rounded,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const CoachFeedbackScreen()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
