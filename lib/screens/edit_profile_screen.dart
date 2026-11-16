import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/profile_image_service.dart';
import '../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _gender = 'Male';
  String? _avatarPath;
  String? _bannerPath;
  String? _bannerPreset;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('player_name') ?? 'Kesava';
    final parts = fullName.trim().split(' ');
    if (parts.isNotEmpty) {
      _firstNameController.text = parts[0];
      if (parts.length > 1) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
    _emailController.text = prefs.getString('player_email') ?? 'kesava.athlete@hexgen.pro';
    _phoneController.text = prefs.getString('player_phone') ?? '+91 98865 19422';
    _gender = prefs.getString('player_gender') ?? 'Male';
    _ageController.text = prefs.getString('player_age') ?? '';
    _bioController.text = prefs.getString('player_bio') ??
        'Cricket lover | Sports enthusiast |\nDream to play for India 🇮🇳';
    _avatarPath = prefs.getString(ProfileImageService.avatarPrefKey);
    _bannerPath = prefs.getString(ProfileImageService.bannerPrefKey);
    _bannerPreset = prefs.getString(ProfileImageService.bannerPresetPrefKey) ?? 'night_lights';
    if (mounted) setState(() {});
  }

  Future<void> _saveProfile() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final fullName = [first, last].where((s) => s.isNotEmpty).join(' ');
    final effectiveName = fullName.isNotEmpty ? fullName : 'Kesava';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', effectiveName);
    await prefs.setString('player_email', _emailController.text.trim());
    await prefs.setString('player_phone', _phoneController.text.trim());
    await prefs.setString('player_gender', _gender);
    await prefs.setString('player_age', _ageController.text.trim());
    await prefs.setString('player_bio', _bioController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Profile updated for $effectiveName!'),
        backgroundColor: AppTheme.electricBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
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
                  // ── Top Bar ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.arrow_back_rounded,
                                color: AppTheme.navyBlue,
                                size: 22,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _saveProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.electricBlue,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.electricBlue.withAlpha(80),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Form Area ────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Realistic Cover Banner & Overlapping Avatar ──
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Cover Banner
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                  child: Stack(
                                    children: [
                                      ProfileImageService.buildBanner(
                                        bannerPath: _bannerPath,
                                        bannerPreset: _bannerPreset,
                                        height: 110,
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            ProfileImageService.showBannerPickerSheet(
                                              context: context,
                                              onBannerUpdated: (val) {
                                                _loadProfileData();
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 13),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Edit Cover',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Overlapping Avatar
                                Transform.translate(
                                  offset: const Offset(0, -32),
                                  child: GestureDetector(
                                    onTap: () {
                                      ProfileImageService.showAvatarPickerSheet(
                                        context: context,
                                        onAvatarUpdated: (val) {
                                          _loadProfileData();
                                        },
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        ProfileImageService.buildAvatar(
                                          avatarPath: _avatarPath,
                                          displayName: _firstNameController.text.isNotEmpty
                                              ? _firstNameController.text
                                              : 'K',
                                          size: 74,
                                          borderWidth: 3,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: AppTheme.electricBlue,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Transform.translate(
                                  offset: const Offset(0, -22),
                                  child: GestureDetector(
                                    onTap: () {
                                      ProfileImageService.showAvatarPickerSheet(
                                        context: context,
                                        onAvatarUpdated: (val) {
                                          _loadProfileData();
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'Change Profile Picture',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.electricBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildFieldLabel('First Name'),
                          const SizedBox(height: 6),
                          _buildTextField(controller: _firstNameController),

                          const SizedBox(height: 14),

                          _buildFieldLabel('Last Name'),
                          const SizedBox(height: 6),
                          _buildTextField(controller: _lastNameController),

                          const SizedBox(height: 18),

                          _buildSectionTitle('Contact Details'),
                          const SizedBox(height: 12),

                          _buildFieldLabel('Email'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 14),

                          _buildFieldLabel('Phone'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 18),

                          _buildSectionTitle('About'),
                          const SizedBox(height: 12),

                          // Gender Dropdown
                          _buildFieldLabel('Gender'),
                          const SizedBox(height: 6),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.cardBorderColor,
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _gender,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.navyBlue,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.navyBlue,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Male', child: Text('Male')),
                                  DropdownMenuItem(
                                      value: 'Female', child: Text('Female')),
                                  DropdownMenuItem(
                                      value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _gender = val);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Age Field
                          _buildFieldLabel('Age'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 14),

                          // Bio Field
                          _buildFieldLabel('Bio'),
                          const SizedBox(height: 6),
                          Container(
                            height: 80,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.cardBorderColor,
                                width: 1.2,
                              ),
                            ),
                            child: TextField(
                              controller: _bioController,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.navyBlue,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          _buildSectionTitle('Other Accounts'),
                          const SizedBox(height: 12),

                          // Google Account Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.cardBorderColor,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildGoogleGLogo(),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.navyBlue,
                                    ),
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
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.navyBlue,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppTheme.navyBlue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.cardBorderColor,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.navyBlue,
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGoogleGLogo() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleGLogoPainter()),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final double radius = w / 2;
    final double innerRadius = radius * 0.55;
    final double barHeight = radius * 0.44;

    final circleRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Red (Top Arc: 220° to 325°)
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(circleRect, 1.22 * 3.14159, 0.58 * 3.14159, false)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // 2. Yellow (Left Arc: 140° to 220°)
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(circleRect, 0.78 * 3.14159, 0.44 * 3.14159, false)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 3. Green (Bottom Arc: 45° to 140°)
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(circleRect, 0.25 * 3.14159, 0.53 * 3.14159, false)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 4. Blue (Bottom-Right Arc: 0° to 45°)
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(circleRect, 0.0, 0.25 * 3.14159, false)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 5. Inner White Cutout
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, innerRadius, whitePaint);

    // 6. Blue Horizontal Crossbar (Center to Right Edge)
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - barHeight / 2,
        radius,
        barHeight,
      ),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
