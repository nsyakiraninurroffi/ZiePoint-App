import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ZiePoint — Blush Rose × Soft Lavender Glassmorphism Theme
/// Professional · Elegant · Girly
class AppTheme {
  AppTheme._();

  // Background Gradient (deep plum to mauve)
  static const Color backgroundTop = Color(0xFF1A0E2E);
  static const Color backgroundMid = Color(0xFF2D1B4E);
  static const Color backgroundBottom = Color(0xFF3D2060);

  // Accent Colors
  static const Color accentRose = Color(0xFFE8A4B8);
  static const Color accentRoseDeep = Color(0xFFD4688C);
  static const Color accentLavender = Color(0xFFB8A4E8);
  static const Color accentLavDeep = Color(0xFF9B7FD4);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);
  static const Color textLabel = Color(0x99FFFFFF);

  // Status Colors
  static const Color successGreen = Color(0xFF7DD8A8);
  static const Color errorRed = Color(0xFFFF8FA3);
  static const Color warningAmber = Color(0xFFFFCB77);

  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [accentLavender, accentLavDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

// Glassmorphism Tokens
  static final Color glassBg = Color.fromRGBO(255, 255, 255, 0.06);
  static final Color glassBorder = Color.fromRGBO(255, 255, 255, 0.14);
  static final Color glassHoverBorder = Color.fromRGBO(255, 255, 255, 0.28);
  static final Color glassActiveTabBg = Color(0xFFE8A4B8).withOpacity(0.15);
  static final Color glassActiveTabBorder = Color(0xFFE8A4B8).withOpacity(0.5);

  // Additional status colors for pelanggaran and prestasi
  static const Color pelanggaran = Color(0xFFFF8FA3);
  static const Color prestasi = Color(0xFF7DD8A8);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundTop, backgroundMid, backgroundBottom],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient roseGradient = LinearGradient(
    colors: [accentRose, accentRoseDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [accentRose, accentLavender, accentRose],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border Radius
  static final BorderRadius radiusXs = BorderRadius.all(Radius.circular(8));
  static final BorderRadius radiusSm = BorderRadius.all(Radius.circular(12));
  static final BorderRadius radiusMd = BorderRadius.all(Radius.circular(16));
  static final BorderRadius radiusLg = BorderRadius.all(Radius.circular(22));
  static final BorderRadius radiusXl = BorderRadius.all(Radius.circular(28));


  // Additional Colors for compatibility
  static const Color accentIndigo = Color(0xFF6A5ACD);
  static const Color accentHover = accentLavender; // use lavender as hover accent

  // Gradient alias for legacy name
  static const LinearGradient navyBackgroundGradient = backgroundGradient;

  // Button gradient used in teacher page
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [accentRose, accentLavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: -0.3),
      titleMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
      titleSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
      bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 15),
      bodyMedium: GoogleFonts.inter(color: textPrimary, fontSize: 14),
      bodySmall: GoogleFonts.inter(color: textSecondary, fontSize: 12),
      labelLarge: GoogleFonts.inter(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      labelMedium: GoogleFonts.inter(color: textLabel, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.1),
      labelSmall: GoogleFonts.inter(color: textMuted, fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 0.8),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: _buildTextTheme(),
    scaffoldBackgroundColor: backgroundTop,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentRose,
      brightness: Brightness.dark,
      primary: accentRose,
      secondary: accentLavender,
      surface: backgroundMid,
      error: errorRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRose,
        foregroundColor: Color(0xFF3D1A2A),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: accentRose.withOpacity(0.6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: errorRed.withOpacity(0.7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: errorRed, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(color: textLabel, fontSize: 14, fontWeight: FontWeight.w400),
      hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      errorStyle: GoogleFonts.inter(color: errorRed, fontSize: 11),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: radiusLg),
      color: glassBg,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.08),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(size: 22),
  );

  // Light theme mirrors dark
  static ThemeData get lightTheme => darkTheme;

  static ThemeMode get themeMode => ThemeMode.dark;
}

extension ColorWithValues on Color {
  Color withValues({double? alpha}) => withOpacity(alpha ?? 1.0);
}


// Theme Provider for toggling (kept simple, always dark for premium aesthetic)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  void toggle() { _themeMode = ThemeMode.dark; notifyListeners(); }
  void setMode(ThemeMode mode) { _themeMode = ThemeMode.dark; notifyListeners(); }
}
