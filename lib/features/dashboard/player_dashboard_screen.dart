import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../widgets/session_setup_dialog.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import '../live_analysis_screen.dart';
import 'tabs/booking_tab.dart';
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
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _currentName = name;
        if (id != null && id.isNotEmpty) _currentId = id;
      });
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
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

  void _openCenterBallDialog() async {
    final result = await SessionSetupDialog.show(context);
    if (result != null && mounted) {
      final sessionCompleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => LiveAnalysisScreen(
            mode: AnalysisMode.biomechanics,
            sessionConfig: result,
            playerName: _currentName,
          ),
        ),
      );

      if (sessionCompleted == true && mounted) {
        _navigateToTab(1); // Jump to Sessions Tab to view telemetry!
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const BookingIntegrationTab(),
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
                child: pages[_currentIndex],
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
          const Text(
            'HEXGEN CONNECT',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppTheme.navyBlue,
              letterSpacing: 0.8,
              fontFamily: 'Roboto',
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Live Calibration & Launch',
            icon: const Icon(Icons.bolt_rounded, color: AppTheme.electricBlue),
            onPressed: _openCenterBallDialog,
          ),
          IconButton(
            tooltip: 'Athlete Dossier',
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.electricBlue,
              child: Text(
                _currentName.isNotEmpty
                    ? _currentName[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            onPressed: () {
              _refreshProfile();
              _navigateToTab(3);
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, color: AppTheme.navyBlue),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()),
              );
              _refreshProfile();
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
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C3E78).withValues(alpha: 0.08),
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
                    label: 'Booking',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                  ),
                  _buildNavItem(
                    index: 1,
                    label: 'Sessions',
                    icon: Icons.play_arrow_outlined,
                    activeIcon: Icons.play_arrow_rounded,
                  ),
                  _buildNavItem(
                    index: 2,
                    label: 'Connect',
                    icon: Icons.groups_outlined,
                    activeIcon: Icons.groups_rounded,
                  ),
                  _buildNavItem(
                    index: 3,
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
