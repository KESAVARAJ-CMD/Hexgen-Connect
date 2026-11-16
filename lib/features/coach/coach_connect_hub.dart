import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../models/pose_data.dart';
import '../../services/demo_state.dart';
import '../../widgets/skeleton_painter.dart';
import 'view_coach_profile_screen.dart';
import 'coach_feedback_screen.dart';
import 'coach_chat_screen.dart';

class CoachConnectHub extends StatefulWidget {
  final bool showBackButton;
  const CoachConnectHub({super.key, this.showBackButton = true});

  @override
  State<CoachConnectHub> createState() => _CoachConnectHubState();
}

class _CoachConnectHubState extends State<CoachConnectHub> {
  final DemoState _state = DemoState();
  int _selectedTab = 0; // 0: Coaches List, 1: Coach Feedback
  final TextEditingController _handleController = TextEditingController();
  String _searchHandle = '';

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _handleController.dispose();
    super.dispose();
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    int? count,
    bool isDark = false,
  }) {
    final isSel = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isDark ? null : (isSel ? AppTheme.primaryCtaGradient : null),
            color: isDark ? (isSel ? Colors.white : Colors.transparent) : null,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? (isSel ? AppTheme.navyBlue : Colors.white)
                        : (isSel ? Colors.white : AppTheme.navyBlue),
                    letterSpacing: 0.3,
                  ),
                ),
                if (count != null && count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSel
                          ? (isDark ? AppTheme.electricBlue : Colors.white)
                          : AppTheme.electricBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isSel
                            ? (isDark ? Colors.white : AppTheme.electricBlue)
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _state.allReviews.where((r) => r['status'] == 'PENDING').length;

    final Widget content = Column(
      children: [
        // Header Selector (Rendered on iceBlue when embedded, or inside Dark Canopy when standalone)
        if (!widget.showBackButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navyBlue.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTabButton(index: 0, label: 'COACHES'),
                  _buildTabButton(index: 1, label: 'REQUESTS', count: pendingCount),
                  _buildTabButton(index: 2, label: 'FEEDBACK'),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryCtaGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'HEXGEN CONNECT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // 3-Tab Segmented Selector
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(index: 0, label: 'COACHES', isDark: true),
                          _buildTabButton(index: 1, label: 'REQUESTS', count: pendingCount, isDark: true),
                          _buildTabButton(index: 2, label: 'FEEDBACK', isDark: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Body Content based on selected tab (0: Coaches, 1: Requests, 2: Feedback)
        Expanded(
          child: _selectedTab == 0
              ? _buildCoachesListTab()
              : _selectedTab == 1
                  ? _buildRequestsTab()
                  : _buildCoachFeedbackTab(),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.showBackButton ? CyberGlassBackdrop(child: content) : content,
    );
  }

  Widget _buildCoachesListTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        // Search Box
        Container(
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
            boxShadow: HexgenColors.cardShadow(opacity: 0.06),
          ),
          child: TextField(
            controller: _handleController,
            onChanged: (v) => setState(() => _searchHandle = v),
            style: const TextStyle(color: AppTheme.navyBlue, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Search Coach ID e.g. @coach.madhu...',
              hintStyle: TextStyle(color: AppTheme.slateBlue, fontSize: 12),
              prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.electricBlue, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'AVAILABLE COACHES',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            letterSpacing: 0.8,
            
          ),
        ),

        const SizedBox(height: 12),

        // Directory List
        Builder(
          builder: (context) {
            final filtered = _state.verifiedCoaches.where((c) {
              final h = (c['handle'] as String).toLowerCase();
              final n = (c['name'] as String).toLowerCase();
              final q = _searchHandle.toLowerCase();
              return h.contains(q) || n.contains(q);
            }).toList();

            if (filtered.isEmpty) {
              return HexgenCard(
                padding: const EdgeInsets.all(32),
                child: const Center(
                  child: Text(
                    'NO VERIFIED COACH FOUND WITH THAT HANDLE',
                    style: TextStyle(
                      color: AppTheme.slateBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: filtered.map((coach) {
                final String cName = coach['name'] as String;
                final String initials = cName.replaceAll('Coach ', '').substring(0, 1).toUpperCase();
                final String? assetPath = coach['assetImage'] as String?;
                final String role = coach['role'] ?? 'Cricket Coach';
                final String rating = coach['rating'] ?? '★ 4.9';
                final String responseTime = coach['responseTime'] ?? '⚡ Replies quickly';
                final String pricing = coach['pricing'] ?? '₹499 / session';
                final bool isOnline = coach['status'] == 'ONLINE NOW';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: HexgenCard(
                    hasGlow: true,
                    hasTopAccent: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coach Header Row with Realistic Photo Avatar
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewCoachProfileScreen(coach: coach),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFD6E4F8), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: assetPath != null
                                          ? Image.asset(
                                              assetPath,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppTheme.electricBlue,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: AppTheme.electricBlue,
                                              alignment: Alignment.center,
                                              child: Text(
                                                initials,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Green Active / Online indicator
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
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
                                              color: AppTheme.navyBlue,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: Color(0xFF0052FF),
                                          size: 15,
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            rating,
                                            style: const TextStyle(
                                              color: Color(0xFFB45309),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      role,
                                      style: const TextStyle(
                                        color: AppTheme.slateBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${coach['handle']} • ${coach['experience']}',
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Info Pill Badges (Response time & pricing)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFDCFCE7)),
                              ),
                              child: Text(
                                responseTime,
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              pricing,
                              style: const TextStyle(
                                color: AppTheme.navyBlue,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Dual Action Buttons: Chat (WhatsApp Style) & Profile
                        Row(
                          children: [
                            // 1. WhatsApp-Style Direct Chat Button
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () {
                                  CoachChatScreen.open(context, coach: coach);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryCtaGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0052FF).withValues(alpha: 0.22),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'CHAT (DM)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 2. View Profile Button
                            Expanded(
                              flex: 2,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewCoachProfileScreen(coach: coach),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  backgroundColor: const Color(0xFFF8FAFC),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.navyBlue),
                                    SizedBox(width: 4),
                                    Text(
                                      'BIO',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.navyBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ── TAB 1: SUBMITTED REQUESTS (Waiting for Coach) ─────────────────────────
  Widget _buildRequestsTab() {
    final requests = _state.allReviews
        .where((r) => r['status'] == 'PENDING')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        // Header info banner
        HexgenCard(
          hasGlow: true,
          hasTopAccent: true,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorderColor),
                ),
                child: const Icon(Icons.schedule_send_rounded, color: AppTheme.electricBlue, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUBMITTED REVIEW REQUESTS',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Questions & video clips sent to coach awaiting review.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),
              HexgenBadge(
                label: '${requests.length} PENDING',
                variant: HexgenBadgeVariant.volt,
                fontSize: 8.5,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (requests.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_chat_unread_outlined,
                      size: 42,
                      color: AppTheme.electricBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Active Requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'When you ask a coach about a session or delivery, your question and clip will appear here while waiting for review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...requests.map((r) {
            final String cName = r['coachName'] ?? 'Coach';
            final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: HexgenCard(
                hasGlow: true,
                hasTopAccent: true,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Coach info + PENDING badge
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.electricBlue,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
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
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, size: 14, color: AppTheme.electricBlue),
                                ],
                              ),
                              Text(
                                r['coachHandle'] ?? '',
                                style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.hourglass_top_rounded, size: 11, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text(
                                'PENDING',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFD97706),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Attached Session Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam_rounded, size: 15, color: AppTheme.electricBlue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r['session'] ?? 'Session Attached',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.navyBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Topic & Question
                    if (r['topic'] != null) ...[
                      Text(
                        r['topic'] as String,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.electricBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      r['question'] ?? r['focus'] ?? 'Awaiting Coach Review',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.navyBlue,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),

                    // Bottom: Sent time + Estimated turnaround
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: AppTheme.slateBlue),
                            const SizedBox(width: 4),
                            Text(
                              r['date'] ?? 'Just now',
                              style: const TextStyle(fontSize: 10, color: AppTheme.slateBlue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 14, color: AppTheme.electricBlue),
                            SizedBox(width: 2),
                            Text(
                              'Reply expected in 2-4 hrs',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.electricBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── TAB 2: COMPLETED COACH FEEDBACK & DRILLS ──────────────────────────────
  Widget _buildCoachFeedbackTab() {
    final reviews = _state.allReviews
        .where((r) => r['status'] == 'PUBLISHED')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        // Header info banner
        HexgenCard(
          hasGlow: true,
          hasTopAccent: true,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLETED COACH REVIEWS',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap any review to view drills, posture HUD & voice notes.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),
              HexgenBadge(
                label: '${reviews.length} COMPLETED',
                variant: HexgenBadgeVariant.volt,
                fontSize: 8.5,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 42, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text(
                    'No Coach Feedback Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Once a coach reviews your submitted request, their technique report and drills will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          )
        else
          ...reviews.map((r) {
            final String cName = r['coachName'] ?? 'Coach';
            final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: HexgenCard(
                hasGlow: true,
                hasTopAccent: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoachFeedbackScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.electricBlue,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.navyBlue)),
                              Text('${r['coachHandle']} • ${r['session']}', style: const TextStyle(fontSize: 10.5, color: AppTheme.slateBlue)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Text(
                            'PUBLISHED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      r['focus'] ?? '',
                      style: const TextStyle(fontSize: 12, color: AppTheme.navyBlue, height: 1.4, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (r['drill'] != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center_rounded, size: 14, color: AppTheme.electricBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Drill: ${r['drill']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.navyBlue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r['date'] ?? '', style: const TextStyle(fontSize: 9.5, color: AppTheme.slateBlue, fontWeight: FontWeight.bold)),
                        const Row(
                          children: [
                            Text('Open Report', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.electricBlue)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.electricBlue),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// QUEUING & PIPELINE CONNECTING SCREEN
class CoachQueueScreen extends StatefulWidget {
  final Map<String, dynamic> coach;
  const CoachQueueScreen({super.key, required this.coach});

  @override
  State<CoachQueueScreen> createState() => _CoachQueueScreenState();
}

class _CoachQueueScreenState extends State<CoachQueueScreen> {
  int _step = 0;
  final List<String> _steps = [
    'QUEUING IN NEURAL LINE...',
    'PROCESSING SESSION METRICS...',
    'ESTABLISHING SECURE LINK...',
    'LINK ESTABLISHED! CONNECTING...'
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPipeline();
  }

  void _startPipeline() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      if (_step < _steps.length - 1) {
        setState(() => _step++);
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LiveCoachVideoCallScreen(coach: widget.coach)),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String cName = widget.coach['name'] as String;
    final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120, height: 120,
                    child: CircularProgressIndicator(
                      value: (_step + 1) / _steps.length,
                      strokeWidth: 4,
                      color: AppTheme.electricBlue,
                      backgroundColor: AppTheme.lightBlue,
                    ),
                  ),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppTheme.electricBlue,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                cName,
                style: const TextStyle(color: AppTheme.navyBlue, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.coach['handle']} • ${widget.coach['role']}',
                style: const TextStyle(color: AppTheme.slateBlue, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 36),

              HexgenBadge(
                label: _steps[_step],
                variant: HexgenBadgeVariant.primary,
                fontSize: 11,
              ),

              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL REQUEST',
                  style: TextStyle(color: AppTheme.slateBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// LIVE VIDEO CALL WITH COACH
class LiveCoachVideoCallScreen extends StatefulWidget {
  final Map<String, dynamic> coach;
  const LiveCoachVideoCallScreen({super.key, required this.coach});

  @override
  State<LiveCoachVideoCallScreen> createState() => _LiveCoachVideoCallScreenState();
}

class _LiveCoachVideoCallScreenState extends State<LiveCoachVideoCallScreen> {
  bool _isMuted = false;
  bool _isCamOn = true;

  final Map<String, Keypoint> _mockKeypoints = const {
    'nose': Keypoint(x: .5, y: .16, z: 0, score: .95),
    'l_shoulder': Keypoint(x: .43, y: .28, z: 0, score: .95),
    'r_shoulder': Keypoint(x: .57, y: .28, z: 0, score: .95),
    'l_elbow': Keypoint(x: .34, y: .42, z: 0, score: .9),
    'r_elbow': Keypoint(x: .66, y: .42, z: 0, score: .9),
    'l_wrist': Keypoint(x: .3, y: .54, z: 0, score: .9),
    'r_wrist': Keypoint(x: .7, y: .54, z: 0, score: .9),
    'l_hip': Keypoint(x: .46, y: .53, z: 0, score: .95),
    'r_hip': Keypoint(x: .54, y: .53, z: 0, score: .95),
    'l_knee': Keypoint(x: .44, y: .68, z: 0, score: .9),
    'r_knee': Keypoint(x: .56, y: .68, z: 0, score: .9),
    'l_ankle': Keypoint(x: .42, y: .84, z: 0, score: .9),
    'r_ankle': Keypoint(x: .58, y: .84, z: 0, score: .9),
    'l_heel': Keypoint(x: .4, y: .86, z: 0, score: .9),
    'r_heel': Keypoint(x: .56, y: .86, z: 0, score: .9),
    'l_foot': Keypoint(x: .34, y: .87, z: 0, score: .9),
    'r_foot': Keypoint(x: .64, y: .87, z: 0, score: .9),
  };

  @override
  Widget build(BuildContext context) {
    final String cName = widget.coach['name'] as String;
    final String initials = cName.replaceAll('Coach ', '')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.iceBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: AppTheme.navyBlue,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.sports_cricket_rounded,
                      size: 100,
                      color: AppTheme.cyanBlue.withValues(alpha: 0.4),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SkeletonPainter(keypoints: _mockKeypoints, color: HexgenColors.voltGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fiber_manual_record_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 6),
                          Text(
                            'LIVE REVIEW • 02:45',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 90, height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.electricBlue, width: 2),
                        boxShadow: HexgenColors.cardShadow(opacity: 0.2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            initials,
                            style: const TextStyle(color: AppTheme.navyBlue, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          Positioned(
                            bottom: 6, left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.navyBlue, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                cName.split(' ')[0],
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18, right: 18, bottom: 20,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HexgenCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.record_voice_over_rounded, color: HexgenColors.voltGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(widget.coach['handle'] as String).toUpperCase()} AUDIO FEED',
                                style: const TextStyle(color: AppTheme.electricBlue, fontSize: 9, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '"Watch your front shoulder on release. Keep your head centered over ball line."',
                                style: TextStyle(color: AppTheme.navyBlue, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                      boxShadow: HexgenColors.cardShadow(opacity: 0.15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded, color: AppTheme.navyBlue),
                          onPressed: () => setState(() => _isMuted = !_isMuted),
                        ),
                        IconButton(
                          icon: Icon(_isCamOn ? Icons.videocam_rounded : Icons.videocam_off_rounded, color: AppTheme.navyBlue),
                          onPressed: () => setState(() => _isCamOn = !_isCamOn),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session ended. Feedback saved to Dashboard.')));
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.call_end_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'END LINK',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
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
          ),
        ],
      ),
    );
  }
}

// ── Coach 1-on-1 Booking Bottom Sheet Modal ──────────────────────────────────
class _CoachBookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> coach;
  const _CoachBookingBottomSheet({required this.coach});

  @override
  State<_CoachBookingBottomSheet> createState() => _CoachBookingBottomSheetState();
}

class _CoachBookingBottomSheetState extends State<_CoachBookingBottomSheet> {
  int _selectedTopicIndex = 0;
  int _selectedSessionIndex = 0;
  int _selectedResponseFormat = 0;
  bool _isSubmitting = false;
  final TextEditingController _doubtController = TextEditingController();

  final List<Map<String, String>> _topicOptions = const [
    {
      'title': '🏏 Batting Shot Correction',
      'desc': 'Cover drive, pull shot, straight drive & edging issues',
    },
    {
      'title': '⚡ Bat Speed & Power Hitting',
      'desc': 'Swing speed, clearing the 30-yard/boundary & timing',
    },
    {
      'title': '🦶 Footwork & Head Stability',
      'desc': 'Front foot reach, balance & keeping head still',
    },
    {
      'title': '🎯 Fast Bowling Pace & Seam',
      'desc': 'Wrist snap, run-up rhythm & seam alignment',
    },
    {
      'title': '🌀 Spin Bowling & Turn Variations',
      'desc': 'Grip, release flight, revs & landing on good length',
    },
    {
      'title': '📹 Review Recorded Session Video',
      'desc': 'Frame-by-frame biomechanics critique of your overs',
    },
  ];

  final List<String> _sessionOptions = const [
    'Session 3 • Cover Drive Practice (3 Overs)',
    'Session 2 • Pace Attack & Line (2 Overs)',
    'Session 1 • Front-Foot Balance (4 Overs)',
    'No Video (General Cricket Question)',
  ];

  final List<String> _quickChips = const [
    'Edging outswing balls',
    'Bat turning in hand',
    'Head falling over off-side',
    'Front foot reaching too early',
    'Bowling arm dropping early',
  ];

  @override
  void dispose() {
    _doubtController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 350));
    final coachName = widget.coach['name'] as String? ?? 'Coach Madhu';
    final coachHandle = widget.coach['handle'] as String? ?? '@coach.madhu';
    final topic = _topicOptions[_selectedTopicIndex]['title']!;
    final session = _sessionOptions[_selectedSessionIndex];
    final questionText = _doubtController.text.trim();

    DemoState().submitQuestion(
      coachName: coachName,
      coachHandle: coachHandle,
      topic: topic,
      question: questionText,
      session: session,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context); // Close sheet

    // Show Confirmed Success Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Question Sent to Coach!',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                  
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.iceBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.electricBlue,
                        child: Text(
                          coachName.replaceAll('Coach ', '')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coachName,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.navyBlue),
                            ),
                            Text(
                              coachHandle,
                              style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  Text('• Topic: $topic', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.navyBlue)),
                  const SizedBox(height: 4),
                  Text('• Attached: $session', style: const TextStyle(fontSize: 11.5, color: AppTheme.electricBlue, fontWeight: FontWeight.w700)),
                  if (questionText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('• Doubt: "$questionText"', style: const TextStyle(fontSize: 11.5, color: AppTheme.slateBlue, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 8),
                  const Text('⏱️ Coach will analyze your video & telemetry and send feedback to the Feedback tab.', style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question submitted to Coach ⚡ Check Coach Feedback tab'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.navyBlue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.electricBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('GOT IT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coachName = widget.coach['name'] as String? ?? 'Coach Madhu';
    final coachRole = widget.coach['role'] as String? ?? 'Mentor';
    final coachRating = widget.coach['rating'] as String? ?? '4.9 ★';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.electricBlue,
                      child: Text(
                        coachName.replaceAll('Coach ', '')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask $coachName',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navyBlue),
                        ),
                        Text(
                          '$coachRole • $coachRating',
                          style: const TextStyle(fontSize: 11, color: AppTheme.slateBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.navyBlue, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. SELECT CRICKET TECHNIQUE TOPIC
            const Text(
              '1. WHAT DO YOU NEED GUIDANCE ON?',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            ...List.generate(_topicOptions.length, (idx) {
              final isSel = _selectedTopicIndex == idx;
              final opt = _topicOptions[idx];
              return GestureDetector(
                onTap: () => setState(() => _selectedTopicIndex = idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? AppTheme.electricBlue : AppTheme.cardBorderColor,
                      width: isSel ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 16,
                        color: isSel ? AppTheme.electricBlue : AppTheme.slateBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt['title']!,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w700,
                                color: AppTheme.navyBlue,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              opt['desc']!,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isSel ? AppTheme.electricBlue : AppTheme.slateBlue,
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

            const SizedBox(height: 14),

            // 2. ATTACH RECORDED SESSION (OPTIONAL)
            const Text(
              '2. ATTACH A SESSION / OVER (OPTIONAL)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_sessionOptions.length, (idx) {
                final isSel = _selectedSessionIndex == idx;
                final session = _sessionOptions[idx];
                return GestureDetector(
                  onTap: () => setState(() => _selectedSessionIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.electricBlue : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? AppTheme.electricBlue : AppTheme.cardBorderColor,
                      ),
                    ),
                    child: Text(
                      session,
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

            const SizedBox(height: 16),

            // 3. DESCRIBE YOUR CRICKET DOUBT
            const Text(
              '3. DESCRIBE YOUR SPECIFIC PROBLEM OR QUESTION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorderColor),
              ),
              child: TextField(
                controller: _doubtController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12.5, color: AppTheme.navyBlue),
                decoration: const InputDecoration(
                  hintText: 'e.g. My front foot reaches too early in cover drives and I keep getting caught at slips. How do I keep my head stable?',
                  hintStyle: TextStyle(fontSize: 11.5, color: AppTheme.slateBlue, height: 1.4),
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
                children: _quickChips.map((chip) {
                  return GestureDetector(
                    onTap: () {
                      final current = _doubtController.text.trim();
                      if (current.isEmpty) {
                        _doubtController.text = chip;
                      } else {
                        _doubtController.text = '$current, $chip';
                      }
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 12, color: AppTheme.electricBlue),
                          const SizedBox(width: 3),
                          Text(
                            chip,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.electricBlue),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 4. PREFERRED RESPONSE FORMAT
            const Text(
              '4. PREFERRED FEEDBACK FORMAT',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedResponseFormat = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _selectedResponseFormat == 0 ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedResponseFormat == 0 ? AppTheme.electricBlue : AppTheme.cardBorderColor,
                          width: _selectedResponseFormat == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🎙️ Voice & Video',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: _selectedResponseFormat == 0 ? AppTheme.electricBlue : AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('Detailed review', style: TextStyle(fontSize: 9.5, color: AppTheme.slateBlue)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedResponseFormat = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _selectedResponseFormat == 1 ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedResponseFormat == 1 ? AppTheme.electricBlue : AppTheme.cardBorderColor,
                          width: _selectedResponseFormat == 1 ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '💬 Text Notes',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: _selectedResponseFormat == 1 ? AppTheme.electricBlue : AppTheme.navyBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('Quick pointers', style: TextStyle(fontSize: 9.5, color: AppTheme.slateBlue)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CTA BUTTON
            HexgenButton(
              text: _isSubmitting ? 'SENDING QUESTION TO COACH...' : 'ASK COACH ⚡',
              icon: _isSubmitting ? null : Icons.send_rounded,
              onPressed: _isSubmitting ? null : _submitQuestion,
            ),
          ],
        ),
      ),
    );
  }
}
