import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Backdrop providing a clean ice-blue foundation with minimal top and bottom
/// blue cloud effects and ambient atmospheric glow.
class CyberGlassBackdrop extends StatelessWidget {
  final Widget child;
  final bool showOrbs;
  final bool showPattern;

  static const String bgPatternUrl = AppTheme.bgPatternUrl;

  const CyberGlassBackdrop({
    super.key,
    required this.child,
    this.showOrbs = false,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Full-Screen Blue Gradient Base Foundation ─────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFCEE5FD), // Rich Sky Blue (Top)
                  Color(0xFFE2F0FE), // Ambient Soft Cyan Blue
                  Color(0xFFEFF7FF), // Crisp Ice Blue (Center)
                  Color(0xFFD4E9FD), // Electric Blue Atmospheric Tint (Bottom)
                ],
                stops: [0.0, 0.32, 0.68, 1.0],
              ),
            ),
          ),
        ),

        // ── 2. Full-Screen Cloud Effect ─────────────────────────────────────
        if (showPattern)
          Positioned.fill(
            child: Image.network(
              bgPatternUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),

        // ── 3. Full-Screen Blue Gradient & Light Atmosphere Overlay ──────────
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0077FF).withValues(alpha: 0.14),
                    const Color(0xFF00B4D8).withValues(alpha: 0.05),
                    Colors.transparent,
                    const Color(0xFF0052FF).withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.25, 0.65, 1.0],
                ),
              ),
            ),
          ),
        ),

        // ── 4. Foreground Content ────────────────────────────────────────────
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

/// Frosted Glass Card container matching the Hexgen cyber glassmorphic system.
class CyberGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const CyberGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20,
    this.blur = 16,
    this.color,
    this.borderColor,
    this.borderWidth = 1.2,
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    Widget content = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: borderColor ?? const Color(0xFFD6E4F8),
            width: borderWidth,
          ),
          boxShadow: boxShadow ??
              [
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
        child: child,
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          borderRadius: effectiveBorderRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
