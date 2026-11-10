import 'package:flutter/material.dart';
import '../widgets/cyber_controls.dart';

class AppTheme {
  // ── One6 Premium Blue Gradient Color Palette ────────────────────────────────
  static const Color electricBlue = Color(0xFF0057FF); // Primary buttons, active
  static const Color royalBlue = Color(0xFF1769FF);    // Primary brand color
  static const Color skyBlue = Color(0xFF20BFFF);      // Gradient highlights
  static const Color cyanBlue = Color(0xFF00D4FF);     // Accent & glowing endpoints
  static const Color lightBlue = Color(0xFFB9DEFF);    // Decorative elements
  static const Color iceBlue = Color(0xFFEAF5FF);      // Screen background
  static const Color pureWhite = Color(0xFFFFFFFF);    // Cards, white text
  static const Color navyBlue = Color(0xFF102A63);     // Headings, primary text
  static const Color slateBlue = Color(0xFF647899);    // Descriptions, secondary text
  static const Color cardBorderColor = Color(0xFFE2E8F0); // Mild Grey Border
  static const Color dotUnselected = Color(0xFFB9D5F0);  // Unselected pagination

  // Backward-compatible aliases
  static const Color primaryBlueStart = electricBlue;
  static const Color primaryBlue = royalBlue;
  static const Color primaryBlueEnd = skyBlue;
  static const Color accentCyan = cyanBlue;
  static const Color iceBackground = iceBlue;
  static const Color primaryOrange = electricBlue;
  static const Color primaryOrangeDark = royalBlue;
  static const Color accentPurple = royalBlue;
  static const Color lightPurpleBg = iceBlue;
  static const Color cyberDark = navyBlue;
  static const Color cardDark = pureWhite;
  static const Color cardBorder = cardBorderColor;
  static const Color cyberCyan = cyanBlue;
  static const Color turfGreen = Color(0xFF10B981);
  static const Color flameOrange = electricBlue;
  static const Color focusPurple = royalBlue;
  static const Color textPrimary = navyBlue;
  static const Color textSecondary = slateBlue;
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderColor = cardBorderColor;
  static const Color backgroundLight = iceBlue;
  static const Color badgePurpleBg = Color(0xFFD9EDFF);
  static const Color badgePurpleText = electricBlue;
  static const Color linkBlue = electricBlue;

  // ── Gradients ───────────────────────────────────────────────────────────────
  // Gradient 1: Primary CTA Button
  static const LinearGradient primaryCtaGradient = LinearGradient(
    colors: [electricBlue, royalBlue, skyBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradient 2: Premium Background
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [iceBlue, pureWhite, Color(0xFFD9EDFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradient 3: Brand Accent
  static const LinearGradient brandAccentGradient = LinearGradient(
    colors: [Color(0xFF0038B8), electricBlue, cyanBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Aliases
  static const LinearGradient blueGradient = primaryCtaGradient;
  static const LinearGradient heroGradient = brandAccentGradient;
  static const LinearGradient orangeGradient = primaryCtaGradient;
  static const LinearGradient cyberGradient = primaryCtaGradient;

  // ── Theme Data ──────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: iceBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: electricBlue,
        primary: electricBlue,
        secondary: skyBlue,
        surface: pureWhite,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: navyBlue),
        titleTextStyle: TextStyle(
          color: navyBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: cardBorderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: electricBlue, width: 1.8),
        ),
        labelStyle: const TextStyle(color: slateBlue, fontSize: 14, fontFamily: 'Roboto'),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontFamily: 'Roboto'),
      ),
      sliderTheme: const SliderThemeData(
        trackShape: GradientSliderTrackShape(),
        trackHeight: 6,
        inactiveTrackColor: Color(0xFFE2E8F0),
        thumbColor: Colors.white,
        overlayColor: Color(0x260066FF),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9, elevation: 3),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return electricBlue;
          }
          return const Color(0xFFCBD5E1);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return electricBlue;
          }
          return const Color(0xFFCBD5E1);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return electricBlue;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static BoxDecoration gradientBox({
    double radius = 16,
    List<Color>? colors,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: colors ?? const [electricBlue, royalBlue, skyBlue],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      boxShadow: [
        BoxShadow(
          color: electricBlue.withAlpha(80),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
