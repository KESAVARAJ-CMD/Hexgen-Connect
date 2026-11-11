import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/network/api_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/hexgen_badge.dart';
import '../core/widgets/hexgen_button.dart';
import '../core/widgets/hexgen_card.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/dashboard/player_dashboard_screen.dart';
import 'session_config_screen.dart';
import 'venue_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final int initialTab; // 0: Upcoming, 1: Past
  final bool returnToDashboard;

  const MyBookingsScreen({
    super.key,
    this.initialTab = 0,
    this.returnToDashboard = false,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late int _selectedTab;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _fetchLiveBookings();
  }

  Future<void> _fetchLiveBookings() async {
    setState(() => _isLoading = true);
    final bookings = await ApiService().getMyBookings();
    if (!mounted) return;
    
    final upcoming = <Map<String, dynamic>>[];
    final past = <Map<String, dynamic>>[];

    for (final b in bookings) {
      final status = (b['status'] ?? 'CONFIRMED').toString().toUpperCase();
      final mappedItem = {
        'id': b['bookingId'] ?? b['id'] ?? 'HEX-BK',
        'venue': b['venueName'] ?? b['venue'] ?? 'Hexgen Sports Arena',
        'lane': b['lane'] ?? 'Right-Hand Lane 1 • Synthetic Turf',
        'location': b['location'] ?? 'Shanthinagar, Bangalore',
        'date': b['date'] ?? 'Upcoming',
        'time': (b['timeSlots'] is List) ? (b['timeSlots'] as List).join(', ') : (b['time'] ?? '09:00 AM - 10:00 AM'),
        'sport': b['sport'] ?? 'Cricket',
        'status': status,
        'badgeVariant': status == 'COMPLETED'
            ? HexgenBadgeVariant.primary
            : (status == 'CANCELLED' ? HexgenBadgeVariant.gold : HexgenBadgeVariant.volt),
        'price': (b['totalAmount'] != null) ? '₹ ${b['totalAmount']}' : (b['price'] ?? '₹ 1,830'),
        'bowlerConfig': b['bowlerConfig'] ?? '120 km/h • Fast Seam • 6 Overs',
        'tracking': b['tracking'] ?? '60fps AI Pose Calibration',
        'coach': b['coach'] ?? 'Coach Madhu (Assigned)',
        'entryGate': b['entryGate'] ?? 'Gate B • Lane Turnstile 01',
      };

      if (status == 'COMPLETED' || status == 'CANCELLED') {
        past.add(mappedItem);
      } else {
        upcoming.add(mappedItem);
      }
    }

    setState(() {
      _upcomingBookings.clear();
      _upcomingBookings.addAll(upcoming);
      _pastBookings.clear();
      _pastBookings.addAll(past);
      _isLoading = false;
    });
  }

  final List<Map<String, dynamic>> _upcomingBookings = [];
  final List<Map<String, dynamic>> _pastBookings = [];

  void _showQrPassModal(BuildContext context, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: _QrPassBottomSheet(booking: booking),
      ),
    );
  }

  void _confirmCancelBooking(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text(
              'Cancel Booking?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel ${booking['id']} for ${booking['venue']}?\n\nA full refund will be initiated to your original payment method within 2-4 hours.',
          style: const TextStyle(fontSize: 13, color: AppTheme.slateBlue, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('KEEP BOOKING', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.slateBlue)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _upcomingBookings.removeWhere((b) => b['id'] == booking['id']);
                booking['status'] = 'CANCELLED';
                booking['badgeVariant'] = HexgenBadgeVariant.gold;
                _pastBookings.insert(0, booking);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking ${booking['id']} cancelled. Refund initiated.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.navyBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('YES, CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateBack() {
    if (widget.returnToDashboard || !Navigator.canPop(context)) {
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
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedTab == 0 ? _upcomingBookings : _pastBookings;

    return PopScope(
      canPop: !widget.returnToDashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CyberGlassBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                // ── Top Header Bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _navigateBack,
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
                      const SizedBox(width: 12),
                      const Text(
                        'MY ARENA BOOKINGS',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                          letterSpacing: 0.6,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.electricBlue),
                              )
                            : const Icon(Icons.refresh_rounded,
                                color: AppTheme.navyBlue, size: 20),
                        onPressed: _fetchLiveBookings,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD6E4F8)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F2B5C)
                                  .withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.confirmation_number_outlined,
                                size: 14, color: AppTheme.electricBlue),
                            const SizedBox(width: 4),
                            Text(
                              '${_upcomingBookings.length} Active',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.navyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Real-Time Session Reminder Banner ───────────────────────────
                if (_upcomingBookings.isNotEmpty)
                  _buildUpcomingReminderCard(_upcomingBookings.first),

          // ── Tab Toggle ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navyBlue.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      index: 0,
                      label: 'UPCOMING (${_upcomingBookings.length})',
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      index: 1,
                      label: 'PAST & CANCELLED (${_pastBookings.length})',
                      icon: Icons.history_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bookings List ─────────────────────────────────────────────────
          Expanded(
            child: currentList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final item = currentList[index];
                      return _buildBookingCard(item);
                    },
                  ),
          ),
        ],
      ),
    ),
  ),
),
);
}

  Widget _buildUpcomingReminderCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0038B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0057FF).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFF00E676),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'NEXT SESSION REMINDER',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E676),
                        letterSpacing: 0.6,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Lane 1 • Gate B',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${booking['venue']} • ${booking['time']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Radar & 60FPS AI cameras auto-armed on check-in',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryCtaGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.electricBlue.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : AppTheme.slateBlue,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppTheme.slateBlue,
                letterSpacing: 0.3,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> item) {
    final bool isUpcoming = _selectedTab == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: HexgenCard(
        hasGlow: isUpcoming,
        hasTopAccent: isUpcoming,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.iceBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.sports_cricket_rounded,
                        size: 16,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['id'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppTheme.slateBlue,
                        letterSpacing: 0.8,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                HexgenBadge(
                  label: item['status'] as String,
                  variant: item['badgeVariant'] as HexgenBadgeVariant,
                  fontSize: 9,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 2: Venue Name & Lane
            Text(
              item['venue'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.electricBlue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${item['lane']} • ${item['location']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.slateBlue,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 3: Date & Time Highlight Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.iceBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 15, color: AppTheme.navyBlue),
                  const SizedBox(width: 8),
                  Text(
                    '${item['date']}  |  ${item['time']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Row 4: Telemetry & Machine Config Tag
            Row(
              children: [
                const Icon(Icons.tune_rounded, size: 13, color: AppTheme.slateBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Config: ${item['bowlerConfig']}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slateBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.cardBorderColor),
            const SizedBox(height: 12),

            // Row 5: Price & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL PAID',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.slateBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      item['price'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                  ],
                ),
                if (isUpcoming) ...[
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => _confirmCancelBooking(context, item),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        icon: Icon(
                          item['configured'] == true ? Icons.check_circle_rounded : Icons.tune_rounded,
                          size: 13,
                        ),
                        label: Text(
                          item['configured'] == true ? 'PROGRAMMED' : 'PROGRAM SESSION',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SessionConfigScreen(),
                            ),
                          );
                          if (result == true || result != null) {
                            setState(() {
                              item['configured'] = true;
                              item['bowlerConfig'] = 'Configured • AI Armed';
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: item['configured'] == true ? const Color(0xFF10B981) : AppTheme.electricBlue,
                          side: BorderSide(
                            color: item['configured'] == true ? const Color(0xFF6EE7B7) : AppTheme.electricBlue,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                      const SizedBox(width: 6),
                      HexgenButton(
                        text: 'PASS',
                        icon: Icons.qr_code_rounded,
                        isFullWidth: false,
                        height: 36,
                        borderRadius: 12,
                        fontSize: 10.5,
                        onPressed: () => _showQrPassModal(context, item),
                      ),
                    ],
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text(
                      'BOOK AGAIN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VenueDetailsScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.electricBlue,
                      side: const BorderSide(color: AppTheme.lightBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isUpcoming = _selectedTab == 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cardBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navyBlue.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isUpcoming ? Icons.calendar_month_outlined : Icons.history_toggle_off_rounded,
                size: 48,
                color: AppTheme.electricBlue,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isUpcoming ? 'No Active Arena Bookings' : 'No Past Booking Records',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isUpcoming
                  ? 'Reserve a court, select your machine bowling telemetry, and step up to the crease!'
                  : 'Your completed arena match sessions and receipts will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.slateBlue,
                height: 1.4,
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 20),
              HexgenButton(
                text: 'BOOK AN ARENA NOW',
                icon: Icons.sports_cricket_rounded,
                isFullWidth: false,
                height: 44,
                borderRadius: 16,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VenueDetailsScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── QR Ticket Pass Modal BottomSheet ──────────────────────────────────────────
class _QrPassBottomSheet extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _QrPassBottomSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag pill
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.cardBorderColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARENA ACCESS PASS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    'Scan at turnstile barrier for lane entry',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.slateBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ticket Container with Cutout Notches
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.iceBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.lightBlue),
            ),
            child: Column(
              children: [
                // Venue + Pass ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking['venue'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                    ),
                    Text(
                      booking['id'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${booking['lane']} • ${booking['entryGate']}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.slateBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.lightBlue),
                const SizedBox(height: 14),

                // Simulated Barcode / QR Visual Representation
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorderColor),
                  ),
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(200, 70),
                        painter: _BarcodePainter(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '* ${booking['id']} *',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          letterSpacing: 3,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Schedule and Coach summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SLOT TIME',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.slateBlue),
                        ),
                        Text(
                          booking['time'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.navyBlue),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'COACH / MENTOR',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.slateBlue),
                        ),
                        Text(
                          booking['coach'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.navyBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          HexgenButton(
            text: 'DOWNLOAD PASS / SHARE',
            icon: Icons.ios_share_rounded,
            height: 48,
            borderRadius: 16,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pass saved to device and ready for Apple/Google Wallet!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.navyBlue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Custom Barcode Graphic Painter ───────────────────────────────────────────
class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.navyBlue
      ..style = PaintingStyle.fill;

    // Deterministic pattern of lines of varying widths
    final List<double> widths = [
      3, 1, 4, 2, 1, 3, 2, 4, 1, 2, 3, 1, 4, 2, 1, 3, 1, 2, 4, 3, 1, 2, 4, 1, 3, 2, 1, 4, 2, 3
    ];
    final List<double> spaces = [
      2, 3, 1, 2, 4, 2, 1, 3, 2, 1, 2, 3, 1, 2, 4, 2, 3, 1, 2, 1, 3, 2, 1, 4, 2, 1, 3, 2, 1, 2
    ];

    double currentX = 10;
    for (int i = 0; i < widths.length && currentX < size.width - 10; i++) {
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
