import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final TextEditingController _bioController = TextEditingController();

  String _gender = 'Male';

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
    _bioController.text = prefs.getString('player_bio') ??
        'Cricket lover | Sports enthusiast |\nDream to play for India 🇮🇳';
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
                                Icons.arrow_back_ios_rounded,
                                color: AppTheme.navyBlue,
                                size: 18,
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
                        _buildHexgenLogo(),
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
                          // Avatar & Change Photo
                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 82,
                                      height: 82,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.electricBlue.withAlpha(40),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        image: const DecorationImage(
                                          image: NetworkImage(
                                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: AppTheme.electricBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Change Profile Picture',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.electricBlue,
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
    return Image.network(
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(painter: _GoogleGLogoPainter()),
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

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final double radius = w / 2;

    // Blue Bar & Arc
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), 0, -3.14 * 0.4, false)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Red Top Arc
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), -3.14 * 0.4, -3.14 * 0.55, false)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow Left Arc
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), -3.14 * 0.95, -3.14 * 0.35, false)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green Bottom Arc
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), -3.14 * 1.30, -3.14 * 0.45, false)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Inner White Hole
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.52, whitePaint);

    // Inner Blue Horizontal Rect Line
    final blueLinePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.22, radius * 0.95, radius * 0.44),
      blueLinePaint,
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
