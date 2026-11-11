import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../core/widgets/hexgen_badge.dart';
import '../core/widgets/hexgen_button.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../widgets/share_bottom_sheet.dart';
import 'home_dashboard_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'advanced_settings_screen.dart';
import '../features/onboarding/role_selection_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  final bool showBottomNavBar;

  const AccountSettingsScreen({super.key, this.showBottomNavBar = false});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String _playerName = 'Kesava';
  String _playerId = 'HX-9821';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('player_name');
    final id = prefs.getString('player_id');
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _playerName = name;
        if (id != null && id.isNotEmpty) _playerId = id;
      });
    }
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(name: _playerName, id: _playerId),
      ),
    );
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        child: Stack(
          children: [
            // ── Background Ambient Curves ────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 180,
              child: CustomPaint(
                painter: _AmbientWavesPainter(),
              ),
            ),

            SafeArea(
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
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AppTheme.navyBlue,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        _buildHexgenLogo(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => ShareBottomSheet.show(context),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.ios_share_rounded,
                                color: AppTheme.navyBlue,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable Body ──────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          // ── User Header Profile Info ─────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryCtaGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.electricBlue.withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _playerName.isNotEmpty ? _playerName[0].toUpperCase() : 'A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _playerName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  GestureDetector(
                                    onTap: _openProfile,
                                    child: Row(
                                      children: const [
                                        Text(
                                          'View your profile',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.electricBlue,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: AppTheme.electricBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ── Menu List Items in White Card ────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.cardBorderColor,
                                width: 1.2,
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
                                _buildSettingItem(
                                  icon: Icons.calendar_today_outlined,
                                  iconBgColor: const Color(0xFFF3E8FF),
                                  iconColor: const Color(0xFF9333EA),
                                  title: 'My Bookings',
                                  subtitle: 'View Transactions & Receipts',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const MyBookingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.groups_outlined,
                                  iconBgColor: const Color(0xFFFCE7F3),
                                  iconColor: const Color(0xFFDB2777),
                                  title: 'Teams',
                                  subtitle: 'View & Manage Players',
                                  onTap: () => _openTeamsSheet(context),
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.mail_outline_rounded,
                                  iconBgColor: const Color(0xFFE0E7FF),
                                  iconColor: const Color(0xFF4F46E5),
                                  title: 'Payment',
                                  subtitle: 'Manage rewards , HexGen credits, etc',
                                  onTap: () => _openPaymentSheet(context),
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.favorite_border_rounded,
                                  iconBgColor: const Color(0xFFEFF6FF),
                                  iconColor: AppTheme.electricBlue,
                                  title: 'Offers',
                                  subtitle: 'Avail your offers',
                                  onTap: () => _openOffersSheet(context),
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.card_giftcard_rounded,
                                  iconBgColor: const Color(0xFFFDF4FF),
                                  iconColor: const Color(0xFFA855F7),
                                  title: 'Invite & Earn',
                                  subtitle: 'Earn 50 points by inviting your friends',
                                  onTap: () => ShareBottomSheet.show(context),
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.tune_rounded,
                                  iconBgColor: const Color(0xFFDCFCE7),
                                  iconColor: const Color(0xFF16A34A),
                                  title: 'Advanced Settings',
                                  subtitle: 'Ball speed, pitch surface & game mode',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const AdvancedSettingsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.lock_outline_rounded,
                                  iconBgColor: const Color(0xFFF3E8FF),
                                  iconColor: const Color(0xFF7E22CE),
                                  title: 'Preference and Privacy',
                                  subtitle: 'Sports, Locations, Notifications, etc',
                                  onTap: () => _openPreferencesSheet(context),
                                ),
                                _buildDivider(),
                                _buildSettingItem(
                                  icon: Icons.help_outline_rounded,
                                  iconBgColor: const Color(0xFFFDF2F8),
                                  iconColor: const Color(0xFFE11D48),
                                  title: 'Help & Support',
                                  subtitle: 'Contact our center for any queries',
                                  onTap: () => _openHelpSupportSheet(context),
                                ),
                                _buildDivider(),
                                _buildLogoutItem(context),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavBar
          ? AnimatedBottomNavBar(
              currentIndex: 3,
              style: AnimatedNavBarStyle.fluidPill,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
                    (route) => false,
                  );
                } else if (index == 1) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                  );
                } else if (index == 2) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                  );
                }
              },
              items: const [
                AnimatedNavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                AnimatedNavBarItem(
                  icon: Icons.play_circle_outline_rounded,
                  activeIcon: Icons.play_circle_fill_rounded,
                  label: 'Watch',
                ),
                AnimatedNavBarItem(
                  icon: Icons.handshake_outlined,
                  activeIcon: Icons.handshake_rounded,
                  label: 'Connect',
                ),
                AnimatedNavBarItem(
                  icon: Icons.sports_cricket_outlined,
                  activeIcon: Icons.sports_cricket_rounded,
                  label: 'Session',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 64,
      endIndent: 16,
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slateBlue,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.navyBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return InkWell(
      onTap: () => _confirmLogout(context),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 10),
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.navyBlue,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of Hexgen Connect? You will return to the role selection screen.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppTheme.slateBlue,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.slateBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await prefs.remove('user_role');
              await prefs.remove('player_name');
              await prefs.remove('player_id');
              await prefs.remove('coach_name');
              await prefs.remove('coach_id');
              await ApiService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w700),
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

  void _openTeamsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const _TeamsBottomSheet(),
      ),
    );
  }

  void _openPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const _PaymentWalletBottomSheet(),
      ),
    );
  }

  void _openOffersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const _OffersBottomSheet(),
      ),
    );
  }

  void _openPreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const _PreferencesBottomSheet(),
      ),
    );
  }

  void _openHelpSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const _HelpSupportBottomSheet(),
      ),
    );
  }
}

// ── 1. Teams & Squad BottomSheet ─────────────────────────────────────────────
class _TeamsBottomSheet extends StatelessWidget {
  const _TeamsBottomSheet();

  @override
  Widget build(BuildContext context) {
    final members = [
      {'name': 'Rahul Kumar', 'role': 'Captain • Top Order Batsman', 'badge': 'YOU', 'xp': '1,420 XP'},
      {'name': 'Karthik Raja', 'role': 'Vice-Captain • All-Rounder', 'badge': 'PRO', 'xp': '1,890 XP'},
      {'name': 'Arjun Mehta', 'role': 'Pace Bowler • Fast Seam', 'badge': 'EXPERT', 'xp': '2,450 XP'},
      {'name': 'Dev Patel', 'role': 'Wicket-Keeper & Finisher', 'badge': 'PRO', 'xp': '1,680 XP'},
      {'name': 'Coach Madhu', 'role': 'Assigned Biomechanics Mentor', 'badge': 'MENTOR', 'xp': 'MASTER'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HEXGEN SQUAD & PLAYERS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    'Team: Hexgen Titans XI (Division 1)',
                    style: TextStyle(
                      fontSize: 11.5,
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
          ...members.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.lightBlue),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.electricBlue,
                      child: Text(
                        m['name']![0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                m['name']!,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.navyBlue),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  m['badge']!,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.electricBlue),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            m['role']!,
                            style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      m['xp']!,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.navyBlue),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),
          HexgenButton(
            text: 'INVITE ATHLETE TO SQUAD',
            icon: Icons.person_add_alt_1_rounded,
            height: 48,
            borderRadius: 16,
            onPressed: () {
              Navigator.pop(context);
              ShareBottomSheet.show(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── 2. Payment & Hexgen Wallet BottomSheet ───────────────────────────────────
class _PaymentWalletBottomSheet extends StatelessWidget {
  const _PaymentWalletBottomSheet();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HEXGEN ARENA WALLET',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gradient Wallet Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryCtaGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE CREDITS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8),
                    ),
                    HexgenBadge(
                      label: 'ACTIVE ATHLETE',
                      variant: HexgenBadgeVariant.sky,
                      fontSize: 8.5,
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '₹ 1,250.00',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '480 Hexgen Rewards XP • Auto-applied at checkout',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'RECENT TRANSACTIONS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.slateBlue, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          _buildTxn('Lane Booking • Hexgen Arena', '- ₹ 1,830', 'Yesterday • UPI', const Color(0xFFEF4444)),
          _buildTxn('Pro Athlete Pass Reward Cashback', '+ ₹ 200', '15 Sep • Reward', const Color(0xFF10B981)),
          _buildTxn('Wallet Top-up via GPay', '+ ₹ 1,000', '10 Sep • Added', const Color(0xFF10B981)),
          const SizedBox(height: 16),
          HexgenButton(
            text: 'ADD WALLET CREDITS (+ ₹500)',
            icon: Icons.add_card_rounded,
            height: 48,
            borderRadius: 16,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('₹500 added to Hexgen Wallet successfully!'),
                  backgroundColor: AppTheme.navyBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTxn(String title, String amount, String date, Color amountColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.iceBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppTheme.navyBlue)),
              Text(date, style: const TextStyle(fontSize: 10.5, color: AppTheme.slateBlue)),
            ],
          ),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: amountColor)),
        ],
      ),
    );
  }
}

// ── 3. Offers & Promos BottomSheet ───────────────────────────────────────────
class _OffersBottomSheet extends StatelessWidget {
  const _OffersBottomSheet();

  @override
  Widget build(BuildContext context) {
    final offers = [
      {
        'code': 'HEXGEN50',
        'title': '50% OFF FIRST MACHINE SESSION',
        'desc': 'Get 50% discount on autonomous machine bowling telemetry lanes.',
        'expiry': 'Valid till 30 Sep 2025',
      },
      {
        'code': 'ARENAPOWER',
        'title': '₹ 300 FLAT TURF CASHBACK',
        'desc': 'Book 2+ hours on any hybrid synthetic cricket turf and save ₹300.',
        'expiry': 'Valid on Weekend bookings',
      },
      {
        'code': 'PROPASS100',
        'title': '₹ 100 OFF PRO ATHLETE PASS',
        'desc': 'Unlock 4K multi-angle video replays and direct mentor reviews.',
        'expiry': 'Valid for Season 2025',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AVAILABLE OFFERS & PROMOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...offers.map((o) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.lightBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o['title']!,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon code ${o['code']} copied to clipboard!'),
                                backgroundColor: AppTheme.navyBlue,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.pureWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.electricBlue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  o['code']!,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppTheme.electricBlue),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded, size: 12, color: AppTheme.electricBlue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(o['desc']!, style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, height: 1.3)),
                    const SizedBox(height: 6),
                    Text(o['expiry']!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── 4. Preferences & Privacy BottomSheet ─────────────────────────────────────
class _PreferencesBottomSheet extends StatefulWidget {
  const _PreferencesBottomSheet();

  @override
  State<_PreferencesBottomSheet> createState() => _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState extends State<_PreferencesBottomSheet> {
  bool _reminders = true;
  bool _autoTelemetry = true;
  bool _coachAlerts = true;
  bool _publicDossier = true;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PREFERENCES & PRIVACY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  letterSpacing: 0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSwitch('Booking Reminders & Match Slots', 'Get alerts 1 hr before your reserved lane session', _reminders, (v) => setState(() => _reminders = v)),
          _buildSwitch('Auto-Save 60fps Telemetry Video', 'Save high speed HD pose clips directly to Session Log', _autoTelemetry, (v) => setState(() => _autoTelemetry = v)),
          _buildSwitch('Coach Review & Drill Alerts', 'Notify when Coach Madhu publishes biomechanical notes', _coachAlerts, (v) => setState(() => _coachAlerts = v)),
          _buildSwitch('Public Athlete Dossier Visibility', 'Allow other arena athletes to view your leaderboard rank', _publicDossier, (v) => setState(() => _publicDossier = v)),
          const SizedBox(height: 16),
          HexgenButton(
            text: 'SAVE PREFERENCES',
            height: 48,
            borderRadius: 16,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preferences saved successfully!'),
                  backgroundColor: AppTheme.navyBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.slateBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CyberGradientSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── 5. Help & Support BottomSheet ────────────────────────────────────────────
class _HelpSupportBottomSheet extends StatelessWidget {
  const _HelpSupportBottomSheet();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HELP & ARENA SUPPORT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.5,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    '24/7 Arena Concierge & Machine Support',
                    style: TextStyle(fontSize: 11, color: AppTheme.slateBlue),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSupportTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chat on WhatsApp',
            subtitle: '+91 98765 43210 • Quick response in 5 mins',
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening WhatsApp Support (+91 98765 43210)...'),
                  backgroundColor: AppTheme.navyBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildSupportTile(
            icon: Icons.call_outlined,
            title: 'Call Arena Front Desk',
            subtitle: 'Hexgen Sports Arena, Shanthinagar Desk',
            color: AppTheme.electricBlue,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling Arena Reception (080-4921-8800)...'),
                  backgroundColor: AppTheme.navyBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildSupportTile(
            icon: Icons.report_problem_outlined,
            title: 'Report Lane / Machine Sensor Issue',
            subtitle: 'Lane net calibration or ball feeder jam',
            color: const Color(0xFFEF4444),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket created! Arena technicians alerted for Lane 1.'),
                  backgroundColor: AppTheme.navyBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.iceBlue,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightBlue),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.navyBlue)),
                    const SizedBox(height: 1),
                    Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppTheme.slateBlue)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.navyBlue, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final p1 = Paint()
      ..color = const Color(0xFFD9EDFF).withAlpha(150)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, h * 0.45)
      ..cubicTo(w * 0.3, h * 0.35, w * 0.45, h * 0.8, 0, h)
      ..close();
    canvas.drawPath(path1, p1);

    final p2 = Paint()
      ..color = const Color(0xFFB9DEFF).withAlpha(120)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(w, h * 0.25)
      ..cubicTo(w * 0.65, h * 0.4, w * 0.6, h * 0.9, w, h)
      ..close();
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
