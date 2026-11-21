import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/profile_image_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../widgets/avatar_cropper_dialog.dart';
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

  String? _avatarPath;
  List<Map<String, dynamic>> _subProfiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final prefs = await SharedPreferences.getInstance();

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

    _avatarPath = prefs.getString(ProfileImageService.avatarPrefKey);

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

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0052FF)),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1600,
                    maxHeight: 1600,
                    imageQuality: 95,
                  );
                  if (picked != null && mounted) {
                    final croppedPath = await AvatarCropperDialog.show(
                      context,
                      File(picked.path),
                    );
                    if (croppedPath != null && mounted) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(ProfileImageService.avatarPrefKey, croppedPath);
                      setState(() => _avatarPath = croppedPath);
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0052FF)),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1600,
                    maxHeight: 1600,
                    imageQuality: 95,
                  );
                  if (picked != null && mounted) {
                    final croppedPath = await AvatarCropperDialog.show(
                      context,
                      File(picked.path),
                    );
                    if (croppedPath != null && mounted) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(ProfileImageService.avatarPrefKey, croppedPath);
                      setState(() => _avatarPath = croppedPath);
                    }
                  }
                },
              ),
              if (_avatarPath != null)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE11D48)),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ProfileImageService.clearAvatar();
                    if (mounted) setState(() => _avatarPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
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

    // Save profile to persistent multi-profile store
    final profileRecord = {
      'name': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'id': playerId,
      'phone': phone,
      'email': email,
      'gender': gender,
      'age': age,
      'level': level,
      'bio': bio,
      'avatarPath': _avatarPath,
    };
    final allProfilesRaw = prefs.getString('hexgen_all_profiles_v1');
    List<dynamic> allProfiles = [];
    if (allProfilesRaw != null && allProfilesRaw.isNotEmpty) {
      try {
        allProfiles = jsonDecode(allProfilesRaw);
      } catch (_) {}
    }
    allProfiles.removeWhere((p) => p['id'] == playerId);
    allProfiles.add(profileRecord);
    await prefs.setString('hexgen_all_profiles_v1', jsonEncode(allProfiles));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContinueWithScreen(
          playerName: fullName,
          playerId: playerId,
          phone: phone,
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
    String? subAvatarPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickSubAvatar() async {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (pickerCtx) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Choose Sub Profile Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0052FF)),
                        ),
                        title: const Text(
                          'Choose from Gallery',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        onTap: () async {
                          Navigator.pop(pickerCtx);
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1600,
                            maxHeight: 1600,
                            imageQuality: 95,
                          );
                          if (picked != null && context.mounted) {
                            final croppedPath = await AvatarCropperDialog.show(
                              context,
                              File(picked.path),
                            );
                            if (croppedPath != null) {
                              setModalState(() => subAvatarPath = croppedPath);
                            }
                          }
                        },
                      ),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0052FF)),
                        ),
                        title: const Text(
                          'Take a Photo',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        onTap: () async {
                          Navigator.pop(pickerCtx);
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 1600,
                            maxHeight: 1600,
                            imageQuality: 95,
                          );
                          if (picked != null && context.mounted) {
                            final croppedPath = await AvatarCropperDialog.show(
                              context,
                              File(picked.path),
                            );
                            if (croppedPath != null) {
                              setModalState(() => subAvatarPath = croppedPath);
                            }
                          }
                        },
                      ),
                      if (subAvatarPath != null)
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48)),
                          ),
                          title: const Text(
                            'Remove Photo',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE11D48)),
                          ),
                          onTap: () {
                            Navigator.pop(pickerCtx);
                            setModalState(() => subAvatarPath = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

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
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0052FF), size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Add Sub Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Sub Profile Avatar Picker (With Zoom / Crop) ───
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: pickSubAvatar,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0052FF).withValues(alpha: 0.12),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: subAvatarPath != null
                                      ? Image.file(
                                          File(subAvatarPath!),
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 46,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickSubAvatar,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryCtaGradient,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload Profile Photo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _buildFieldLabel('First Name'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subFirstCtrl,
                    hint: 'Enter first name (e.g. Aarav)',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('Last Name'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subLastCtrl,
                    hint: 'Enter last name',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('Email (Optional)'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subEmailCtrl,
                    hint: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('Gender'),
                  const SizedBox(height: 8),
                  _buildGenderSelector(
                    selectedGender: subGender,
                    onSelect: (val) => setModalState(() => subGender = val),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('Age'),
                  const SizedBox(height: 6),
                  _buildInputBox(
                    controller: subAgeCtrl,
                    hint: 'Enter age (e.g. 12)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.cake_outlined,
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
                            backgroundColor: Color(0xFFE11D48),
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
                        'avatarPath': subAvatarPath,
                      };

                      setState(() {
                        _subProfiles.add(newSubProfile);
                      });
                      await _saveSubProfiles();

                      if (ctx.mounted) Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Sub profile "$subName" added successfully!'),
                            backgroundColor: const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            color: const Color(0xFF0052FF).withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sub Profiles (${_subProfiles.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openAddSubProfileModal();
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Another', style: TextStyle(fontWeight: FontWeight.w700)),
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
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ] else ...[
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _subProfiles.length,
                      separatorBuilder: (_, _) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final p = _subProfiles[index];
                        final initial = (p['name'] as String? ?? 'S').substring(0, 1).toUpperCase();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Color(0xFF0052FF),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'] ?? 'Sub Athlete',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Level: ${p['level'] ?? 'Beginner'} • Age: ${p['age'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 20),
                                onPressed: () async {
                                  setState(() {
                                    _subProfiles.removeAt(index);
                                  });
                                  setModalState(() {});
                                  await _saveSubProfiles();
                                },
                              ),
                            ],
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
              // ── Top Navigation Bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF0F172A),
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Personalize your cricket experience',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "+ Sub Profile" Clean Pill Button
                    GestureDetector(
                      onTap: _openAddSubProfileModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052FF).withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Color(0xFF0052FF),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Sub Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0052FF),
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

              // ── Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // ── Profile Photo Section (Modern Avatar Picker) ─────
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickAvatar,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0052FF).withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _avatarPath != null
                                      ? Image.file(
                                          File(_avatarPath!),
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            size: 52,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAvatar,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryCtaGradient,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload Profile Photo',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),

                      // "Total sub profiles: X" Pill Badge
                      if (_subProfiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showSubProfilesListModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.group_outlined, size: 15, color: Color(0xFF0052FF)),
                                const SizedBox(width: 6),
                                Text(
                                  'Linked Sub Profiles: ${_subProfiles.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Card 1: Personal Details ─────────────────────────
                      _buildSectionCard(
                        title: 'Personal Details',
                        icon: Icons.person_outline_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('First Name'),
                                    const SizedBox(height: 6),
                                    _buildInputBox(
                                      controller: _firstNameController,
                                      focusNode: _firstNameFocus,
                                      hint: 'e.g. Karthik',
                                      prefixIcon: Icons.badge_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Last Name'),
                                    const SizedBox(height: 6),
                                    _buildInputBox(
                                      controller: _lastNameController,
                                      focusNode: _lastNameFocus,
                                      hint: 'e.g. Raja',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('Email Address'),
                          const SizedBox(height: 6),
                          _buildInputBox(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            hint: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Gender'),
                                    const SizedBox(height: 6),
                                    _buildGenderSelector(
                                      selectedGender: _selectedGender,
                                      onSelect: (val) {
                                        setState(() => _selectedGender = val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Age'),
                                    const SizedBox(height: 6),
                                    _buildInputBox(
                                      controller: _ageController,
                                      focusNode: _ageFocus,
                                      hint: 'Age',
                                      keyboardType: TextInputType.number,
                                      prefixIcon: Icons.cake_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Card 2: Cricket Skill & Bio ──────────────────────
                      _buildSectionCard(
                        title: 'Cricket Skill Level',
                        icon: Icons.sports_cricket_rounded,
                        children: [
                          _buildFieldLabel('Select Your Current Level'),
                          const SizedBox(height: 12),
                          _buildLevelStepperWidget(
                            selectedIndex: _selectedLevelIndex,
                            onSelect: (index) {
                              setState(() => _selectedLevelIndex = index);
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildFieldLabel('About You (Bio)'),
                          const SizedBox(height: 6),
                          _buildMultilineInputBox(
                            controller: _bioController,
                            focusNode: _bioFocus,
                            hint: 'Tell us about your batting style, favorite shots, or cricket goals...',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Save & Continue Button ───────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _onContinue,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: AppTheme.primaryCtaGradient,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Save & Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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

  // ── Helper Widgets ──────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF0052FF)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF475569),
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
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: GestureDetector(
              onTap: () => onSelect(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 46,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                  color: isSelected ? null : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.0,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF0052FF).withValues(alpha: 0.25)
                          : const Color(0xFF0F172A).withValues(alpha: 0.02),
                      blurRadius: isSelected ? 6 : 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5,
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
    IconData? prefixIcon,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: 16, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.normal,
                ),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultilineInputBox({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12.5,
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
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: const Color(0xFFE2E8F0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_levels.length, (index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => onSelect(index),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected ? AppTheme.primaryCtaGradient : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF0052FF).withValues(alpha: 0.35)
                              : const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: isSelected ? 6 : 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0052FF) : const Color(0xFF64748B),
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
