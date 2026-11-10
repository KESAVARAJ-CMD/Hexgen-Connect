import 'package:flutter/material.dart';
import '../theme/hexgen_colors.dart';

/// Elite Athlete Hero Card — Gradient Top Section of Dashboard
class HexgenHeroCard extends StatelessWidget {
  final String playerName;
  final String playerId;
  final bool isSubscribed;
  final VoidCallback onBookTap;
  final VoidCallback onHistoryTap;
  final int playerLevel;
  final int currentXp;
  final int maxXp;
  final int ovrRating;

  const HexgenHeroCard({
    super.key,
    required this.playerName,
    required this.playerId,
    required this.isSubscribed,
    required this.onBookTap,
    required this.onHistoryTap,
    this.playerLevel = 14,
    this.currentXp = 3450,
    this.maxXp = 4000,
    this.ovrRating = 88,
  });

  static const _fontFamily = 'Roboto';

  @override
  Widget build(BuildContext context) {
    final double xpProgress = (currentXp / maxXp).clamp(0.0, 1.0);
    final initial = playerName.isNotEmpty ? playerName[0].toUpperCase() : 'A';

    return Container(
      decoration: BoxDecoration(
        gradient: HexgenColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HexgenColors.royalBlue.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HexgenColors.cyanBlue.withValues(alpha: 0.15),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row: Level badge + OVR chip ───────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Level + Tier pills
                    Row(
                      children: [
                        _glassPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 13, color: Colors.amberAccent),
                              const SizedBox(width: 4),
                              Text(
                                'LVL $playerLevel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  fontFamily: _fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _glassPill(
                          child: Text(
                            isSubscribed ? 'PRO PASS' : 'FREE TIER',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              fontFamily: _fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // OVR chip (white solid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'OVR',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: HexgenColors.slateBlue,
                              letterSpacing: 0.6,
                              fontFamily: _fontFamily,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$ovrRating',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: HexgenColors.navyBlue,
                              fontFamily: _fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Player Identity ────────────────────────────────────
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: HexgenColors.navyBlue,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: _fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + ID row
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              fontFamily: _fontFamily,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: HexgenColors.cyanBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '$playerId • SENSOR ONLINE',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                    fontFamily: _fontFamily,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── XP Progress Bar ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TELEMETRY XP SYNC',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontFamily: _fontFamily,
                      ),
                    ),
                    Text(
                      '$currentXp / $maxXp XP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 5, color: Colors.white.withValues(alpha: 0.22)),
                      FractionallySizedBox(
                        widthFactor: xpProgress,
                        child: Container(
                          height: 5,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, HexgenColors.cyanBlue],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Action Buttons: BOOK SLOT | PLAYER LOGS ───────────
                Row(
                  children: [
                    // BOOK SLOT (solid white)
                    Expanded(
                      child: _ctaButton(
                        icon: Icons.calendar_today_rounded,
                        label: 'BOOK SLOT',
                        iconColor: HexgenColors.electricBlue,
                        textColor: HexgenColors.navyBlue,
                        bgColor: Colors.white,
                        borderColor: Colors.transparent,
                        onTap: onBookTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // PLAYER LOGS (glass)
                    Expanded(
                      child: _ctaButton(
                        icon: isSubscribed ? Icons.analytics_outlined : Icons.lock_outline_rounded,
                        label: 'PLAYER LOGS',
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        bgColor: Colors.white.withValues(alpha: 0.15),
                        borderColor: Colors.white.withValues(alpha: 0.4),
                        onTap: onHistoryTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: child,
    );
  }

  Widget _ctaButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Ink(
          height: 46,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: bgColor == Colors.white
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  letterSpacing: 0.5,
                  fontFamily: _fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
