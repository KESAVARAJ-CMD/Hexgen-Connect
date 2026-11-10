import 'package:flutter/material.dart';
import '../core/network/api_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'calendar_screen.dart';
import 'session_config_screen.dart';

class CheckSlotsScreen extends StatefulWidget {
  final String venueId;
  const CheckSlotsScreen({super.key, this.venueId = 'v1'});

  @override
  State<CheckSlotsScreen> createState() => _CheckSlotsScreenState();
}

class _CheckSlotsScreenState extends State<CheckSlotsScreen> {
  // Selected time slots (Morning 9:00 and 11:00 selected by default as in screenshot)
  final Set<String> _selectedSlots = {'Morning-9:00', 'Morning-11:00'};

  // Booked slots list from Live API
  Set<String> _bookedSlots = {
    'Morning-6:00',
    'Morning-8:00',
    'Afternoon-12:00',
    'Afternoon-5:00',
    'Evening-7:00',
    'Evening-10:00',
  };

  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveSlots();
  }

  Future<void> _fetchLiveSlots() async {
    setState(() => _isLoadingSlots = true);
    final res = await ApiService().getVenueSlots(widget.venueId, date: 'today');
    if (mounted && res['success'] == true && res['slots'] != null) {
      final slotsData = res['slots'];
      final newBooked = <String>{};

      for (final period in ['morning', 'afternoon', 'evening']) {
        final periodList = slotsData[period] as List<dynamic>?;
        if (periodList != null) {
          final prefix = period[0].toUpperCase() + period.substring(1);
          for (final item in periodList) {
            if (item['status'] == 'booked' || item['isAvailable'] == false) {
              newBooked.add('$prefix-${item['time']}');
            }
          }
        }
      }

      setState(() {
        _bookedSlots = newBooked;
        _isLoadingSlots = false;
      });
    } else {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  void _toggleSlot(String slotKey) {
    if (_bookedSlots.contains(slotKey)) return; // Booked slot cannot be selected
    setState(() {
      if (_selectedSlots.contains(slotKey)) {
        _selectedSlots.remove(slotKey);
      } else {
        _selectedSlots.add(slotKey);
      }
    });
  }

  void _onBookSlots() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SessionConfigScreen(),
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
              // ── Top Header Bar (Hexgen Logo Left Aligned) ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppTheme.navyBlue,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildHexgenLogo(),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppTheme.navyBlue,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ──────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Date Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.navyBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Note: ',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.electricBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Booked',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Date Range Card ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE0EEFF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '05 Sep 2025  -  06 Sep 2025',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Text(
                                      'Friday',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.slateBlue,
                                      ),
                                    ),
                                    SizedBox(width: 38),
                                    Text(
                                      'Saturday',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.slateBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CalendarScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0EEFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppTheme.electricBlue,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Select Time White Card Container ──────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFE0EEFF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withAlpha(12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Select Time',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                if (_isLoadingSlots)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricBlue),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: _fetchLiveSlots,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.refresh_rounded, size: 14, color: AppTheme.electricBlue),
                                        SizedBox(width: 4),
                                        Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.electricBlue,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 1. Morning Section
                            _buildTimePeriodSection(
                              periodTitle: 'Morning (6:00AM - 12:00PM)',
                              timeSlots: [
                                '6:00',
                                '7:00',
                                '8:00',
                                '9:00',
                                '10:00',
                                '11:00',
                              ],
                              periodPrefix: 'Morning',
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(color: Color(0xFFF1F5F9), height: 1),
                            ),

                            // 2. Afternoon Section
                            _buildTimePeriodSection(
                              periodTitle: 'Afternoon (12:00PM - 6:00PM)',
                              timeSlots: [
                                '12:00',
                                '1:00',
                                '2:00',
                                '3:00',
                                '4:00',
                                '5:00',
                              ],
                              periodPrefix: 'Afternoon',
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(color: Color(0xFFF1F5F9), height: 1),
                            ),

                            // 3. Evening Section
                            _buildTimePeriodSection(
                              periodTitle: 'Evening (6:00PM - 12:00AM)',
                              timeSlots: [
                                '6:00',
                                '7:00',
                                '8:00',
                                '9:00',
                                '10:00',
                                '11:00',
                              ],
                              periodPrefix: 'Evening',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Bottom Book Your Slots Button ──────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _onBookSlots,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: AppTheme.primaryCtaGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.electricBlue.withAlpha(90),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Book your slots',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildTimePeriodSection({
    required String periodTitle,
    required List<String> timeSlots,
    required String periodPrefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          periodTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.navyBlue,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((time) {
            final slotKey = '$periodPrefix-$time';
            final isBooked = _bookedSlots.contains(slotKey);
            final isSelected = _selectedSlots.contains(slotKey);

            return GestureDetector(
              onTap: () => _toggleSlot(slotKey),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 68,
                height: 42,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                  color: isBooked
                      ? const Color(0xFFE2E8F0) // Disabled booked grey
                      : isSelected
                          ? null
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isBooked
                              ? Colors.transparent
                              : const Color(0xFFE2EEFF),
                          width: 1.2,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.electricBlue.withAlpha(70),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isBooked
                          ? const Color(0xFF94A3B8)
                          : isSelected
                              ? Colors.white
                              : AppTheme.navyBlue,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
