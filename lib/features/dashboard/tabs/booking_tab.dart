import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../screens/venue_details_screen.dart';

class BookingIntegrationTab extends StatefulWidget {
  const BookingIntegrationTab({super.key});

  @override
  State<BookingIntegrationTab> createState() => _BookingIntegrationTabState();
}

class _BookingIntegrationTabState extends State<BookingIntegrationTab> {
  int _selectedTopTab = 0; // 0 = Venues, 1 = Tournaments, 2 = Deals
  String _selectedSport = 'All';
  String _selectedLocation = 'Shanthinagar, Bangalore';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingVenues = false;
  List<Map<String, dynamic>> _allVenues = [
    {
      'name': 'Hexgen Sports Arena',
      'sport': 'Cricket',
      'sportIcon': '🏏',
      'location': 'Shanthinagar, Bangalore',
      'distance': '1.2 km',
      'rating': '4.9',
      'reviews': '184',
      'price': '₹ 1,500 / hr',
      'image': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&auto=format&fit=crop&q=80',
      'amenities': ['Auto Machine', 'Floodlights', 'Speed Radar'],
      'isPopular': true,
    },
    {
      'name': 'Hexgen Turf Arena',
      'sport': 'Football',
      'sportIcon': '⚽',
      'location': 'Indiranagar, Bangalore',
      'distance': '3.4 km',
      'rating': '4.8',
      'reviews': '142',
      'price': '₹ 1,200 / hr',
      'image': 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=800&auto=format&fit=crop&q=80',
      'amenities': ['FIFA Turf', 'Locker Room', 'Dugouts'],
      'isPopular': false,
    },
    {
      'name': 'Royal Cricket Pavilion',
      'sport': 'Cricket',
      'sportIcon': '🏏',
      'location': 'Koramangala, Bangalore',
      'distance': '2.8 km',
      'rating': '4.9',
      'reviews': '210',
      'price': '₹ 1,800 / hr',
      'image': 'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=800&auto=format&fit=crop&q=80',
      'amenities': ['Pro Turf Lane', 'Live Video Replay', 'Coach Sync'],
      'isPopular': true,
    },
    {
      'name': 'Smash Point Badminton & Pickleball',
      'sport': 'Badminton',
      'sportIcon': '🏸',
      'location': 'HSR Layout, Bangalore',
      'distance': '4.1 km',
      'rating': '4.7',
      'reviews': '96',
      'price': '₹ 600 / hr',
      'image': 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&auto=format&fit=crop&q=80',
      'amenities': ['BWF Synthetic', 'Air Conditioned', 'Pro Shop'],
      'isPopular': false,
    },
    {
      'name': 'KickOff Premier 7v7 Arena',
      'sport': 'Football',
      'sportIcon': '⚽',
      'location': 'Whitefield, Bangalore',
      'distance': '6.2 km',
      'rating': '4.8',
      'reviews': '118',
      'price': '₹ 1,400 / hr',
      'image': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800&auto=format&fit=crop&q=80',
      'amenities': ['7v7 Pitch', 'Night Stadium Lights', 'Parking'],
      'isPopular': false,
    },
  ];

  static const List<Map<String, String>> _sportsFilterList = [
    {'label': 'All', 'icon': '🏆'},
    {'label': 'Cricket', 'icon': '🏏'},
    {'label': 'Football', 'icon': '⚽'},
    {'label': 'Badminton', 'icon': '🏸'},
  ];

  static const List<Map<String, dynamic>> _tournamentsList = [
    {
      'title': 'Hexgen Super 8 Cricket Championship',
      'category': 'Open Age • T10 Format',
      'date': 'This Saturday, 08:30 AM',
      'venue': 'Hexgen Sports Arena • Main Turf',
      'prize': '₹ 50,000 Cash Pool',
      'slotsLeft': '2 Slots Left',
      'entryFee': '₹ 2,499 / Team',
      'tag': 'FAST FILLING 🔥',
    },
    {
      'title': 'Midnight 5v5 Football Blitz',
      'category': 'Knockout Cup • Floodlit Arena',
      'date': 'Next Friday, 10:00 PM',
      'venue': 'Hexgen Turf Arena • Lane A & B',
      'prize': '₹ 30,000 Cash Pool',
      'slotsLeft': '4 Slots Left',
      'entryFee': '₹ 1,800 / Team',
      'tag': 'WEEKEND NIGHT ⚡',
    },
  ];

  static const List<Map<String, dynamic>> _dealsList = [
    {
      'code': 'HEXGEN100',
      'title': 'Flat ₹100 Off on First Lane Booking',
      'desc': 'Valid on Cricket batting lanes and football turfs across Bangalore.',
      'discount': '₹100 OFF',
      'validTill': 'Valid till 30 Nov 2026',
    },
    {
      'code': 'EARLYBIRD25',
      'title': '25% Off on Morning Slots (6 AM - 9 AM)',
      'desc': 'Book early morning slots and get flat 25% instant cashback to wallet.',
      'discount': '25% OFF',
      'validTill': 'Daily Morning Deal',
    },
    {
      'code': 'PROATHLETE',
      'title': 'Complimentary AI Video Telemetry Analysis',
      'desc': 'Free 60FPS pose & bat speed review when you book for 2+ hours.',
      'discount': 'FREE HUD',
      'validTill': 'Pro Pass Exclusive',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveVenues();
  }

  Future<void> _fetchLiveVenues() async {
    setState(() => _isLoadingVenues = true);
    final apiVenues = await ApiService().getVenues(sport: _selectedSport);
    if (!mounted) return;
    if (apiVenues.isNotEmpty) {
      setState(() {
        _allVenues = apiVenues;
        _isLoadingVenues = false;
      });
    } else {
      setState(() => _isLoadingVenues = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── 1. Location Bar & Quick Notification ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showLocationPicker(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppTheme.electricBlue, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            _selectedLocation,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.slateBlue, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: AppTheme.electricBlue),
                    SizedBox(width: 4),
                    Text(
                      'AI Ready Arenas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── 2. Search Field ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search arenas, sports, or locations...',
                    hintStyle: TextStyle(color: AppTheme.slateBlue, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppTheme.electricBlue,
                      size: 20,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── 3. Interactive Sports Filter Pills with Icons ────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _sportsFilterList.map((sport) {
                final isSelected = _selectedSport == sport['label'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSport = sport['label']!;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                      color: isSelected ? null : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.electricBlue.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(sport['icon']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          sport['label']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── 4. Top Segmented Content Tabs (Venues, Tournaments, Deals) ───────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                ),
                child: Row(
                  children: [
                    _buildTopTab('Arenas & Turfs', 0),
                    _buildTopTab('Tournaments 🏆', 1),
                    _buildTopTab('Deals & Passes', 2),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── 5. Main Content Area ─────────────────────────────────────────────
        Expanded(
          child: IndexedStack(
            index: _selectedTopTab,
            children: [
              _buildVenuesContent(),
              _buildTournamentsContent(),
              _buildDealsContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopTab(String title, int index) {
    final isSelected = index == _selectedTopTab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTopTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.iceBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: isSelected
                ? Border.all(color: AppTheme.electricBlue.withValues(alpha: 0.25), width: 1)
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.electricBlue : AppTheme.slateBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Venues Tab Content with Hero Banner & Modern Cards ──────────────────────
  Widget _buildVenuesContent() {
    final filteredVenues = _allVenues.where((v) {
      final name = v['name']!.toString().toLowerCase();
      final loc = v['location']!.toString().toLowerCase();
      final sport = v['sport']!.toString();

      final matchesQuery = name.contains(_searchQuery) || loc.contains(_searchQuery);
      final matchesSport = _selectedSport == 'All' || sport == _selectedSport;
      return matchesQuery && matchesSport;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        // ── Promotional Hero Banner ──────────────────────────────────────────
        _buildHeroPromoBanner(),
        const SizedBox(height: 14),

        // ── Section Title Row ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedSport == 'All'
                  ? 'All Recommended Arenas (${filteredVenues.length})'
                  : '$_selectedSport Arenas (${filteredVenues.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.navyBlue,
                fontFamily: 'Roboto',
              ),
            ),
            GestureDetector(
              onTap: _fetchLiveVenues,
              child: Row(
                children: [
                  if (_isLoadingVenues)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.electricBlue),
                    )
                  else
                    const Icon(Icons.refresh_rounded, size: 14, color: AppTheme.electricBlue),
                  const SizedBox(width: 4),
                  const Text(
                    'Real-Time Slots',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.electricBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (filteredVenues.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorderColor),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.slateBlue),
                const SizedBox(height: 10),
                const Text(
                  'No Arenas Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No venue matches "$_searchQuery" for $_selectedSport.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppTheme.slateBlue),
                ),
              ],
            ),
          )
        else
          ...filteredVenues.map((venue) => _buildModernVenueCard(venue)),
      ],
    );
  }

  Widget _buildHeroPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0038B8), Color(0xFF0057FF), Color(0xFF00D4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚡ AI SMART BOWLING ARENA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Book 60FPS AI Batting Lanes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Instant Pose Telemetry & Speed Radar included.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VenueDetailsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Book Smart Lane ⚡',
                      style: TextStyle(
                        color: AppTheme.electricBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🏏',
                style: TextStyle(fontSize: 42),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernVenueCard(Map<String, dynamic> venue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const VenueDetailsScreen(),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C3E78).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Image with Rating Tag
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          venue['image'] as String,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryCtaGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                venue['sportIcon'] as String,
                                style: const TextStyle(fontSize: 34),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
                              const SizedBox(width: 2),
                              Text(
                                venue['rating'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.iceBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${venue['sportIcon']} ${venue['sport']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.electricBlue,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              venue['distance'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.slateBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venue['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.slateBlue),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                venue['location'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.slateBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          venue['price'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Amenities Tags & Quick CTA Row
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: ((venue['amenities'] as List?)?.map((e) => e.toString()).toList() ?? <String>[]).take(2).map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            amenity,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const VenueDetailsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryCtaGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.electricBlue.withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Book Slot ⚡',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  // ── Tournaments Content ────────────────────────────────────────────────────
  Widget _buildTournamentsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tournamentsList.length,
      itemBuilder: (context, index) {
        final t = _tournamentsList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navyBlue.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t['tag'] as String,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                  Text(
                    t['slotsLeft'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t['title'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${t['category']} • ${t['date']}',
                style: const TextStyle(fontSize: 12, color: AppTheme.slateBlue),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.slateBlue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      t['venue'] as String,
                      style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIZE POOL',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.slateBlue),
                      ),
                      Text(
                        t['prize'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Registration for ${t['title']} opened!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.navyBlue,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.electricBlue,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Join • ${t['entryFee']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Deals Content ──────────────────────────────────────────────────────────
  Widget _buildDealsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dealsList.length,
      itemBuilder: (context, index) {
        final d = _dealsList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navyBlue.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.iceBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFB9DEFF)),
                    ),
                    child: Text(
                      d['code'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.electricBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    d['discount'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                d['title'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navyBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                d['desc'] as String,
                style: const TextStyle(fontSize: 12, color: AppTheme.slateBlue, height: 1.3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d['validTill'] as String,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBlue),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Promo Code ${d['code']} Applied!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.navyBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14, color: AppTheme.electricBlue),
                    label: const Text(
                      'Apply Code',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select City & Area',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.my_location_rounded, color: AppTheme.electricBlue),
              title: const Text('Shanthinagar, Bangalore'),
              subtitle: const Text('Current Location • Closest Arenas'),
              onTap: () {
                setState(() => _selectedLocation = 'Shanthinagar, Bangalore');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppTheme.slateBlue),
              title: const Text('Indiranagar, Bangalore'),
              onTap: () {
                setState(() => _selectedLocation = 'Indiranagar, Bangalore');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppTheme.slateBlue),
              title: const Text('Koramangala, Bangalore'),
              onTap: () {
                setState(() => _selectedLocation = 'Koramangala, Bangalore');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city_rounded, color: AppTheme.slateBlue),
              title: const Text('HSR Layout, Bangalore'),
              onTap: () {
                setState(() => _selectedLocation = 'HSR Layout, Bangalore');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
