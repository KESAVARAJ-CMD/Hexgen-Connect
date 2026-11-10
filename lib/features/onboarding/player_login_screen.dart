import 'package:flutter/material.dart';
import '../../core/theme/hexgen_colors.dart';
import '../../core/widgets/cyber_glass_backdrop.dart';
import '../../core/widgets/hexgen_button.dart';
import '../../core/widgets/hexgen_card.dart';
import '../dashboard/player_dashboard_screen.dart';

class PlayerLoginScreen extends StatefulWidget {
  const PlayerLoginScreen({super.key});

  @override
  State<PlayerLoginScreen> createState() => _PlayerLoginScreenState();
}

class _PlayerLoginScreenState extends State<PlayerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerDashboardScreen(
            playerName: _nameController.text.trim(),
            playerId: _idController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ATHLETE ACCESS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: CyberGlassBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'LINK TELEMETRY PROFILE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: HexgenColors.navyBlue,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Access your real-time court booking integration, multi-angle telemetry, and AI drill progress.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: HexgenColors.slateBlue,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Name Field
                const Text(
                  'ATHLETE NAME',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HexgenColors.navyBlue, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                HexgenCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: HexgenColors.navyBlue),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person_rounded, color: HexgenColors.electricBlue, size: 20),
                      hintText: 'e.g. Alex Strike',
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter player name' : null,
                  ),
                ),

                const SizedBox(height: 16),

                // ID Field
                const Text(
                  'SENSOR TAG ID',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HexgenColors.navyBlue, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                HexgenCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: TextFormField(
                    controller: _idController,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: HexgenColors.electricBlue, letterSpacing: 1.0),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.badge_outlined, color: HexgenColors.royalBlue, size: 20),
                      hintText: 'HX-9821',
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter sensor tag ID' : null,
                  ),
                ),

                const SizedBox(height: 28),

                HexgenButton(
                  text: 'READY. SET. BAT • ENTER ARENA',
                  icon: Icons.sports_tennis_rounded,
                  onPressed: _onLogin,
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
