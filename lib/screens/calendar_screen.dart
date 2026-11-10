import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'check_slots_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedStartDay = 5;
  int _selectedEndDay = 6;
  int _currentMonthIndex = 8; // September

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September 2025',
    'October 2025',
    'November 2025',
    'December 2025',
  ];

  final Set<int> _highlightedDays = {18, 23, 28}; // Light blue halo days

  void _onDateTap(int day) {
    setState(() {
      if (_selectedStartDay == day) return;
      if (day > _selectedStartDay) {
        _selectedEndDay = day;
      } else {
        _selectedStartDay = day;
        _selectedEndDay = day + 1;
      }
    });
  }

  void _onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckSlotsScreen(),
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
              // ── Top Bar: Back < | Hexgen Logo (Left Aligned) | Filter Funnel ─────────────────
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
                      // Check Slots Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Check Slots',
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

                      const SizedBox(height: 6),
                      const Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyBlue,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Calendar White Card ──────────────────────────────────
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
                          children: [
                            // Month Navigation Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _months[_currentMonthIndex],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.navyBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: AppTheme.navyBlue,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_left_rounded,
                                        color: AppTheme.navyBlue,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        if (_currentMonthIndex > 0) {
                                          setState(() => _currentMonthIndex--);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppTheme.navyBlue,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        if (_currentMonthIndex <
                                            _months.length - 1) {
                                          setState(() => _currentMonthIndex++);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Day Names Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                _CalendarDayName('SUN'),
                                _CalendarDayName('MON'),
                                _CalendarDayName('TUE'),
                                _CalendarDayName('WED'),
                                _CalendarDayName('THU'),
                                _CalendarDayName('FRI'),
                                _CalendarDayName('SAT'),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Calendar Grid (30 Days for Sept)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: 35, // 1 empty slot + 30 days
                              itemBuilder: (context, index) {
                                if (index < 1) {
                                  return const SizedBox(); // Sept 1 starts on Mon
                                }
                                final day = index;
                                if (day > 30) return const SizedBox();

                                final isSelected = day == _selectedStartDay ||
                                    day == _selectedEndDay;
                                final isHighlighted =
                                    _highlightedDays.contains(day);

                                return GestureDetector(
                                  onTap: () => _onDateTap(day),
                                  child: Center(
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isSelected
                                            ? AppTheme.primaryCtaGradient
                                            : null,
                                        color: isSelected
                                            ? null
                                            : isHighlighted
                                                ? const Color(0xFFE0EEFF)
                                                : Colors.transparent,
                                        border: isHighlighted
                                            ? Border.all(
                                                color: const Color(0xFF38BDF8),
                                                width: 1.5,
                                              )
                                            : null,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.electricBlue
                                                      .withAlpha(80),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected || isHighlighted
                                                ? FontWeight.w900
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme.navyBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Date Range Selected Cards Row ────────────────────────
                      Row(
                        children: [
                          // From Date
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F7FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.electricBlue,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'From date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.electricBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '0$_selectedStartDay Sep 2025',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.navyBlue,
                                        ),
                                      ),
                                      const Text(
                                        'Fri',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slateBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // To Date
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE0EEFF),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'To date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.electricBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '0$_selectedEndDay Sep 2025',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.navyBlue,
                                        ),
                                      ),
                                      const Text(
                                        'Sat',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slateBlue,
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

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Bottom Continue Button ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _onContinue,
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
                        'Continue',
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

class _CalendarDayName extends StatelessWidget {
  final String dayName;
  const _CalendarDayName(this.dayName);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Text(
        dayName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.slateBlue,
        ),
      ),
    );
  }
}
