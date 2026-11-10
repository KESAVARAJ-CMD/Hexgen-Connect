import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_constants.dart';
import '../core/network/api_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/onboarding/role_selection_screen.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  double _ballSpeed = 120.0;
  String _pitchType = 'Standard Turf';
  String _lightingLevel = 'High Floodlights';
  bool _videoRecording = true;
  bool _analyticsTracking = true;
  String _gameType = 'Match Practice';

  bool _isCheckingHealth = false;
  Map<String, dynamic>? _healthResult;

  @override
  void initState() {
    super.initState();
    _pingServer();
  }

  Future<void> _pingServer() async {
    setState(() => _isCheckingHealth = true);
    final res = await ApiService().checkHealth();
    if (mounted) {
      setState(() {
        _healthResult = res;
        _isCheckingHealth = false;
      });
    }
  }

  void _openHostConfigDialog() {
    final controller = TextEditingController(text: ApiConstants.customHost);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Configure Backend Host IP',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter local server host and port (e.g. 127.0.0.1:5000 or your Wi-Fi LAN IP):',
              style: TextStyle(fontSize: 12, color: AppTheme.slateBlue),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: '127.0.0.1:5000',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  ApiConstants.customHost = controller.text.trim();
                });
                Navigator.pop(context);
                _pingServer();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.electricBlue),
            child: const Text('Save & Ping ⚡', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
              // ── Top Cyber HUD Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.navyBlue.withAlpha(12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.navyBlue,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADVANCED SETTINGS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                            letterSpacing: 0.8,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          'HARDWARE & SIMULATION ENGINE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slateBlue,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Logout',
                      onPressed: () => _confirmLogout(context),
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body Content ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServerHealthCard(),
                      _buildSectionHeader('Simulation & Hardware'),
                      const SizedBox(height: 12),
                      _buildSliderSetting(
                        title: 'Ball Speed (km/h)',
                        value: _ballSpeed,
                        min: 60.0,
                        max: 160.0,
                        divisions: 20,
                        label: '${_ballSpeed.round()} km/h',
                        onChanged: (val) => setState(() => _ballSpeed = val),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownSetting(
                        title: 'Pitch Surface Simulation',
                        value: _pitchType,
                        items: const [
                          'Standard Turf',
                          'Dusty / Spin Friendly',
                          'Bouncy / Fast',
                          'Wet Turf',
                        ],
                        onChanged: (val) => setState(() => _pitchType = val!),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownSetting(
                        title: 'Lighting Preset',
                        value: _lightingLevel,
                        items: const [
                          'Daylight',
                          'High Floodlights',
                          'Medium Intensity',
                          'Low Intensity',
                        ],
                        onChanged: (val) => setState(() => _lightingLevel = val!),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Session Recording & Stats'),
                      const SizedBox(height: 12),
                      _buildSwitchSetting(
                        title: 'Automated Video Recording',
                        subtitle: 'Capture full HD session replays automatically.',
                        value: _videoRecording,
                        onChanged: (val) => setState(() => _videoRecording = val),
                      ),
                      const SizedBox(height: 14),
                      _buildSwitchSetting(
                        title: 'Real-time Analytics',
                        subtitle: 'Compute ball trajectories and pitch points.',
                        value: _analyticsTracking,
                        onChanged: (val) => setState(() => _analyticsTracking = val),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Game Mode Type'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.90),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildRadioOption('Match Practice'),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildRadioOption('Single Player Drill'),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildRadioOption('Tournament Play'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings saved successfully'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.navyBlue,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            gradient: AppTheme.primaryCtaGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Save Settings',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildLogoutButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmLogout(context),
          borderRadius: BorderRadius.circular(27),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 19),
                SizedBox(width: 8),
                Text(
                  'LOGOUT OF ACCOUNT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.6,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        color: AppTheme.navyBlue,
        letterSpacing: 0.7,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
            blurRadius: 14,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.electricBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: const GradientSliderTrackShape(),
              trackHeight: 6,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF0066FF).withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 3,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.navyBlue,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.electricBlue),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyBlue,
                  ),
                ),
                const SizedBox(height: 3),
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
          CyberGradientSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    final isSelected = _gameType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gameType = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.navyBlue : AppTheme.slateBlue,
              ),
            ),
            CyberGradientRadio(
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _gameType = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerHealthCard() {
    final bool isOnline = _healthResult?['online'] == true;
    final int latency = _healthResult?['latencyMs'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? const Color(0xFF10B981) : AppTheme.navyBlue)
                .withValues(alpha: 0.08),
            blurRadius: 14,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFFE6F4EA)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.dns_rounded,
                      color: isOnline ? const Color(0xFF10B981) : const Color(0xFFD97706),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SERVER HEALTH MONITOR',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                          letterSpacing: 0.5,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        'Real-time REST & Telemetry Sync',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.slateBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isCheckingHealth
                          ? 'PINGING...'
                          : (isOnline ? 'ONLINE' : 'OFFLINE'),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.iceBlue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.cardBorderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ApiConstants.baseUrl,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.navyBlue,
                      fontFamily: 'Roboto',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  isOnline ? '$latency ms latency' : 'Demo Fallback',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? const Color(0xFF10B981) : AppTheme.slateBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCheckingHealth ? null : _pingServer,
                  icon: _isCheckingHealth
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    'PING SERVER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.electricBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _openHostConfigDialog,
                icon: const Icon(Icons.settings_ethernet_rounded, size: 16, color: AppTheme.navyBlue),
                label: const Text(
                  'HOST IP',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.cardBorderColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
