import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'check_slots_screen.dart';
import 'checkout_screen.dart';

class BookingStagesScreen extends StatefulWidget {
  final String selectedSport;

  const BookingStagesScreen({
    super.key,
    this.selectedSport = 'Cricket',
  });

  @override
  State<BookingStagesScreen> createState() => _BookingStagesScreenState();
}

class _BookingStagesScreenState extends State<BookingStagesScreen> {
  bool _stage1Completed = false;

  int get _currentStage => _stage1Completed ? 2 : 1;

  void _openStage1() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckSlotsScreen(),
      ),
    );
    if (result == true || result != null) {
      setState(() {
        _stage1Completed = true;
      });
    }
  }

  void _openStage2() {
    if (!_stage1Completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete Stage 1 (Select Slot) first.'),
          backgroundColor: AppTheme.navyBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _stage1Completed ? 1.0 : 0.5;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
                  // ── Top Bar with Centered One6 Logo ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
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
                        ),
                        _buildHexgenLogo(),
                      ],
                    ),
                  ),

                  // ── Top Segmented Progress Bar ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Booking Journey',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slateBlue,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.badgePurpleBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Stage $_currentStage of 2',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.electricBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFDDE8F7),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.electricBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Main Glassmorphic Journey Card ───────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xFFD6E4F8),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
                                  blurRadius: 22,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: AppTheme.electricBlue.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Venue Pill Header
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: AppTheme.iceBlue,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppTheme.skyBlue.withAlpha(140),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.selectedSport == 'Pickleball'
                                              ? Icons.sports_baseball_rounded
                                              : Icons.sports_cricket_rounded,
                                          color: AppTheme.electricBlue,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'HexGen Sports Arena (${widget.selectedSport})',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.navyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                const Text(
                                  'Complete Booking Stages',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                    letterSpacing: -0.3,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text(
                                  'Follow the 2 quick steps below to confirm your session',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.slateBlue,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ── Timeline Journey Nodes ─────────────────────────
                                Stack(
                                  children: [
                                    // Connecting Vertical Line
                                    Positioned(
                                      left: 21,
                                      top: 36,
                                      bottom: 36,
                                      width: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              _stage1Completed
                                                  ? const Color(0xFF22C55E)
                                                  : AppTheme.electricBlue,
                                              _stage1Completed
                                                  ? AppTheme.electricBlue
                                                  : const Color(0xFFCBD5E1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        // ── Stage 1 Node ────────────────────
                                        _buildTimelineStageNode(
                                          stageNum: 1,
                                          title: 'Select Slot',
                                          subtitle:
                                              'Choose date & preferred time slots',
                                          summary: _stage1Completed
                                              ? '05 Sep 2025 • 2 Slots Selected'
                                              : null,
                                          icon: Icons.event_available_rounded,
                                          isCompleted: _stage1Completed,
                                          isCurrent: _currentStage == 1,
                                          buttonLabel: _stage1Completed
                                              ? 'Edit'
                                              : 'Select Slots',
                                          onTap: _openStage1,
                                        ),

                                        const SizedBox(height: 24),

                                        // ── Stage 2 Node ────────────────────
                                        _buildTimelineStageNode(
                                          stageNum: 2,
                                          title: 'Checkout',
                                          subtitle:
                                              'Review booking summary & pay',
                                          summary: null,
                                          icon: Icons.payments_rounded,
                                          isCompleted: false,
                                          isCurrent: _currentStage == 2,
                                          buttonLabel: _stage1Completed
                                              ? 'Pay Now'
                                              : 'Locked',
                                          onTap: _openStage2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // ── Stylized Motivational Banner ───────────────
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEFF6FF),
                                        Color(0xFFDBEAFE)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          AppTheme.electricBlue.withAlpha(50),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.sports_baseball_rounded,
                                          color: AppTheme.electricBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Unleash Your Game',
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.navyBlue,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '2 simple steps to confirm your slot',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: AppTheme.slateBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildTimelineStageNode({
    required int stageNum,
    required String title,
    required String subtitle,
    required String? summary,
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    final isEnabled = isCompleted || isCurrent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node Number Badge / Indicator Circle
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCompleted
                  ? const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    )
                  : isCurrent
                      ? AppTheme.primaryCtaGradient
                      : null,
              color: isEnabled ? null : const Color(0xFFE2E8F0),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppTheme.electricBlue.withAlpha(90),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : isCompleted
                      ? [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      '0$stageNum',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color:
                            isCurrent ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Stage Content Box
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Colors.white
                    : isCompleted
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCurrent
                      ? AppTheme.electricBlue
                      : isCompleted
                          ? const Color(0xFF22C55E)
                          : AppTheme.cardBorderColor,
                  width: isCurrent ? 1.8 : 1.2,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppTheme.electricBlue.withAlpha(18),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: isCompleted
                            ? const Color(0xFF16A34A)
                            : isCurrent
                                ? AppTheme.electricBlue
                                : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isCompleted
                                ? const Color(0xFF15803D)
                                : isCurrent
                                    ? AppTheme.navyBlue
                                    : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slateBlue,
                    ),
                  ),

                  if (summary != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Action Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: isCompleted
                            ? const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                              )
                            : isCurrent
                                ? AppTheme.primaryCtaGradient
                                : null,
                        color: isEnabled ? null : const Color(0xFFE2E8F0),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppTheme.electricBlue.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isEnabled
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHexgenLogo() {
    return const Text(
      'HEXGEN CONNECT',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: AppTheme.navyBlue,
        letterSpacing: 0.8,
        fontFamily: 'Roboto',
      ),
    );
  }
}
