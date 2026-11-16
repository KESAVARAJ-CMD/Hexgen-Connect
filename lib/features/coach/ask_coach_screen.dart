import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../services/demo_state.dart';

/// Clean, dedicated full-page screen for asking a coach for guidance or review.
/// Accessible from:
/// 1) Connect Tab -> Coaches list (coach pre-selected)
/// 2) Over Video Player -> "Ask Coach (Ball X)" (session & ball pre-attached)
/// 3) Sessions Tab -> "Ask Coach" button on any session
class AskCoachScreen extends StatefulWidget {
  final Map<String, dynamic>? initialCoach;
  final String? preAttachedSession;

  const AskCoachScreen({
    super.key,
    this.initialCoach,
    this.preAttachedSession,
  });

  static Future<void> open(
    BuildContext context, {
    Map<String, dynamic>? initialCoach,
    String? preAttachedSession,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AskCoachScreen(
          initialCoach: initialCoach,
          preAttachedSession: preAttachedSession,
        ),
      ),
    );
  }

  @override
  State<AskCoachScreen> createState() => _AskCoachScreenState();
}

class _AskCoachScreenState extends State<AskCoachScreen> {
  final DemoState _state = DemoState();
  late int _selectedCoachIndex;
  late int _selectedSessionIndex;
  int _selectedTopicIndex = 0;
  bool _isSubmitting = false;
  String? _customAttachedSession;
  final TextEditingController _questionController = TextEditingController();

  final List<Map<String, String>> _sessionList = const [
    {
      'title': 'Session 3 • Cover Drive Practice',
      'detail': '3 Overs • 142.4 km/h • Hexgen Turf',
    },
    {
      'title': 'Session 2 • Fast Pace & Line',
      'detail': '2 Overs • 138.8 km/h • Hexgen Turf',
    },
    {
      'title': 'Session 1 • Front Foot Defense',
      'detail': '4 Overs • 134.0 km/h • Hexgen Turf',
    },
    {
      'title': 'No Session (General Cricket Doubt)',
      'detail': 'Ask technical question without video',
    },
  ];

  final List<String> _commonTopics = const [
    '🏏 Batting Shot Correction',
    '🦶 Footwork & Balance',
    '⚡ Bat Speed & Power',
    '🎯 Bowling Line & Length',
    '📹 Review My Video',
  ];

  final List<String> _quickDoubtChips = const [
    'Edge to slips issue',
    'Head falling over',
    'Front foot too early',
    'Late bat swing',
    'Back foot punch balance',
    'Seam wobble release',
  ];

  @override
  void initState() {
    super.initState();
    _customAttachedSession = widget.preAttachedSession;

    // 1. Pre-select coach if provided
    if (widget.initialCoach != null) {
      final idx = _state.verifiedCoaches.indexWhere(
        (c) => c['handle'] == widget.initialCoach!['handle'],
      );
      _selectedCoachIndex = idx >= 0 ? idx : 0;
    } else {
      _selectedCoachIndex = 0;
    }

    // 2. Pre-select session if provided
    if (_customAttachedSession != null) {
      final idx = _sessionList.indexWhere(
        (s) => s['title']!.toLowerCase().contains(_customAttachedSession!.toLowerCase()),
      );
      _selectedSessionIndex = idx >= 0 ? idx : 0;
    } else {
      _selectedSessionIndex = 0;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 350));

    final coach = _state.verifiedCoaches[_selectedCoachIndex];
    final coachName = coach['name'] as String? ?? 'Coach Madhu';
    final coachHandle = coach['handle'] as String? ?? '@coach.madhu';

    final sessionName = _customAttachedSession ?? _sessionList[_selectedSessionIndex]['title']!;
    final topic = _commonTopics[_selectedTopicIndex];
    final questionText = _questionController.text.trim();

    _state.submitQuestion(
      coachName: coachName,
      coachHandle: coachHandle,
      topic: topic,
      question: questionText.isNotEmpty ? questionText : topic,
      session: sessionName,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sent to $coachName! Check "Coach Feedback" tab.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.navyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCoachSelectorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CoachSelectorModal(
        coaches: _state.verifiedCoaches,
        selectedIndex: _selectedCoachIndex,
        onSelected: (idx) {
          setState(() => _selectedCoachIndex = idx);
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
              // ── Top App Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.navyBlue,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask Coach',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Get technique advice from certified coaches',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 13, color: AppTheme.electricBlue),
                          SizedBox(width: 4),
                          Text(
                            'VERIFIED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.electricBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // ── Main Scrollable Form Body ─────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // ── STEP 1: Select Coach ────────────────────────────────
                    _buildSectionHeader(
                      step: '1',
                      title: 'CHOOSE COACH',
                      subtitle: 'Select the mentor you want feedback from',
                    ),
                    const SizedBox(height: 10),

                    // Selected Coach Card (Option 1: Modern & Scales to 100+ coaches)
                    Builder(
                      builder: (context) {
                        final currentCoach = _state.verifiedCoaches[_selectedCoachIndex];
                        final cName = currentCoach['name'] as String;
                        final isOnline = currentCoach['status'] == 'ONLINE NOW';

                        return GestureDetector(
                          onTap: _openCoachSelectorModal,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.electricBlue,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.electricBlue.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFD6E4F8), width: 1.5),
                                      ),
                                      child: ClipOval(
                                        child: (currentCoach['assetImage'] != null)
                                            ? Image.asset(
                                                currentCoach['assetImage'] as String,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  color: AppTheme.electricBlue,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    cName.replaceAll('Coach ', '')[0].toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: AppTheme.electricBlue,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  cName.replaceAll('Coach ', '')[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 11,
                                        height: 11,
                                        decoration: BoxDecoration(
                                          color: isOnline
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF3B82F6),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              cName,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w900,
                                                color: AppTheme.navyBlue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified_rounded, size: 15, color: AppTheme.electricBlue),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${currentCoach['spec'] ?? currentCoach['role']} • ${currentCoach['experience'] ?? '10+ Yrs'}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                          const SizedBox(width: 3),
                                          Text(
                                            currentCoach['rating'] as String? ?? '★ 4.9',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.navyBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.swap_horiz_rounded, size: 15, color: AppTheme.electricBlue),
                                      SizedBox(width: 4),
                                      Text(
                                        'Change',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.electricBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // ── STEP 2: Attached Session ────────────────────────────
                    _buildSectionHeader(
                      step: '2',
                      title: 'ATTACHED PRACTICE SESSION',
                      subtitle: 'Coach will review the video clip & speed data',
                    ),
                    const SizedBox(height: 10),

                    if (_customAttachedSession != null)
                      // Highlighted card when coming from Session or Video page
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF93C5FD), width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.electricBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _customAttachedSession!,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.navyBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, size: 13, color: AppTheme.electricBlue),
                                      SizedBox(width: 4),
                                      Text(
                                        'Video clip & ball speed attached',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.electricBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _customAttachedSession = null),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Choose from recent sessions
                      Column(
                        children: List.generate(_sessionList.length, (idx) {
                          final s = _sessionList[idx];
                          final isSel = _selectedSessionIndex == idx;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedSessionIndex = idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFEFF6FF) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                                  width: isSel ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    size: 20,
                                    color: isSel ? AppTheme.electricBlue : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['title']!,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                                            color: isSel ? AppTheme.navyBlue : const Color(0xFF334155),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          s['detail']!,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                    const SizedBox(height: 22),

                    // ── STEP 3: Topic ────────────────────────────────────────
                    _buildSectionHeader(
                      step: '3',
                      title: 'WHAT DO YOU WANT TO IMPROVE?',
                      subtitle: 'Choose your main focus area',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_commonTopics.length, (idx) {
                        final isSel = _selectedTopicIndex == idx;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTopicIndex = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                                width: isSel ? 1.6 : 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSel
                                      ? AppTheme.electricBlue.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              _commonTopics[idx],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                color: isSel ? AppTheme.electricBlue : AppTheme.navyBlue,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 22),

                    // ── STEP 4: Optional Question ────────────────────────────
                    _buildSectionHeader(
                      step: '4',
                      title: 'YOUR QUESTION (OPTIONAL)',
                      subtitle: 'Type your doubt or tap a quick chip below',
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _questionController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.navyBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. How to stop edging outswingers on front foot?',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Quick suggestion chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickDoubtChips.map((chip) {
                          return GestureDetector(
                            onTap: () {
                              _questionController.text = chip;
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                '+ $chip',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Submit CTA Button ────────────────────────────────────
                    HexgenButton(
                      text: _isSubmitting ? 'SENDING TO COACH...' : 'SEND TO COACH ⚡',
                      icon: _isSubmitting ? null : Icons.send_rounded,
                      onPressed: _isSubmitting ? null : _submit,
                    ),

                    const SizedBox(height: 12),

                    // Bottom info label
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text(
                            'Coach reviews usually arrive within 2-4 hours',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String step,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppTheme.navyBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Search & Filter Modal for 100+ Coaches (Option 1) ────────────────────────
class _CoachSelectorModal extends StatefulWidget {
  final List<Map<String, dynamic>> coaches;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CoachSelectorModal({
    required this.coaches,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<_CoachSelectorModal> createState() => _CoachSelectorModalState();
}

class _CoachSelectorModalState extends State<_CoachSelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    '🏏 Batting',
    '⚡ Pace Bowling',
    '🌀 Spin',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCoaches {
    final query = _searchController.text.trim().toLowerCase();
    return widget.coaches.where((coach) {
      final name = (coach['name'] as String? ?? '').toLowerCase();
      final spec = (coach['spec'] as String? ?? '').toLowerCase();
      final role = (coach['role'] as String? ?? '').toLowerCase();

      // Category check
      if (_selectedCategory == '🏏 Batting' && !spec.contains('batting') && !role.contains('batting')) {
        return false;
      }
      if (_selectedCategory == '⚡ Pace Bowling' &&
          !spec.contains('pace') &&
          !spec.contains('fast') &&
          !spec.contains('seam') &&
          !role.contains('pace') &&
          !role.contains('fast')) {
        return false;
      }
      if (_selectedCategory == '🌀 Spin' && !spec.contains('spin') && !role.contains('spin')) {
        return false;
      }

      // Query check
      if (query.isNotEmpty) {
        return name.contains(query) || spec.contains(query) || role.contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filtered = _filteredCoaches;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Coach',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Choose a mentor for your technique review',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13, color: AppTheme.navyBlue),
                    decoration: const InputDecoration(
                      hintText: 'Search by coach name or specialty...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.navyBlue : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? AppTheme.navyBlue : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Coach List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 10),
                        const Text(
                          'No coaches found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try clearing your search or category filter',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _selectedCategory = 'All');
                          },
                          child: const Text('Reset Search', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.electricBlue)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final coach = filtered[i];
                      final origIdx = widget.coaches.indexOf(coach);
                      final isSelected = origIdx == widget.selectedIndex;
                      final cName = coach['name'] as String;

                      return GestureDetector(
                        onTap: () {
                          widget.onSelected(origIdx);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.6 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFD6E4F8), width: 1.5),
                                    ),
                                    child: ClipOval(
                                      child: (coach['assetImage'] != null)
                                          ? Image.asset(
                                              coach['assetImage'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: isSelected ? AppTheme.electricBlue : const Color(0xFF94A3B8),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  cName.replaceAll('Coach ', '')[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: isSelected ? AppTheme.electricBlue : const Color(0xFF94A3B8),
                                              alignment: Alignment.center,
                                              child: Text(
                                                cName.replaceAll('Coach ', '')[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: coach['status'] == 'ONLINE NOW'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF3B82F6),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          cName,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                            color: isSelected ? AppTheme.electricBlue : AppTheme.navyBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified_rounded, size: 14, color: AppTheme.electricBlue),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${coach['spec'] ?? coach['role']} • ${coach['experience'] ?? '10+ Yrs'}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 3),
                                        Text(
                                          coach['rating'] as String? ?? '★ 4.9',
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.navyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? AppTheme.electricBlue : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
