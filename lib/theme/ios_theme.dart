import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSTheme {
  // Apple System & Gradient Colors
  static const Color primaryBlue = Color(0xFF0A84FF);
  static const Color primaryIndigo = Color(0xFF5E5CE6);
  static const Color systemPurple = Color(0xFFBF5AF2);
  static const Color systemOrange = Color(0xFFFF9F0A);
  static const Color systemRed = Color(0xFFFF453A);
  static const Color systemGreen = Color(0xFF30D158);
  static const Color systemTeal = Color(0xFF64D2FF);
  static const Color systemPink = Color(0xFFFF375F);
  static const Color systemYellow = Color(0xFFFFD60A);

  // Modern Apple Gradients
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9500), Color(0xFFFF5E3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFF30E8BD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardMeshLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardMeshDark = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF161618)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backgrounds
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0xCCFFFFFF);
  static const Color lightGlassBorder = Color(0x40FFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);

  static const Color darkBackground = Color(0xFF090A0F);
  static const Color darkCardBackground = Color(0xFF161822);
  static const Color darkGlass = Color(0xCC161822);
  static const Color darkGlassBorder = Color(0x25FFFFFF);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF26293B);

  // Glassmorphism Box Decoration Helper
  static BoxDecoration glassDecoration({
    required bool isDark,
    double radius = 18,
    Color? accentColor,
    bool isSelected = false,
  }) {
    return BoxDecoration(
      color: isSelected
          ? (accentColor ?? primaryBlue).withValues(alpha: isDark ? 0.22 : 0.14)
          : (isDark ? darkCardBackground : lightCardBackground),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isSelected
            ? (accentColor ?? primaryBlue)
            : (isDark ? darkGlassBorder : lightDivider),
        width: isSelected ? 1.5 : 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: (isSelected ? (accentColor ?? primaryBlue) : Colors.black)
              .withValues(alpha: isSelected ? (isDark ? 0.35 : 0.2) : (isDark ? 0.35 : 0.05)),
          blurRadius: isSelected ? 16 : 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Light ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: systemPurple,
        surface: lightCardBackground,
        error: systemRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      dividerColor: lightDivider,
      fontFamily: '.SF Pro Text',
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: lightBackground,
        barBackgroundColor: Color(0xCCF6F8FA),
      ),
    );
  }

  // Dark ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: systemPurple,
        surface: darkCardBackground,
        error: systemRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      dividerColor: darkDivider,
      fontFamily: '.SF Pro Text',
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: darkBackground,
        barBackgroundColor: Color(0xCC090A0F),
      ),
    );
  }
}
