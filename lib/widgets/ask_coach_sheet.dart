import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../services/demo_state.dart';

/// Clean, simple modal for asking a coach for guidance or review.
/// Can be opened from:
/// 1) Connect / Coaches tab (picks a coach first, optionally attaches a session)
/// 2) Sessions tab or Over Video player (session is already pre-attached!)
class AskCoachSheet extends StatefulWidget {
  final Map<String, dynamic>? initialCoach;
  final String? preAttachedSession;

  const AskCoachSheet({
    super.key,
    this.initialCoach,
    this.preAttachedSession,
  });

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? initialCoach,
    String? preAttachedSession,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AskCoachSheet(
          initialCoach: initialCoach,
          preAttachedSession: preAttachedSession,
        ),
      ),
    );
  }

  @override
  State<AskCoachSheet> createState() => _AskCoachSheetState();
}

class _AskCoachSheetState extends State<AskCoachSheet> {
  final DemoState _state = DemoState();
  late int _selectedCoachIndex;
  late int _selectedSessionIndex;
  int _selectedTopicIndex = 0;
  bool _isSubmitting = false;
  final TextEditingController _questionController = TextEditingController();

  final List<String> _sessionList = const [
    'Session 3 • Cover Drive Practice',
    'Session 2 • Fast Pace & Line',
    'Session 1 • Front Foot Defense',
    'No Session (General Cricket Doubt)',
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
  ];

  @override
  void initState() {
    super.initState();
    // 1. Pick initial coach
    if (widget.initialCoach != null) {
      final idx = _state.verifiedCoaches.indexWhere(
        (c) => c['handle'] == widget.initialCoach!['handle'],
      );
      _selectedCoachIndex = idx >= 0 ? idx : 0;
    } else {
      _selectedCoachIndex = 0;
    }

    // 2. Pick pre-attached session if provided
    if (widget.preAttachedSession != null) {
      final idx = _sessionList.indexWhere(
        (s) => s.toLowerCase().contains(widget.preAttachedSession!.toLowerCase()),
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
    await Future.delayed(const Duration(milliseconds: 300));

    final coach = _state.verifiedCoaches[_selectedCoachIndex];
    final coachName = coach['name'] as String? ?? 'Coach Madhu';
    final coachHandle = coach['handle'] as String? ?? '@coach.madhu';

    final sessionName = widget.preAttachedSession ?? _sessionList[_selectedSessionIndex];
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
        content: Text('Sent to $coachName! 🏏 View in Coach Feedback.'),
        backgroundColor: AppTheme.navyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
            const SizedBox(height: 14),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask a Coach',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Get technique advice on your batting or bowling',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── STEP 1: Select Coach ─────────────────────────────────────────
            const Text(
              '1. SELECT COACH',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_state.verifiedCoaches.length, (idx) {
                  final coach = _state.verifiedCoaches[idx];
                  final isSel = _selectedCoachIndex == idx;
                  final cName = coach['name'] as String;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCoachIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                          width: isSel ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isSel ? AppTheme.electricBlue : const Color(0xFF94A3B8),
                            child: Text(
                              cName.replaceAll('Coach ', '')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w700,
                                  color: isSel ? AppTheme.electricBlue : AppTheme.navyBlue,
                                ),
                              ),
                              Text(
                                coach['spec'] as String? ?? 'Specialist',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // ── STEP 2: Attached Session ─────────────────────────────────────
            const Text(
              '2. ATTACHED SESSION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.preAttachedSession != null)
              // Auto-attached from Session / Video page
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam_rounded, color: AppTheme.electricBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.preAttachedSession!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                            ),
                          ),
                          const Text(
                            'Video clip & ball details attached automatically',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppTheme.electricBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppTheme.electricBlue, size: 18),
                  ],
                ),
              )
            else
              // Pick from previous sessions
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_sessionList.length, (idx) {
                    final isSel = _selectedSessionIndex == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSessionIndex = idx),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.navyBlue : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppTheme.navyBlue : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          _sessionList[idx],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : AppTheme.navyBlue,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            const SizedBox(height: 16),

            // ── STEP 3: Topic ────────────────────────────────────────────────
            const Text(
              '3. WHAT DO YOU WANT TO IMPROVE?',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(_commonTopics.length, (idx) {
                final isSel = _selectedTopicIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTopicIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? AppTheme.electricBlue : const Color(0xFFE2E8F0),
                        width: isSel ? 1.4 : 1.0,
                      ),
                    ),
                    child: Text(
                      _commonTopics[idx],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                        color: isSel ? AppTheme.electricBlue : AppTheme.navyBlue,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── STEP 4: Optional Question ────────────────────────────────────
            const Text(
              '4. YOUR QUESTION (OPTIONAL)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _questionController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12.5, color: AppTheme.navyBlue),
                decoration: const InputDecoration(
                  hintText: 'Type your question e.g. How to stop edging outswingers?',
                  hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 8),

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
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+ $chip',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ── Submit CTA ───────────────────────────────────────────────────
            HexgenButton(
              text: _isSubmitting ? 'SENDING TO COACH...' : 'SEND TO COACH ⚡',
              icon: _isSubmitting ? null : Icons.send_rounded,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
