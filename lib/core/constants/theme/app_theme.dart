import 'package:flutter/material.dart';
import '../app_constants.dart';

class AppTheme {
  // Modern Cinema Colors - تدرجات عصرية للسينما
  static const Color primaryColor = Color(0xFF0F0E17); // Deep Space Black
  static const Color secondaryColor = Color(0xFF6C5CE7); // Electric Purple
  static const Color accentColor = Color(0xFFFF6B6B); // Coral Red
  static const Color goldColor = Color(0xFFFD79A8); // Pink Gold
  static const Color neonBlue = Color(0xFF00CEC9); // Neon Turquoise
  static const Color neonPurple = Color(0xFF6C5CE7); // Electric Purple
  static const Color cosmicOrange = Color(0xFFFF7675); // Cosmic Orange

  // Gradient Colors for Professional UI
  static const List<Color> primaryGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFf093fb),
    Color(0xFFf5576c),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF232526),
    Color(0xFF414345),
  ];

  // Light Theme Colors - Modern & Clean
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF2D3436);
  static const Color lightCardColor = Color(0xFFFFFFFF);

  // Dark Theme Colors - Cinematic & Professional
  static const Color darkBackground = Color(0xFF0F0E17);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkOnSurface = Color(0xFFEEEEEE);
  static const Color darkCardColor = Color(0xFF16213E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error:
            Color(0xFFD32F2F), // Changed from accentColor to proper error color
        surface: lightCardColor,
        onSurface: lightOnSurface,
        primaryContainer: Color(0xFFE8F4FD),
        onPrimaryContainer: primaryColor,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: _buildTextTheme(lightOnSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightOnSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: lightOnSurface),
      ),
      cardTheme: CardThemeData(
        color: lightCardColor,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightCardColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: lightOnSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPurple,
        error:
            Color(0xFFEF5350), // Changed from accentColor to proper error color
        surface: darkCardColor,
        onSurface: darkOnSurface,
        primaryContainer: Color(0xFF1A1A2E),
        onPrimaryContainer: neonBlue,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: _buildTextTheme(darkOnSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkOnSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: darkOnSurface),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 12,
        shadowColor: neonBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: neonBlue.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: neonPurple.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: neonBlue,
        unselectedItemColor: darkOnSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: neonBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return const TextTheme().copyWith(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: -0.25,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: 'Inter',
        letterSpacing: 0.5,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: 'Inter',
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
        fontFamily: 'Inter',
        letterSpacing: 0.4,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 1.25,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 1.5,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textColor,
        fontFamily: 'Poppins',
        letterSpacing: 1.5,
        height: 1.2,
      ),
    );
  }
}
