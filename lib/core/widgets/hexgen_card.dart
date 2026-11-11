import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/hexgen_colors.dart';

/// Clean cyber glassmorphic card surface with frosted backdrop blur and white border
class HexgenCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasGlow;
  final bool hasTopAccent;
  final Color? borderColor;
  final double borderRadius;
  final bool isGlass;
  final Color? backgroundColor;

  const HexgenCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.hasGlow = false,
    this.hasTopAccent = false,
    this.borderColor,
    this.borderRadius = 20,
    this.isGlass = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    Widget cardContent;

    if (isGlass) {
      cardContent = Container(
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF0057FF).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: borderColor ?? const Color(0xFFD6E4F8),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      );
    } else {
      cardContent = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? HexgenColors.pureWhite,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: borderColor ?? AppTheme.cardBorderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navyBlue.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          borderRadius: effectiveBorderRadius,
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
