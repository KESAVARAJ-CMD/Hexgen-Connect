import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Reusable Cyber Glassmorphic Backdrop providing the radial gradient,
/// subtle ambient cyber pattern, and glowing blurred cyan/blue light orbs.
class CyberGlassBackdrop extends StatelessWidget {
  final Widget child;
  final bool showOrbs;
  final bool showPattern;

  static const String bgPatternUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAdOdv4w8HJWhCfumwKzqU2omAHxpNWqqFdfDDPm74pdBwmpZJVjLcqiT-YtGmRxGIbhruVNdqHqxmPBmsUTUrQiWTlKeKuR8dXXF4FEl6A2P5rhjl9sU1S0A9DNNC7XeF3AkQRbtaJCSaaUPn54vdJ-lTYCzXZqamQ8zB5BaLeozqkAnwBReA2P4ipcukVOpQf2S8w6c42lTlKvwbBbAXRb3ViZiobzFzx0NsxHtzZife0qivtGH67';

  const CyberGlassBackdrop({
    super.key,
    required this.child,
    this.showOrbs = true,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── 1. Crisp Background Image Backdrop with Radial Gradient ────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.80, -0.90),
                radius: 0.95,
                colors: [
                  const Color(0xFF0066FF).withValues(alpha: 0.25),
                  const Color(0xFFE2EDFF).withValues(alpha: 0.85),
                  const Color(0xFFF3F7FF),
                ],
              ),
            ),
            child: showPattern
                ? Image.network(
                    bgPatternUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  )
                : null,
          ),
        ),

        // ── 2. Glowing Ambient Orbs ──────────────────────────────────────────
        if (showOrbs) ...[
          // Cyber Cyan Glow Overlay (Top Right)
          Positioned(
            top: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0099FF).withValues(alpha: 0.28),
                ),
              ),
            ),
          ),

          // Cyber Cyan Glow Overlay (Bottom Right)
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0099FF).withValues(alpha: 0.28),
                ),
              ),
            ),
          ),

          // Cyber Blue Glow Overlay (Bottom Left)
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0066FF).withValues(alpha: 0.28),
                ),
              ),
            ),
          ),
        ],

        // ── 3. Foreground Content ────────────────────────────────────────────
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
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.60),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.85),
              width: borderWidth,
            ),
            boxShadow: boxShadow ??
                [
                  BoxShadow(
                    color: const Color(0xFF1C3E78).withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
          ),
          child: child,
        ),
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
