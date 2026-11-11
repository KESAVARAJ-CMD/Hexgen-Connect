import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../widgets/share_bottom_sheet.dart';
import 'booking_stages_screen.dart';

class VenueDetailsScreen extends StatefulWidget {
  const VenueDetailsScreen({super.key});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  String _selectedSport = 'Cricket';

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
                  // ── Top Bar with Centered One6 Logo ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => ShareBottomSheet.show(context),
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
                                    Icons.ios_share_rounded,
                                    color: AppTheme.navyBlue,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable Body ──────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Hero Stadium Image ───────────────────────────────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.cardBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&auto=format&fit=crop&q=80',
                                width: double.infinity,
                                height: 210,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 210,
                                  color: AppTheme.lightBlue,
                                  child: const Center(
                                    child: Icon(
                                      Icons.sports_cricket,
                                      size: 50,
                                      color: AppTheme.electricBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Venue Header Info ────────────────────────────────
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.badgePurpleBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.electricBlue.withAlpha(60),
                                  ),
                                ),
                                child: const Text(
                                  'New Venue!!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.electricBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          const Text(
                            'Hexgen sports arena',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Open Timing
                          Row(
                            children: const [
                              Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: AppTheme.electricBlue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Open · 9 AM – 12 AM',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Address
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppTheme.electricBlue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '123 Elm Street, Anytown',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.slateBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Show in Map Button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.cardBorderColor,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.electricBlue.withAlpha(12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.map_rounded,
                                    color: AppTheme.electricBlue,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Show in Map',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.navyBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: AppTheme.cardBorderColor, height: 1),
                          const SizedBox(height: 16),

                          // ── Offers Section ───────────────────────────────────
                          const Text(
                            'Offers',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: AppTheme.gradientBox(radius: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_offer_rounded,
                                    color: AppTheme.electricBlue,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Get 20% off upto 2400rs on all sports on min 2 hours slots',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: AppTheme.cardBorderColor, height: 1),
                          const SizedBox(height: 16),

                          // ── Available Sports Section ─────────────────────────
                          const Text(
                            'Available Sports',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              _buildSportCard(
                                icon: Icons.sports_cricket,
                                label: 'Cricket',
                              ),
                              const SizedBox(width: 12),
                              _buildSportCard(
                                icon: Icons.sports_baseball_rounded,
                                label: 'Pickleball',
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: AppTheme.cardBorderColor, height: 1),
                          const SizedBox(height: 16),

                          // ── Amenities Section ────────────────────────────────
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _AmenityPill(label: 'Washroom'),
                              _AmenityPill(label: 'Parking'),
                              _AmenityPill(label: 'CCTV'),
                              _AmenityPill(label: 'Changing room'),
                              _AmenityPill(label: 'Flood Lights'),
                              _AmenityPill(label: 'Drinking Water'),
                              _AmenityPill(label: 'First aid kit'),
                            ],
                          ),

                          const SizedBox(height: 18),
                          const Divider(color: AppTheme.cardBorderColor, height: 1),
                          const SizedBox(height: 16),

                          // ── About Venue Section ──────────────────────────────
                          const Text(
                            'About Venue',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _buildAboutCard(
                            title: 'Box Cricket',
                            points: [
                              'Appropriate sports shoes are recommended for Box Cricket to ensure safety and grip.',
                              'Sports equipment availability: Bat, Ball, Wickets.',
                              'Barefoot play is strictly prohibited.',
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildAboutCard(
                            title: 'Pickleball Courts',
                            points: [
                              'Non-marking indoor court shoes are mandatory to protect the cushion turf.',
                              'Paddles and USAPA approved balls available at the front desk.',
                              'A maximum of 4 players per court allowed for doubles play.',
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildAboutCard(
                            title: 'Cricket Nets',
                            points: [
                              'Sports attire is recommended.',
                              'Outside balls are allowed.',
                              'A maximum of 6 members per booking per cricket net are allowed.',
                              'Please be cautious of other players in the nets.',
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildAboutCard(
                            title: 'Bowling Machine',
                            points: [
                              'Helmets are compulsory for batting.',
                              'A maximum of 2 members per booking per bowling machine are allowed.',
                              'Please follow the instructions provided by the facility staff.',
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ── Fixed Bottom Book Now Button ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingStagesScreen(
                              selectedSport: _selectedSport,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          gradient: AppTheme.primaryCtaGradient,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0057FF).withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(0xFF0F2B5C).withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'BOOK NOW!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
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

  Widget _buildSportCard({
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedSport == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSport = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryCtaGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: AppTheme.cardBorderColor,
                  width: 1.2,
                ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF0057FF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.electricBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.navyBlue,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildAboutCard({
    required String title,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.cardBorderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.navyBlue,
            ),
          ),
          const SizedBox(height: 6),
          ...points.map(
            (pt) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppTheme.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      pt,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.slateBlue,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
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

class _AmenityPill extends StatelessWidget {
  final String label;

  const _AmenityPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.cardBorderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.navyBlue,
        ),
      ),
    );
  }
}
