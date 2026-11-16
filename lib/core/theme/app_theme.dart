import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const Color cardBorderColor = Color(0xFFE2E8F0); // Clean Slate 200 Border for High Contrast
  static const Color dotUnselected = Color(0xFFB9D5F0);  // Unselected pagination

  // Global App Background Pattern Image URL
  static const String bgPatternUrl =
      'https://i.pinimg.com/736x/14/9f/fa/149ffade1b6a54d7e13032f46c865cf1.jpg';

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
    colors: [Color(0xFF0044EB), Color(0xFF1E6FFF), Color(0xFF00D4FF)],
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

  // ── Standard Container Box Decoration across all screens ────────────────────
  static BoxDecoration standardCardDecoration({
    BorderRadius? borderRadius,
    Color? borderColor,
    Color? color,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: borderRadius ?? BorderRadius.circular(16),
    border: Border.all(
      color: borderColor ?? cardBorderColor,
      width: 1.1,
    ),
    boxShadow: boxShadow ?? [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  // ── Theme Data ──────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

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
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: navyBlue),
        titleTextStyle: GoogleFonts.inter(
          color: navyBlue,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
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
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
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
        labelStyle: GoogleFonts.inter(color: slateBlue, fontSize: 13, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w400),
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

// ── Unified Hexgen Clean Typography System (Instagram-Style Neat Hierarchy) ───
class AppTypography {
  AppTypography._();

  /// ── 1. LARGE: Page / Screen Titles (e.g. "Settings and activity", "Previous Sessions")
  static TextStyle pageTitle({Color color = AppTheme.navyBlue, double fontSize = 20}) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: FontWeight.w800,
    color: color,
    letterSpacing: -0.4,
  );

  /// ── 2. MEDIUM-LARGE: Section Headers / Group Titles (e.g. "Your account", "How you use Instagram")
  static TextStyle sectionHeader({Color color = const Color(0xFF64748B), double fontSize = 12.5}) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 0.1,
  );

  /// ── 3. MEDIUM: Row / Card Titles (e.g. "Saved", "Archive", "Notifications", "Cover Drive")
  static TextStyle itemTitle({Color color = AppTheme.navyBlue, double fontSize = 14.5}) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: -0.1,
  );

  /// ── 4. SMALL: Subtitle / Descriptions (e.g. "Password, security, personal details...")
  static TextStyle itemSubtitle({Color color = const Color(0xFF64748B), double fontSize = 12}) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.35,
  );

  /// ── 5. EXTRA SMALL: Badges, Meta, Tags (e.g. "3 Overs", "Not subscribed")
  static TextStyle meta({Color color = const Color(0xFF64748B), FontWeight fontWeight = FontWeight.w600, double fontSize = 11}) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );

  /// ── 6. BUTTONS: Clean CTA Text
  static TextStyle button({Color color = Colors.white, double fontSize = 13.5}) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color,
    letterSpacing: 0.2,
  );
}
