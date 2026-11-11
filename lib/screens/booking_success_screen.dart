import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../core/widgets/hexgen_badge.dart';
import '../core/widgets/hexgen_button.dart';
import '../core/widgets/hexgen_card.dart';
import '../features/dashboard/player_dashboard_screen.dart';
import 'my_bookings_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String venueName;
  final String laneInfo;
  final String dateTime;
  final String totalAmount;

  const BookingSuccessScreen({
    super.key,
    this.bookingId = 'HEX-BK77492',
    this.venueName = 'Hexgen Sports Arena',
    this.laneInfo = 'Right-Hand Lane 1 • Synthetic Turf',
    this.dateTime = 'Tomorrow • 09:00 AM - 10:00 AM',
    this.totalAmount = '₹ 1,830',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const PlayerDashboardScreen(
                playerName: 'Rahul Kumar',
                playerId: 'HEX-99481',
                initialIndex: 0,
              ),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CyberGlassBackdrop(
          showOrbs: true,
          showPattern: true,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Celebratory Success Icon ──────────────────────────────
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Success Heading ───────────────────────────────────────
                  const Text(
                    'BOOKING CONFIRMED!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Booking ID: $bookingId',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.electricBlue,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your arena lane and autonomous AI ball telemetry are calibrated and reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.slateBlue,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Digital Stadium Pass Ticket ───────────────────────────
                  HexgenCard(
                    padding: const EdgeInsets.all(20),
                    hasGlow: true,
                    hasTopAccent: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Venue + Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                venueName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.navyBlue,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            const HexgenBadge(
                              label: 'CONFIRMED',
                              variant: HexgenBadgeVariant.volt,
                              fontSize: 9,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          laneInfo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slateBlue,
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Divider(height: 1, color: AppTheme.cardBorderColor),
                        const SizedBox(height: 14),

                        // Row 2: Date & Time
                        _buildDetailRow(
                          icon: Icons.calendar_today_rounded,
                          title: 'SLOT SCHEDULE',
                          value: dateTime,
                        ),

                        const SizedBox(height: 12),

                        // Row 3: Telemetry & Machine Config
                        _buildDetailRow(
                          icon: Icons.tune_rounded,
                          title: 'TELEMETRY CALIBRATION',
                          value: '120 km/h Fast Seam • 6 Overs • 60fps AI Pose',
                        ),

                        const SizedBox(height: 12),

                        // Row 4: Amount Paid
                        _buildDetailRow(
                          icon: Icons.receipt_long_rounded,
                          title: 'PAYMENT STATUS',
                          value: '$totalAmount • Paid Online (Verified)',
                          valueColor: const Color(0xFF10B981),
                        ),

                        const SizedBox(height: 18),

                        // Simulated Turnstile Barcode
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.iceBlue,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.lightBlue),
                          ),
                          child: Column(
                            children: [
                              CustomPaint(
                                size: const Size(220, 52),
                                painter: _TicketBarcodePainter(),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '* $bookingId *',
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  letterSpacing: 3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Scan at Gate B Turnstile to unlock lane nets',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.slateBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Action Buttons ────────────────────────────────────────
                  HexgenButton(
                    text: 'VIEW IN MY BOOKINGS',
                    icon: Icons.confirmation_number_outlined,
                    height: 52,
                    borderRadius: 16,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsScreen(returnToDashboard: true),
                        ),
                        (route) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text(
                      'BACK TO ARENA DASHBOARD',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlayerDashboardScreen(
                            playerName: 'Rahul Kumar',
                            playerId: 'HEX-99481',
                            initialIndex: 0,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.navyBlue,
                      side: const BorderSide(color: AppTheme.cardBorderColor, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.iceBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppTheme.electricBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slateBlue,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppTheme.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketBarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.navyBlue
      ..style = PaintingStyle.fill;

    final List<double> widths = [
      3, 1, 4, 2, 1, 3, 2, 4, 1, 2, 3, 1, 4, 2, 1, 3, 1, 2, 4, 3, 1, 2, 4, 1, 3, 2, 1, 4, 2, 3, 1, 2
    ];
    final List<double> spaces = [
      2, 3, 1, 2, 4, 2, 1, 3, 2, 1, 2, 3, 1, 2, 4, 2, 3, 1, 2, 1, 3, 2, 1, 4, 2, 1, 3, 2, 1, 2, 3, 1
    ];

    double currentX = 12;
    for (int i = 0; i < widths.length && currentX < size.width - 12; i++) {
      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, widths[i], size.height),
        paint,
      );
      currentX += widths[i] + spaces[i % spaces.length];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
