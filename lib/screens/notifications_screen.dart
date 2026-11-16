import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: false,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const SizedBox(width: 14),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Empty State Body ─────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFDBEAFE),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0057FF).withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 40,
                              color: AppTheme.electricBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Notifications Yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "You're all caught up! Updates regarding your sessions, slot bookings, and academy alerts will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                      ],
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
}
