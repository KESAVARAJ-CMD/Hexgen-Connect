import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SetSubProfileScreen extends StatefulWidget {
  const SetSubProfileScreen({super.key});

  @override
  State<SetSubProfileScreen> createState() => _SetSubProfileScreenState();
}

class _SetSubProfileScreenState extends State<SetSubProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _selectedLevelIndex = 0; // 0 = Beginner, 1 = Trainer, 2 = Pro, 3 = Expert, 4 = Master

  final List<String> _levels = [
    'Beginner',
    'Trainer',
    'Pro',
    'Expert',
    'Master',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sub Profile Created Successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.navyBlue,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar: Back < | Hexgen Logo (Left Aligned) ─────────────────
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
                      // Title Row with Square Plus Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Set your sub profile',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryCtaGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.electricBlue.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'What would you like your friends to call you?',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slateBlue,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Main Form White Card ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.cardBorderColor,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withAlpha(10),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. First Name
                            _buildLabel('First Name'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _firstNameController,
                              hint: 'Enter your first name',
                            ),

                            const SizedBox(height: 14),

                            // 2. Last Name
                            _buildLabel('Last Name'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _lastNameController,
                              hint: 'Enter your last name',
                            ),

                            const SizedBox(height: 14),

                            // 3. Email
                            _buildLabel('Email'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _emailController,
                              hint: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 18),

                            // 4. Your Level Stepper
                            _buildLabel('Your level'),
                            const SizedBox(height: 14),
                            _buildLevelStepper(),
                          ],
                        ),
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.navyBlue,
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.skyBlue,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.navyBlue,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildLevelStepper() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Connecting Line
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFFDDE8F7),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_levels.length, (index) {
                final isSelected = _selectedLevelIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevelIndex = index;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.electricBlue
                          : const Color(0xFFD1E5FC),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.electricBlue.withAlpha(80),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_levels.length, (index) {
            final isSelected = _selectedLevelIndex == index;
            return Expanded(
              child: Text(
                _levels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? AppTheme.navyBlue : AppTheme.slateBlue,
                ),
              ),
            );
          }),
        ),
      ],
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
