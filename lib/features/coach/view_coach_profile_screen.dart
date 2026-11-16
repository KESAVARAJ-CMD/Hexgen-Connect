import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import 'ask_coach_screen.dart';
import 'coach_chat_screen.dart';

class ViewCoachProfileScreen extends StatelessWidget {
  final Map<String, dynamic> coach;
  const ViewCoachProfileScreen({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final String name = coach['name'] ?? 'Coach Madhu';
    final String handle = coach['handle'] ?? '@coach.madhu';
    final String spec = coach['spec'] ?? coach['role'] ?? 'Batting Biomechanics Specialist';
    final String exp = coach['exp'] ?? coach['experience'] ?? '10+ Yrs Coaching';
    final String rating = coach['rating'] ?? '★ 4.9 (184 reviews)';

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
                      child: Text(
                        'Coach Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navyBlue,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    // Verified Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'VERIFIED',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ───────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
                  children: [
                    // 1. Social Proof Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0), width: 0.9),
                      ),
                      child: const Row(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '18+ Athletes currently training with this coach this week',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Hero Coach Identity Card
                    _buildContainer(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with Realistic Asset Photo
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFD6E4F8), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0057FF).withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: coach['assetImage'] != null
                                          ? Image.asset(
                                              coach['assetImage'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: AppTheme.electricBlue,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  name.replaceAll('Coach ', '').substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: AppTheme.electricBlue,
                                              alignment: Alignment.center,
                                              child: Text(
                                                name.replaceAll('Coach ', '').substring(0, 1).toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.navyBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      handle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.electricBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 3),
                                        Text(
                                          rating,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.navyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Coach Philosophy Quote Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  '"Precision in posture brings power to your swing. Training is not about perfection — it is about measurable progress."',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '— Coaching Philosophy',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Quick Tags
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildPillTag(spec, const Color(0xFFEFF6FF), AppTheme.electricBlue),
                              _buildPillTag(exp, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                              _buildPillTag('BCCI Level 2', const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 3. About Coach (Credentials & Trust)
                    _buildSectionHeader('About $name', '👤'),
                    const SizedBox(height: 8),
                    _buildContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBulletPoint('Accreditation', 'BCCI Level 2 High Performance Certified Coach'),
                          const Divider(height: 16, color: Color(0xFFF1F5F9)),
                          _buildBulletPoint('Specialization', 'Batting Biomechanics, High Elbow Drive & Seam Alignment'),
                          const Divider(height: 16, color: Color(0xFFF1F5F9)),
                          _buildBulletPoint('Experience', '$exp • Former Ranji Trophy State Player'),
                          const Divider(height: 16, color: Color(0xFFF1F5F9)),
                          _buildBulletPoint('Proven Results', 'Athletes gain +14 km/h bat speed & 88% reduction in edge dismissals'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 4. About the Sessions (Schedule & Formats)
                    _buildSectionHeader('About the Sessions', '📖'),
                    const SizedBox(height: 8),
                    _buildContainer(
                      child: Column(
                        children: [
                          _buildSessionInfoRow(
                            Icons.calendar_today_rounded,
                            'Schedule',
                            'Monday - Saturday (06:00 AM - 08:30 PM)',
                          ),
                          const Divider(height: 18, color: Color(0xFFF1F5F9)),
                          _buildSessionInfoRow(
                            Icons.groups_rounded,
                            'Target Athletes',
                            'Juniors (U-16), Adults (20+) & Pro Athletes',
                          ),
                          const Divider(height: 18, color: Color(0xFFF1F5F9)),
                          _buildSessionInfoRow(
                            Icons.sports_cricket_rounded,
                            'Format',
                            'AI Over Video Analysis, 1-on-1 Net Practice & Remote Telemetry Sync',
                          ),
                          const Divider(height: 18, color: Color(0xFFF1F5F9)),
                          _buildSessionInfoRow(
                            Icons.location_on_outlined,
                            'Location',
                            'Hexgen Turf, Net Lane 2 & 3 • Cloud Review',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 5. Awards & Recognitions
                    _buildSectionHeader('Awards & Recognitions', '🎓'),
                    const SizedBox(height: 8),
                    _buildContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Center(
                                  child: Text('🏅', style: TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Certified High Performance Coach',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.navyBlue,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'BCCI Level 2 & NIS Sports Science Board',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '• 10+ Years mentoring junior & state-level athletes\n• Advanced Video Biomechanics Accreditation\n• Former Ranji Trophy Squad Member',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Ask Coach Action Card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
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
                                  color: AppTheme.iceBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.forum_outlined, size: 16, color: AppTheme.electricBlue),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Get Technique Advice from $name',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Send a video clip or ask a technical doubt about batting shots, bowling mechanics, or footwork.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // WhatsApp Direct DM Button
                          GestureDetector(
                            onTap: () {
                              CoachChatScreen.open(context, coach: coach);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'CHAT WITH COACH (DM) 💬',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Secondary: Submit Drill for Formal Review
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.videocam_outlined, size: 16, color: AppTheme.electricBlue),
                              label: const Text(
                                'SUBMIT DRILL VIDEO FOR REVIEW',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.electricBlue,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                backgroundColor: const Color(0xFFF0F7FF),
                              ),
                              onPressed: () {
                                AskCoachScreen.open(
                                  context,
                                  initialCoach: coach,
                                );
                              },
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

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPillTag(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppTheme.electricBlue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
