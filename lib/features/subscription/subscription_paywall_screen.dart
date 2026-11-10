import 'package:flutter/material.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../../core/widgets/hexgen_badge.dart';

class SubscriptionPaywallScreen extends StatelessWidget {
  final VoidCallback onSuccess;

  const SubscriptionPaywallScreen({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexgenColors.iceBlue,
      appBar: AppBar(
        title: const Text('PRO PASS UNLOCK'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pro Badge & Crown
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: HexgenColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: HexgenColors.buttonGlow(opacity: 0.3),
                  ),
                  child: const Center(
                    child: Icon(Icons.workspace_premium_rounded, size: 46, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: HexgenBadge(
                  label: 'HEXGEN ATHLETE SEASON PASS',
                  variant: HexgenBadgeVariant.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unlock Full Telemetry & Match Logs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: HexgenColors.navyBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Level up your game with AI stroke analytics, 4K multi-angle replays, and direct mentor drills.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: HexgenColors.slateBlue,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Feature List Card
              HexgenCard(
                hasGlow: true,
                hasTopAccent: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildBenefitRow(Icons.videocam_rounded, 'Multi-Angle 4K Replays', 'Smart court sensors capture every smash & rally'),
                    const Divider(height: 20),
                    _buildBenefitRow(Icons.insights_rounded, 'AI Telemetry & Speed Radar', 'Smash velocity, split-step recovery & stamina analysis'),
                    const Divider(height: 20),
                    _buildBenefitRow(Icons.sports_score_rounded, 'Full Match Logs & Drill History', 'Unlimited access to all past sessions and match archives'),
                    const Divider(height: 20),
                    _buildBenefitRow(Icons.verified_user_rounded, 'Direct Coach Drill Plans', 'Certified mentors review footage and assign drills'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Price & Plan Details Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: HexgenColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HexgenColors.lightBlue),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRO MONTHLY PASS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: HexgenColors.navyBlue)),
                        Text('Cancel anytime • 7-day guarantee', style: TextStyle(fontSize: 11, color: HexgenColors.slateBlue)),
                      ],
                    ),
                    Text('₹499/mo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: HexgenColors.electricBlue)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              HexgenButton(
                text: 'READY. SET. BAT • UNLOCK PRO',
                icon: Icons.flash_on_rounded,
                onPressed: () {
                  onSuccess();
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CONTINUE ON FREE PASS',
                    style: TextStyle(
                      color: HexgenColors.slateBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
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

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: HexgenColors.iceBlue,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HexgenColors.lightBlue, width: 1),
          ),
          child: Icon(icon, color: HexgenColors.electricBlue, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: HexgenColors.navyBlue),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: HexgenColors.slateBlue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
