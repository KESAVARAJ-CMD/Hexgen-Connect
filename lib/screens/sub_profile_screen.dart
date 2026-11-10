import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';

class SubProfileItem {
  final String id;
  String name;
  String playerId;
  String email;
  String phone;
  String age;
  String gender;
  String address;

  SubProfileItem({
    required this.id,
    required this.name,
    required this.playerId,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'playerId': playerId,
        'email': email,
        'phone': phone,
        'age': age,
        'gender': gender,
        'address': address,
      };

  factory SubProfileItem.fromJson(Map<String, dynamic> json) => SubProfileItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        playerId: json['playerId'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        age: json['age'] ?? '',
        gender: json['gender'] ?? '',
        address: json['address'] ?? '',
      );
}

class SubProfileScreen extends StatefulWidget {
  const SubProfileScreen({super.key});

  @override
  State<SubProfileScreen> createState() => _SubProfileScreenState();
}

class _SubProfileScreenState extends State<SubProfileScreen> {
  static const int maxProfiles = 4;
  static const String prefsKey = 'hexgen_sub_profiles_list_v1';

  List<SubProfileItem> _subProfiles = [];
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfilesFromPrefs();
  }

  Future<void> _loadProfilesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(prefsKey);
    if (rawData != null && rawData.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(rawData);
        _subProfiles = list.map((e) => SubProfileItem.fromJson(e)).toList();
      } catch (_) {
        _subProfiles = [];
      }
    } else {
      _subProfiles = [];
    }

    if (_selectedIndex >= _subProfiles.length) {
      _selectedIndex = _subProfiles.isEmpty ? 0 : _subProfiles.length - 1;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfilesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = jsonEncode(_subProfiles.map((p) => p.toJson()).toList());
    await prefs.setString(prefsKey, rawData);
  }

  void _openCreateProfileModal() {
    if (_subProfiles.length >= maxProfiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 sub profiles reached! Delete one to create another.'),
          backgroundColor: AppTheme.navyBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final randomId = '#ON6-${1000 + Random().nextInt(9000)}';
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: randomId);
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final genderCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Sub Profile (${_subProfiles.length + 1}/$maxProfiles)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.slateBlue),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSheetTextField('Full Name *', nameCtrl, Icons.person_outline_rounded, hint: 'e.g. Rahul Kumar'),
                const SizedBox(height: 12),
                _buildSheetTextField('Player ID', idCtrl, Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildSheetTextField('Email Address', emailCtrl, Icons.email_outlined, hint: 'e.g. athlete@gmail.com'),
                const SizedBox(height: 12),
                _buildSheetTextField('Phone Number', phoneCtrl, Icons.phone_outlined, hint: 'e.g. +91 98765 43210'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSheetTextField('Age', ageCtrl, Icons.cake_outlined, hint: 'e.g. 24 Years')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSheetTextField('Gender', genderCtrl, Icons.wc_rounded, hint: 'e.g. Male')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSheetTextField('Address', addressCtrl, Icons.location_on_outlined, maxLines: 2, hint: 'City, State'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a Full Name'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final newProfile = SubProfileItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        playerId: idCtrl.text.trim().isEmpty ? randomId : idCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty ? 'Not provided' : emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim().isEmpty ? 'Not provided' : phoneCtrl.text.trim(),
                        age: ageCtrl.text.trim().isEmpty ? 'Not specified' : ageCtrl.text.trim(),
                        gender: genderCtrl.text.trim().isEmpty ? 'Not specified' : genderCtrl.text.trim(),
                        address: addressCtrl.text.trim().isEmpty ? 'Not provided' : addressCtrl.text.trim(),
                      );

                      setState(() {
                        _subProfiles.add(newProfile);
                        _selectedIndex = _subProfiles.length - 1;
                      });

                      await _saveProfilesToPrefs();

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sub Profile "${newProfile.name}" created! (${_subProfiles.length}/$maxProfiles)'),
                            backgroundColor: AppTheme.navyBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.electricBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Save & Create Sub Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditProfileDialog(SubProfileItem profile) {
    final nameCtrl = TextEditingController(text: profile.name);
    final idCtrl = TextEditingController(text: profile.playerId);
    final emailCtrl = TextEditingController(text: profile.email == 'Not provided' ? '' : profile.email);
    final phoneCtrl = TextEditingController(text: profile.phone == 'Not provided' ? '' : profile.phone);
    final ageCtrl = TextEditingController(text: profile.age == 'Not specified' ? '' : profile.age);
    final genderCtrl = TextEditingController(text: profile.gender == 'Not specified' ? '' : profile.gender);
    final addressCtrl = TextEditingController(text: profile.address == 'Not provided' ? '' : profile.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      'Edit Sub Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.slateBlue),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSheetTextField('Full Name', nameCtrl, Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _buildSheetTextField('Player ID', idCtrl, Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildSheetTextField('Email Address', emailCtrl, Icons.email_outlined),
                const SizedBox(height: 12),
                _buildSheetTextField('Phone Number', phoneCtrl, Icons.phone_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSheetTextField('Age', ageCtrl, Icons.cake_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSheetTextField('Gender', genderCtrl, Icons.wc_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSheetTextField('Address', addressCtrl, Icons.location_on_outlined, maxLines: 2),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() {
                        profile.name = nameCtrl.text.trim().isEmpty ? profile.name : nameCtrl.text.trim();
                        profile.playerId = idCtrl.text.trim().isEmpty ? profile.playerId : idCtrl.text.trim();
                        profile.email = emailCtrl.text.trim().isEmpty ? 'Not provided' : emailCtrl.text.trim();
                        profile.phone = phoneCtrl.text.trim().isEmpty ? 'Not provided' : phoneCtrl.text.trim();
                        profile.age = ageCtrl.text.trim().isEmpty ? 'Not specified' : ageCtrl.text.trim();
                        profile.gender = genderCtrl.text.trim().isEmpty ? 'Not specified' : genderCtrl.text.trim();
                        profile.address = addressCtrl.text.trim().isEmpty ? 'Not provided' : addressCtrl.text.trim();
                      });

                      await _saveProfilesToPrefs();

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Sub Profile Updated Successfully!'),
                          backgroundColor: AppTheme.navyBlue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.electricBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteProfile(SubProfileItem profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Sub Profile?', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
        content: Text('Are you sure you want to remove "${profile.name}"? You can create a new sub profile anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.slateBlue, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _subProfiles.remove(profile);
                if (_selectedIndex >= _subProfiles.length) {
                  _selectedIndex = _subProfiles.isEmpty ? 0 : _subProfiles.length - 1;
                }
              });
              await _saveProfilesToPrefs();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sub Profile deleted.'),
                    backgroundColor: AppTheme.navyBlue,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetTextField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.navyBlue,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: AppTheme.navyBlue, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.slateBlue),
            prefixIcon: Icon(icon, color: AppTheme.royalBlue, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _openChangePictureSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.iceBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppTheme.electricBlue),
                ),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera opened (Simulated)'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.iceBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppTheme.electricBlue),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo selected from Gallery (Simulated)'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPrivacySettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isPublic = true;
        bool showPhone = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Privacy Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Public Sub Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: const Text('Allow arenas & coaches to view profile stats', style: TextStyle(fontSize: 11, color: AppTheme.slateBlue)),
                    value: isPublic,
                    activeThumbColor: AppTheme.electricBlue,
                    onChanged: (val) => setSheetState(() => isPublic = val),
                  ),
                  SwitchListTile(
                    title: const Text('Show Contact Number', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: const Text('Display phone number to teammates', style: TextStyle(fontSize: 11, color: AppTheme.slateBlue)),
                    value: showPhone,
                    activeThumbColor: AppTheme.electricBlue,
                    onChanged: (val) => setSheetState(() => showPhone = val),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy settings saved!'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navyBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.iceBlue,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasProfiles = _subProfiles.isNotEmpty;
    final currentProfile = hasProfiles ? _subProfiles[_selectedIndex] : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: true,
        showPattern: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header Bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.navyBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const Text(
                      'Sub Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (hasProfiles)
                      GestureDetector(
                        onTap: () => _openEditProfileDialog(currentProfile!),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: AppTheme.navyBlue,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),

              // ── Sub-Profiles Selector Pill Tabs (Up to 4) ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < _subProfiles.length; i++) ...[
                        GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedIndex == i ? AppTheme.electricBlue : Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _selectedIndex == i ? AppTheme.electricBlue : Colors.white.withValues(alpha: 0.85),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1C3E78).withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 14,
                                  color: _selectedIndex == i ? Colors.white : AppTheme.navyBlue,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _subProfiles[i].name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: _selectedIndex == i ? Colors.white : AppTheme.navyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_subProfiles.length < maxProfiles)
                        GestureDetector(
                          onTap: _openCreateProfileModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, size: 15, color: Color(0xFF0284C7)),
                                const SizedBox(width: 4),
                                Text(
                                  '+ Add (${_subProfiles.length}/$maxProfiles)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Max (4/4)',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slateBlue),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ── Main Content Body ────────────────────────────────────────
              Expanded(
                child: !hasProfiles
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // ── Profile Avatar & Camera Badge ────────────────────
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFBAE6FD), Color(0xFF38BDF8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1C3E78).withValues(alpha: 0.10),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/cricket_lane.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) {
                                            return Container(
                                              color: AppTheme.royalBlue,
                                              child: Center(
                                                child: Text(
                                                  currentProfile!.name.isNotEmpty ? currentProfile.name[0].toUpperCase() : 'S',
                                                  style: const TextStyle(
                                                    fontSize: 38,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Blue Camera Action Badge
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: _openChangePictureSheet,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0284C7),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ── Name & Player ID ─────────────────────────────────
                            Text(
                              currentProfile!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.navyBlue,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: Text(
                                'Player ID: ${currentProfile.playerId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0284C7),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── User Info Glass Card ─────────────────────────────
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1C3E78).withValues(alpha: 0.08),
                                    blurRadius: 18,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildInfoRow(Icons.mail_outline_rounded, currentProfile.email),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(Icons.phone_rounded, currentProfile.phone),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(Icons.cake_outlined, currentProfile.age),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(Icons.transgender_rounded, currentProfile.gender),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(Icons.location_on_outlined, currentProfile.address, isMultiLine: true),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Action Item 1: Edit Profile ──────────────────────
                            _buildActionTile(
                              icon: Icons.edit_rounded,
                              iconBgColor: const Color(0xFFF3E8FF),
                              iconColor: const Color(0xFF9333EA),
                              title: 'Edit Profile',
                              subtitle: 'Update your details',
                              onTap: () => _openEditProfileDialog(currentProfile),
                            ),

                            const SizedBox(height: 12),

                            // ── Action Item 2: Change Profile Picture ─────────────
                            _buildActionTile(
                              icon: Icons.camera_alt_rounded,
                              iconBgColor: const Color(0xFFFCE7F3),
                              iconColor: const Color(0xFFDB2777),
                              title: 'Change Profile Picture',
                              subtitle: 'Update your photo',
                              onTap: _openChangePictureSheet,
                            ),

                            const SizedBox(height: 12),

                            // ── Action Item 3: Privacy Settings ───────────────────
                            _buildActionTile(
                              icon: Icons.lock_rounded,
                              iconBgColor: const Color(0xFFEDE9FE),
                              iconColor: const Color(0xFF7C3AED),
                              title: 'Privacy Settings',
                              subtitle: 'Manage your privacy',
                              onTap: _openPrivacySettingsSheet,
                            ),

                            const SizedBox(height: 20),

                            // ── Delete Sub Profile Button ────────────────────────
                            GestureDetector(
                              onTap: () => _confirmDeleteProfile(currentProfile),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Delete This Sub Profile',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C3E78).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 32,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Sub Profiles Yet',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create up to 4 sub profiles for your family members, youth athletes, or alternate personas to track personal stats and arena bookings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.slateBlue,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _openCreateProfileModal,
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        label: const Text(
                          'Create First Sub Profile (1/4)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.electricBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFE0F2FE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.navyBlue,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C3E78).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slateBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.slateBlue,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
