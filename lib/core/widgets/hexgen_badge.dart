import 'package:flutter/material.dart';
import '../theme/hexgen_colors.dart';

enum HexgenBadgeVariant {
  primary,
  gold,
  volt,
  sky,
  neutral,
}

/// Tactical HUD Badge / Status Pill
class HexgenBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final HexgenBadgeVariant variant;
  final double fontSize;

  const HexgenBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = HexgenBadgeVariant.primary,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case HexgenBadgeVariant.primary:
        bg = HexgenColors.iceBlue;
        fg = HexgenColors.electricBlue;
        border = HexgenColors.lightBlue;
        break;
      case HexgenBadgeVariant.gold:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFC2410C);
        border = const Color(0xFFFED7AA);
        break;
      case HexgenBadgeVariant.volt:
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF15803D);
        border = const Color(0xFFBBF7D0);
        break;
      case HexgenBadgeVariant.sky:
        bg = HexgenColors.pureWhite.withValues(alpha: 0.25);
        fg = HexgenColors.pureWhite;
        border = HexgenColors.pureWhite.withValues(alpha: 0.4);
        break;
      case HexgenBadgeVariant.neutral:
        bg = const Color(0xFFF1F5F9);
        fg = HexgenColors.slateBlue;
        border = const Color(0xFFE2E8F0);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
