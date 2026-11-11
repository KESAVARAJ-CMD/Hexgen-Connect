import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/dashboard/player_dashboard_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String? initialPhone;
  final String? initialPlayerId;

  const CompleteProfileScreen({
    super.key,
    this.initialPhone,
    this.initialPlayerId,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _idController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _mobileController;
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  String? _selectedAge = '20 - 25';
  String _selectedGender = 'Male'; // 'Male' or 'Female'
  String _selectedRole = '🏏 Batsman'; // '🏏 Batsman', '⚡ Bowler', '🧤 Keeper', '🔥 All-Rounder'

  final List<String> _roles = [
    '🏏 Batsman',
    '⚡ Bowler',
    '🧤 Keeper',
    '🔥 All-Rounder',
  ];

  final List<String> _ageOptions = [
    'Under 14',
    'Under 16',
    'Under 19',
    '20 - 25',
    '26 - 30',
    '31 - 35',
    '36 - 45',
    '45+',
  ];

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(
      text: widget.initialPlayerId ?? 'HX-${1000 + Random().nextInt(9000)}',
    );
    _mobileController = TextEditingController(
      text: widget.initialPhone ?? '',
    );
    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _mobileController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (_mobileController.text.isEmpty) {
      final savedPhone = prefs.getString('player_phone');
      if (savedPhone != null && savedPhone.isNotEmpty) {
        setState(() {
          _mobileController.text = savedPhone;
        });
      }
    }
    if (widget.initialPlayerId == null) {
      final savedId = prefs.getString('player_id');
      if (savedId != null && savedId.isNotEmpty) {
        setState(() {
          _idController.text = savedId;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  double get _profileProgress {
    double score = 0.2; // Base for ID
    if (_nameController.text.trim().isNotEmpty) score += 0.25;
    if (_mobileController.text.trim().isNotEmpty) score += 0.2;
    if (_emailController.text.trim().isNotEmpty) score += 0.15;
    if (_addressController.text.trim().isNotEmpty) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  Future<void> _onSaveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Full Name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final id = _idController.text.trim().isEmpty ? 'HX-${1000 + Random().nextInt(9000)}' : _idController.text.trim();
    final email = _emailController.text.trim();
    final phone = _mobileController.text.trim();
    final age = _selectedAge ?? '20 - 25';
    final gender = _selectedGender;
    final address = _addressController.text.trim().isEmpty ? 'Bangalore Arena' : _addressController.text.trim();

    // Persist profile in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_profile_completed', true);
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'player');
    await prefs.setString('player_name', name);
    await prefs.setString('player_id', id);
    await prefs.setString('player_email', email);
    await prefs.setString('player_phone', phone);
    await prefs.setString('player_age', age);
    await prefs.setString('player_gender', gender);
    await prefs.setString('player_role', _selectedRole);
    await prefs.setString('player_address', address);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerDashboardScreen(
          playerName: name,
          playerId: id,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _profileProgress;
    final progressPercent = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        child: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            children: [
              // ── 1. Top Cyber HUD Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HEXGEN CONNECT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                            letterSpacing: 0.8,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          'SMART ATHLETE HUD • ONBOARDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slateBlue.withValues(alpha: 0.8),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Step Pill Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryCtaGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.electricBlue.withAlpha(60),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'STEP 1 OF 2',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Scrollable Body Content ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Column(
                    children: [
                      // Interactive Profile Readiness Gauge Card
                      _buildReadinessGaugeCard(progress, progressPercent),

                      const SizedBox(height: 18),

                      // Holographic Avatar with Live Initial & Camera Badge
                      _buildHolographicAvatar(),

                      const SizedBox(height: 16),

                      // Primary Role Selection Chips
                      _buildRoleChips(),

                      const SizedBox(height: 18),

                      // ── Section 1: Athlete Digital ID & Identity ────────────
                      _buildFrostedSectionCard(
                        title: 'ATHLETE IDENTITY',
                        icon: Icons.fingerprint_rounded,
                        children: [
                          _buildModernField(
                            label: 'Player ID',
                            badge: 'AUTONOMOUS RADAR SYNCED',
                            child: _buildReadonlyIdBox(),
                          ),
                          const SizedBox(height: 14),
                          _buildModernField(
                            label: 'Player Full Name',
                            child: _buildInputBox(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              hint: 'e.g. Karthik Raja',
                              icon: Icons.person_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── Section 2: Contact & Telemetry Sync ──────────────────
                      _buildFrostedSectionCard(
                        title: 'TELEMETRY & CONTACT',
                        icon: Icons.contact_emergency_rounded,
                        children: [
                          _buildModernField(
                            label: 'Mobile Number',
                            child: _buildMobileInputBox(),
                          ),
                          const SizedBox(height: 14),
                          _buildModernField(
                            label: 'Email Address',
                            child: _buildInputBox(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              hint: 'e.g. athlete@hexgen.com',
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── Section 3: Biometrics & Training Group ───────────────
                      _buildFrostedSectionCard(
                        title: 'BIOMETRICS & PHYSIOLOGY',
                        icon: Icons.fitness_center_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernField(
                                  label: 'Age Bracket',
                                  child: _buildAgeDropdown(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModernField(
                                  label: 'Gender',
                                  child: _buildGenderSelector(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── Section 4: Home Turf Arena Location ──────────────────
                      _buildFrostedSectionCard(
                        title: 'HOME TRAINING ARENA',
                        icon: Icons.stadium_rounded,
                        children: [
                          _buildModernField(
                            label: 'Training Base Location',
                            badge: 'RADAR AUTO-PAIR',
                            child: _buildInputBox(
                              controller: _addressController,
                              focusNode: _addressFocusNode,
                              hint: 'e.g. Shanthinagar Turf, Bangalore',
                              icon: Icons.location_on_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── High-Velocity Stadium Gradient Action Button ─────────────
                      GestureDetector(
                        onTap: _onSaveAndContinue,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0052FF), // Royal Deep Blue
                                Color(0xFF00B4F4), // Cyan Electric Glow
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'SAVE & ENTER ARENA',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
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
      ),
    );
  }

  // ── Dynamic Profile Readiness Gauge Card ────────────────────────────────────
  Widget _buildReadinessGaugeCard(double progress, int percent) {
    final isFull = percent >= 95;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD6E4F8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.iceBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: AppTheme.electricBlue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete Your Dossier',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          Text(
                            'Calibrates live 60FPS radar cameras',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.slateBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isFull ? '100% READY ⚡' : '$percent% SETUP',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isFull ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFull ? const Color(0xFF10B981) : AppTheme.electricBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Holographic Avatar with Dynamic Initial ─────────────────────────────────
  Widget _buildHolographicAvatar() {
    final name = _nameController.text.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '⚡';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Pulsating Glow Circle
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00B4F4).withValues(alpha: 0.35),
                    const Color(0xFF0052FF).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Middle Glass Rim
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF00D4FF),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.electricBlue,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            // Floating Camera Action Badge
            Positioned(
              bottom: 4,
              right: 6,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryCtaGradient,
                  border: Border.all(color: Colors.white, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload Athlete Profile Photo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'JPG, PNG • Camera AI Face ID Ready',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.slateBlue,
          ),
        ),
      ],
    );
  }

  // ── Primary Role Selection Chips ────────────────────────────────────────────
  Widget _buildRoleChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _roles.map((role) {
          final isSelected = _selectedRole == role;

          return GestureDetector(
            onTap: () => setState(() => _selectedRole = role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.cardBorderColor,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.electricBlue.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.navyBlue,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Reusable Frosted Section Container ──────────────────────────────────────
  Widget _buildFrostedSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD6E4F8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.iceBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: AppTheme.electricBlue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.7,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // ── Modern Field Wrapper ───────────────────────────────────────────────────
  Widget _buildModernField({
    required String label,
    String? badge,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.navyBlue,
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  // ── Readonly Player ID with Radar Icon ─────────────────────────────────────
  Widget _buildReadonlyIdBox() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_rounded, color: AppTheme.slateBlue, size: 20),
          const SizedBox(width: 10),
          Text(
            _idController.text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.navyBlue,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'ACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Box with Leading Icon & Signature Gradient Border on Focus ───────
  Widget _buildInputBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return _GradientBorderInputWrapper(
      focusNode: focusNode,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.electricBlue, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.navyBlue,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Number Input Box with Flag/Code & Gradient Border on Focus ──────
  Widget _buildMobileInputBox() {
    return _GradientBorderInputWrapper(
      focusNode: _mobileFocusNode,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.iceBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('🇮🇳 ', style: TextStyle(fontSize: 13)),
                Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navyBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _mobileController,
              focusNode: _mobileFocusNode,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.navyBlue,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter 10-digit mobile number',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Age Dropdown ───────────────────────────────────────────────────────────
  Widget _buildAgeDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyBlue.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAge,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.slateBlue, size: 20),
          items: _ageOptions.map((age) {
            return DropdownMenuItem<String>(
              value: age,
              child: Text(
                age,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navyBlue,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedAge = val);
          },
        ),
      ),
    );
  }

  // ── 3D Cyber Gender Selector ───────────────────────────────────────────────
  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = 'Male'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: _selectedGender == 'Male'
                    ? const LinearGradient(colors: [Color(0xFF0052FF), Color(0xFF0099FF)])
                    : null,
                color: _selectedGender == 'Male' ? null : Colors.white,
                border: Border.all(
                  color: _selectedGender == 'Male' ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: _selectedGender == 'Male'
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.male_rounded,
                    color: _selectedGender == 'Male' ? Colors.white : AppTheme.slateBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Male',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _selectedGender == 'Male' ? Colors.white : AppTheme.navyBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = 'Female'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: _selectedGender == 'Female'
                    ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)])
                    : null,
                color: _selectedGender == 'Female' ? null : Colors.white,
                border: Border.all(
                  color: _selectedGender == 'Female' ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: _selectedGender == 'Female'
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.female_rounded,
                    color: _selectedGender == 'Female' ? Colors.white : AppTheme.slateBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Female',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _selectedGender == 'Female' ? Colors.white : AppTheme.navyBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable Component: Blue Gradient Border on Focus with Soft Cyber Glow ────
class _GradientBorderInputWrapper extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;

  const _GradientBorderInputWrapper({
    required this.child,
    this.focusNode,
  });

  @override
  State<_GradientBorderInputWrapper> createState() => _GradientBorderInputWrapperState();
}

class _GradientBorderInputWrapperState extends State<_GradientBorderInputWrapper> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
    _isFocused = widget.focusNode?.hasFocus ?? false;
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant _GradientBorderInputWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
      _isFocused = widget.focusNode?.hasFocus ?? false;
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _isFocused
            ? const LinearGradient(
                colors: [
                  Color(0xFF0052FF), // Royal Deep Blue
                  Color(0xFF00D4FF), // Cyan-Blue Electric Glow
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        border: _isFocused
            ? null
            : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: AppTheme.navyBlue.withAlpha(6),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Container(
        margin: EdgeInsets.all(_isFocused ? 1.2 : 0),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_isFocused ? 12.8 : 14),
        ),
        child: widget.child,
      ),
    );
  }
}
