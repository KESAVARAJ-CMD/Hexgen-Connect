import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/profile_image_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../profile/profile_screen.dart';
import '../../screens/notifications_screen.dart';
import 'tabs/coaches_tab.dart';
import 'tabs/sessions_tab.dart';

class PlayerDashboardScreen extends StatefulWidget {
  final String playerName;
  final String playerId;
  final int initialIndex;

  const PlayerDashboardScreen({
    super.key,
    required this.playerName,
    required this.playerId,
    this.initialIndex = 0,
  });

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  late int _currentIndex;
  bool _isSubscribed = false;
  late String _currentName;
  late String _currentId;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentName = widget.playerName;
    _currentId = widget.playerId;
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('player_name');
    final id = prefs.getString('player_id');
    final avatar = prefs.getString(ProfileImageService.avatarPrefKey);
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _currentName = name;
        if (id != null && id.isNotEmpty) _currentId = id;
        _avatarPath = avatar;
      });
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _refreshProfile();
  }

  void _onSubscribeSuccess() {
    setState(() {
      _isSubscribed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ PRO ATHLETE PASS ACTIVATED! Full Telemetry Unlocked.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.navyBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      SessionsTab(
          isSubscribed: _isSubscribed,
          onUnlockSubscription: _onSubscribeSuccess),
      const CoachesTab(),
      ProfileScreen(
        name: _currentName,
        id: _currentId,
        showTopBar: false,
        showBottomNavBar: false,
        isSubscribed: _isSubscribed,
        onProfileUpdated: _refreshProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: pages[_currentIndex < pages.length ? _currentIndex : 0],
              ),
              _buildNormalBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 4),
      child: Row(
        children: [
          // Athlete Avatar with tap to Profile
          GestureDetector(
            onTap: () => _navigateToTab(2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileImageService.buildAvatar(
                  avatarPath: _avatarPath,
                  displayName: _currentName,
                  size: 38,
                  borderWidth: 2,
                ),
                // Green active dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Dynamic Greeting / Title based on Tab
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentIndex == 0) ...[
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Hi, $_currentName 🏏',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppTheme.navyBlue,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF0052FF),
                        size: 15,
                      ),
                    ],
                  ),
                  const Text(
                    'Sessions & Net Practice',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (_currentIndex == 1) ...[
                  const Text(
                    'Coach Hub 🌐',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppTheme.navyBlue,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Text(
                    'Connect with Certified Mentors',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  const Row(
                    children: [
                      Text(
                        'Athlete Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: AppTheme.navyBlue,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF0052FF),
                        size: 16,
                      ),
                    ],
                  ),
                  Text(
                    '$_currentId • Pro Telemetry',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.navyBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNormalBottomNavBar() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFD6E4F8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    label: 'Sessions',
                    icon: Icons.play_arrow_outlined,
                    activeIcon: Icons.play_arrow_rounded,
                  ),
                  _buildNavItem(
                    index: 1,
                    label: 'Connect',
                    icon: Icons.groups_outlined,
                    activeIcon: Icons.groups_rounded,
                  ),
                  _buildNavItem(
                    index: 2,
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateToTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? AppTheme.electricBlue : AppTheme.slateBlue,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.electricBlue : AppTheme.slateBlue,
                letterSpacing: 0.1,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
