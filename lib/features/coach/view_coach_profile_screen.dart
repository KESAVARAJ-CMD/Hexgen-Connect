import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../core/widgets/hexgen_badge.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../services/demo_state.dart';

class ViewCoachProfileScreen extends StatelessWidget {
  final Map<String, dynamic> coach;
  const ViewCoachProfileScreen({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final String name = coach['name'] ?? 'Coach';
    final String handle = coach['handle'] ?? '@coach';
    final String spec = coach['spec'] ?? coach['role'] ?? 'Specialist';
    final String exp = coach['exp'] ?? coach['experience'] ?? '10+ Yrs Coaching';
    final String lang = coach['lang'] ?? 'English • Tamil • Hindi';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cardBorderColor,
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppTheme.navyBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Meet Your Coach',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  children: [
            HexgenCard(
              hasGlow: true,
              hasTopAccent: true,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.electricBlue.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        name.replaceFirst('Coach ', '').substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.electricBlue, fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(handle, style: const TextStyle(fontSize: 12, color: AppTheme.electricBlue, fontWeight: FontWeight.w900, fontFamily: 'Roboto')),
                      const SizedBox(width: 6),
                      const HexgenBadge(
                        label: 'VERIFIED',
                        variant: HexgenBadgeVariant.volt,
                        fontSize: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.navyBlue, fontFamily: 'Roboto'), textAlign: TextAlign.center),
                  Text(spec, style: const TextStyle(fontSize: 12, color: AppTheme.slateBlue, fontWeight: FontWeight.w600, fontFamily: 'Roboto'), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppTheme.cardBorderColor),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _metric('Experience', exp, Icons.access_time_rounded)),
                      Container(width: 1, height: 32, color: AppTheme.cardBorderColor),
                      Expanded(child: _metric('Languages', lang, Icons.language_rounded)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('COACHING APPROACH'),
            const SizedBox(height: 10),
            HexgenCard(
              padding: const EdgeInsets.all(18),
              child: const Text(
                'Encouraging, practical biomechanical feedback for every stage of your cricket journey. Every review connects an observation to an achievable next step.',
                style: TextStyle(fontSize: 13, color: AppTheme.navyBlue, height: 1.5, fontFamily: 'Roboto'),
              ),
            ),
            const SizedBox(height: 20),
            _sectionLabel('YOUR REVIEW INCLUDES'),
            const SizedBox(height: 10),
            _buildCheckList([
              'One session, up to 10 overs analysis',
              'Coach-reviewed technical feedback',
              'Custom practice drill assignment',
              'One clarification question'
            ]),
            const SizedBox(height: 28),
            HexgenButton(
              text: 'Choose $name',
              onPressed: () {
                DemoState().coachId = coach['id'] ?? 'madhu';
                DemoState().activeCoachName = name;
                DemoState().activeCoachHandle = handle;
                DemoState().save();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name selected as your coach.')));
              },
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

  Widget _metric(String l, String v, IconData i) {
    return Column(
      children: [
        Icon(i, color: AppTheme.electricBlue, size: 16),
        const SizedBox(height: 6),
        Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontFamily: 'Roboto'), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        Text(l, style: const TextStyle(fontSize: 9.5, color: AppTheme.slateBlue, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
      ],
    );
  }

  Widget _buildCheckList(List<String> items) {
    return Column(
      children: items.map((it) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: HexgenCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: HexgenColors.voltGreen, size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(it, style: const TextStyle(fontSize: 12.5, color: AppTheme.navyBlue, fontWeight: FontWeight.w600, fontFamily: 'Roboto'))),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 12, decoration: BoxDecoration(color: AppTheme.electricBlue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.slateBlue, letterSpacing: 1.2, fontFamily: 'Roboto')),
      ],
    );
  }
}
