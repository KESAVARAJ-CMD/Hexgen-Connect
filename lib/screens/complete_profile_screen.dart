import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import 'continue_with_screen.dart';

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
  static const String subProfilesPrefsKey = 'hexgen_sub_profiles_list_v1';

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  String _selectedGender = 'Male';
  final List<String> _genders = const [
    'Male',
    'Female',
    'Other',
  ];

  int _selectedLevelIndex = 0; // 0: Beginner, 1: Pro, 2: Expert, 3: Master
  final List<String> _levels = const [
    'Beginner',
    'Pro',
    'Expert',
    'Master',
  ];

  List<Map<String, dynamic>> _subProfiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load any existing profile info
    final existingName = prefs.getString('player_name') ?? '';
    if (existingName.isNotEmpty) {
      final parts = existingName.split(' ');
      _firstNameController.text = parts.first;
      if (parts.length > 1) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
    final existingEmail = prefs.getString('player_email') ?? '';
    if (existingEmail.isNotEmpty) {
      _emailController.text = existingEmail;
    }
    final existingGender = prefs.getString('player_gender');
    if (existingGender != null && _genders.contains(existingGender)) {
      _selectedGender = existingGender;
    }
    final existingAge = prefs.getString('player_age') ?? '';
    if (existingAge.isNotEmpty) {
      _ageController.text = existingAge;
    }
    final existingBio = prefs.getString('player_bio') ?? prefs.getString('player_address') ?? '';
    if (existingBio.isNotEmpty) {
      _bioController.text = existingBio;
    }
    final existingLevel = prefs.getString('player_level') ?? '';
    if (existingLevel.isNotEmpty && _levels.contains(existingLevel)) {
      _selectedLevelIndex = _levels.indexOf(existingLevel);
    }

    // Load sub-profiles
    final rawSubProfiles = prefs.getString(subProfilesPrefsKey);
    if (rawSubProfiles != null && rawSubProfiles.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(rawSubProfiles);
        setState(() {
          _subProfiles = list.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } catch (_) {
        _subProfiles = [];
      }
    }
  }

  Future<void> _saveSubProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(subProfilesPrefsKey, jsonEncode(_subProfiles));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _ageFocus.dispose();
    _bioFocus.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final rawFirst = _firstNameController.text.trim();
    final firstName = rawFirst.isNotEmpty ? rawFirst : 'Karthik';

    setState(() => _isLoading = true);

    final lastName = _lastNameController.text.trim();
    final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
    final email = _emailController.text.trim();
    final gender = _selectedGender;
    final age = _ageController.text.trim();
    final bio = _bioController.text.trim();
    final level = _levels[_selectedLevelIndex];

    final prefs = await SharedPreferences.getInstance();
    final playerId = widget.initialPlayerId ??
        prefs.getString('player_id') ??
        'HX-${1000 + Random().nextInt(9000)}';
    final phone = widget.initialPhone ?? prefs.getString('player_phone') ?? '';

    // Persist finalized profile
    await prefs.setBool('is_profile_completed', true);
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'player');
    await prefs.setString('player_name', fullName);
    await prefs.setString('player_first_name', firstName);
    await prefs.setString('player_last_name', lastName);
    await prefs.setString('player_id', playerId);
    await prefs.setString('player_phone', phone);
    await prefs.setString('player_email', email);
    await prefs.setString('player_gender', gender);
    await prefs.setString('player_age', age);
    await prefs.setString('player_level', level);
    await prefs.setString('player_address', bio);
    await prefs.setString('player_bio', bio);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Step 4 -> Step 5: Navigate to ContinueWithScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContinueWithScreen(
          playerName: fullName,
          playerId: playerId,
        ),
      ),
    );
  }

  void _openAddSubProfileModal() {
    final subFirstCtrl = TextEditingController();
    final subLastCtrl = TextEditingController();
    final subEmailCtrl = TextEditingController();
    final subAgeCtrl = TextEditingController();
    String subGender = 'Male';
    int subLevelIdx = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Sub Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('First Name'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subFirstCtrl,
                    hint: 'Enter sub profile first name',
                  ),
                  const SizedBox(height: 12),
                  _buildFieldLabel('Last Name'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subLastCtrl,
                    hint: 'Enter sub profile last name',
                  ),
                  const SizedBox(height: 12),
                  _buildFieldLabel('Email (Optional)'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subEmailCtrl,
                    hint: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildFieldLabel('Gender'),
                  const SizedBox(height: 8),
                  _buildGenderSelector(
                    selectedGender: subGender,
                    onSelect: (val) => setModalState(() => subGender = val),
                  ),
                  const SizedBox(height: 12),
                  _buildFieldLabel('Age'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subAgeCtrl,
                    hint: 'Enter age (e.g. 18)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Skill Level'),
                  const SizedBox(height: 10),
                  _buildLevelStepperWidget(
                    selectedIndex: subLevelIdx,
                    onSelect: (index) {
                      setModalState(() => subLevelIdx = index);
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final fName = subFirstCtrl.text.trim();
                      if (fName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter sub profile first name'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final lName = subLastCtrl.text.trim();
                      final subName = lName.isNotEmpty ? '$fName $lName' : fName;
                      final subId = '#SUB-${1000 + Random().nextInt(9000)}';

                      final newSubProfile = {
                        'id': subId,
                        'name': subName,
                        'firstName': fName,
                        'lastName': lName,
                        'email': subEmailCtrl.text.trim(),
                        'gender': subGender,
                        'age': subAgeCtrl.text.trim(),
                        'level': _levels[subLevelIdx],
                      };

                      setState(() {
                        _subProfiles.add(newSubProfile);
                      });
                      await _saveSubProfiles();

                      if (ctx.mounted) Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Sub profile "$subName" added! Total: ${_subProfiles.length}'),
                            backgroundColor: AppTheme.navyBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryCtaGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Save Sub Profile',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSubProfilesListModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sub Profiles (${_subProfiles.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openAddSubProfileModal();
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add More'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_subProfiles.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No sub profiles added yet.',
                        style: TextStyle(color: AppTheme.slateBlue),
                      ),
                    ),
                  ),
                ] else ...[
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _subProfiles.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final p = _subProfiles[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFF3E8FF),
                            child: Text(
                              (p['name'] as String? ?? 'S').substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            p['name'] ?? 'Sub Athlete',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          subtitle: Text(
                            'Level: ${p['level'] ?? 'Beginner'} • ${p['id'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.slateBlue,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () async {
                              setState(() {
                                _subProfiles.removeAt(index);
                              });
                              setModalState(() {});
                              await _saveSubProfiles();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: false,
        child: SafeArea(
          child: Column(
            children: [
              // ── 1. Top Bar: Back Arrow `<` + "Complete your profile" + "+ Sub Profile" ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Complete your profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // "+ Sub Profile" Clean Pill Button
                    GestureDetector(
                      onTap: _openAddSubProfileModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Color(0xFF0F172A),
                              size: 15,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Sub Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle: "What would you like your friends to call you?"
                      const Text(
                        'What would you like your friends to call you?',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      // "Total sub profiles: X" Pill Badge
                      if (_subProfiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showSubProfilesListModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total sub profiles: ${_subProfiles.length}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Form Fields Card ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. First Name
                            _buildFieldLabel('First Name'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _firstNameController,
                              focusNode: _firstNameFocus,
                              hint: 'Enter your first name',
                            ),

                            const SizedBox(height: 16),

                            // 2. Last Name
                            _buildFieldLabel('Last Name'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _lastNameController,
                              focusNode: _lastNameFocus,
                              hint: 'Enter your last name',
                            ),

                            const SizedBox(height: 16),

                            // 3. Email
                            _buildFieldLabel('Email'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              hint: 'Enter your email address',
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // 4. Gender Selection
                            _buildFieldLabel('Gender'),
                            const SizedBox(height: 8),
                            _buildGenderSelector(
                              selectedGender: _selectedGender,
                              onSelect: (val) {
                                setState(() {
                                  _selectedGender = val;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // 5. Age
                            _buildFieldLabel('Age'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _ageController,
                              focusNode: _ageFocus,
                              hint: 'Enter your age (e.g. 21)',
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 20),

                            // 6. Your Level Stepper (Beginner, Trainer, Pro, Expert, Master)
                            _buildFieldLabel('Your level'),
                            const SizedBox(height: 14),
                            _buildLevelStepperWidget(
                              selectedIndex: _selectedLevelIndex,
                              onSelect: (index) {
                                setState(() {
                                  _selectedLevelIndex = index;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            // 7. Bio (Multiline)
                            _buildFieldLabel('Bio'),
                            const SizedBox(height: 6),
                            _buildMultilineInputBox(
                              controller: _bioController,
                              focusNode: _bioFocus,
                              hint: 'Tell us a bit about your cricket journey or goals',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // ── 3. Bottom Sticky "Continue" Button ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: GestureDetector(
                  onTap: _isLoading ? null : _onContinue,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppTheme.primaryCtaGradient,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
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

  // ── Helper Widgets ──────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildGenderSelector({
    required String selectedGender,
    required ValueChanged<String> onSelect,
  }) {
    final genderOptions = [
      {'label': 'Male', 'icon': Icons.male_rounded},
      {'label': 'Female', 'icon': Icons.female_rounded},
      {'label': 'Other', 'icon': Icons.person_outline_rounded},
    ];

    return Row(
      children: genderOptions.map((opt) {
        final label = opt['label'] as String;
        final icon = opt['icon'] as IconData;
        final isSelected = selectedGender == label;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSelect(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.0,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF0052FF).withValues(alpha: 0.28)
                          : const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: isSelected ? 6 : 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
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

  Widget _buildMultilineInputBox({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLevelStepperWidget({
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Connecting line
            Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xFFE2E8F0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_levels.length, (index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => onSelect(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                      color: isSelected ? null : const Color(0xFFE2E8F0),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
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
            final isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(index),
                child: Text(
                  _levels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
