import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Hexgen Connect One6 Premium Light Gaming Palette
class HexgenColors {
  HexgenColors._();

  static const Color electricBlue = AppTheme.electricBlue;
  static const Color royalBlue = AppTheme.royalBlue;
  static const Color skyBlue = AppTheme.skyBlue;
  static const Color cyanBlue = AppTheme.cyanBlue;
  static const Color lightBlue = AppTheme.lightBlue;
  static const Color iceBlue = AppTheme.iceBlue;
  static const Color pureWhite = AppTheme.pureWhite;
  static const Color navyBlue = AppTheme.navyBlue;
  static const Color slateBlue = AppTheme.slateBlue;
  static const Color cardBorderColor = AppTheme.cardBorderColor;
  static const Color cardBorder = cardBorderColor;
  static const Color dotUnselected = AppTheme.dotUnselected;

  // Status & Telemetry
  static const Color voltGreen = Color(0xFF10B981);
  static const Color cyberAmber = Color(0xFFFF9F0A);
  static const Color neonPink = Color(0xFFFF2D55);

  // Gradients
  static const LinearGradient primaryGradient = AppTheme.primaryCtaGradient;
  static const LinearGradient heroGradient = AppTheme.brandAccentGradient;
  static const LinearGradient backgroundGradient = AppTheme.backgroundGradient;

  static List<BoxShadow> buttonGlow({double opacity = 0.32}) => [
        BoxShadow(
          color: electricBlue.withValues(alpha: opacity),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> cardShadow({double opacity = 0.06}) => [
        BoxShadow(
          color: navyBlue.withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
