import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/hexgen_colors.dart';

/// Hexgen Signature Action Button
/// Mild grey border for outlined buttons and clean CTA gradients for primary buttons.
class HexgenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Widget? trailing;

  const HexgenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.height = 52,
    this.borderRadius = 16,
    this.fontSize = 13,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: isOutlined ? HexgenColors.navyBlue : Colors.white),
          const SizedBox(width: 6),
        ],
        if (isFullWidth)
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: isOutlined ? HexgenColors.navyBlue : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                letterSpacing: 0.4,
                fontFamily: 'Roboto',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: isOutlined ? HexgenColors.navyBlue : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.4,
              fontFamily: 'Roboto',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ],
    );

    if (isOutlined) {
      return Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navyBlue.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: content,
            ),
          ),
        ),
      );
    }

    return Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? HexgenColors.primaryGradient
            : const LinearGradient(
                colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
              ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.navyBlue.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: content,
      ),
    );
  }
}
