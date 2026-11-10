import 'package:flutter/material.dart';
import '../theme/hexgen_colors.dart';

/// Telemetry Stat Widget — clean, Roboto, no over-bold
class HexgenStatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const HexgenStatBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = HexgenColors.electricBlue,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: HexgenColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HexgenColors.cardBorderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: HexgenColors.navyBlue.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + trend badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: HexgenColors.iceBlue,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: HexgenColors.lightBlue, width: 0.8),
                      ),
                      child: Icon(icon, size: 17, color: iconColor),
                    ),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPositiveTrend ? const Color(0xFFE8F7F0) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          trend!,
                          style: tt.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isPositiveTrend ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Value (big number)
                Text(
                  value,
                  style: tt.titleLarge?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: HexgenColors.navyBlue,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Label
                Text(
                  title.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: HexgenColors.slateBlue,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
