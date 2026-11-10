import 'package:flutter/material.dart';

/// Custom Slider Track Shape that renders the active portion of the slider
/// with HexGen's signature Royal Blue to Electric Cyan Gradient.
class GradientSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final LinearGradient gradient;

  const GradientSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [Color(0xFF0052FF), Color(0xFF00D4FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final trackRadius = Radius.circular(trackRect.height / 2);

    // 1. Draw Inactive Track
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? const Color(0xFFE2E8F0);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, trackRadius),
      inactivePaint,
    );

    // 2. Draw Active Track with Signature Blue Gradient
    final double activeWidth = (thumbCenter.dx - trackRect.left).clamp(0.0, trackRect.width);
    if (activeWidth > 0) {
      final Rect activeRect = Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        trackRect.left + activeWidth,
        trackRect.bottom,
      );

      final Paint activePaint = Paint()
        ..shader = gradient.createShader(trackRect);

      context.canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect, trackRadius),
        activePaint,
      );
    }
  }
}

/// Custom Cyber Toggle Switch with Royal Blue -> Cyan Gradient track & glow
class CyberGradientSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CyberGradientSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF00D4FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: value ? null : const Color(0xFFE2E8F0),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Cyber Gradient Radio Button
class CyberGradientRadio extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const CyberGradientRadio({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFCBD5E1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0052FF), Color(0xFF00D4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Custom Cyber Gradient Checkbox
class CyberGradientCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CyberGradientCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF00D4FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: value ? null : Colors.white,
          border: Border.all(
            color: value ? Colors.transparent : const Color(0xFFCBD5E1),
            width: 1.8,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.30),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: value
            ? const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              )
            : null,
      ),
    );
  }
}
