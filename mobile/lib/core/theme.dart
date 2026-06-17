import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryLight = Color(0xFF07345A);
  static const Color accentLight = Color(0xFF0B9F91);
  static const Color bgLight = Color(0xFFF4F8F6);
  static const Color cardLight = Colors.white;

  static const Color primaryDark = Color(0xFFEAF8F4);
  static const Color accentDark = Color(0xFFE8C766);
  static const Color bgDark = Color(0xFF041722);
  static const Color cardDark = Color(0xFF0A2638);

  static ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    primary: primaryLight,
    background: bgLight,
    card: cardLight,
  );

  static ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    background: bgDark,
    card: cardDark,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color card,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      fontFamily: 'Outfit',
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? accentDark : accentLight,
        brightness: brightness,
        primary: isDark ? accentDark : accentLight,
        onPrimary: isDark ? const Color(0xFF031827) : Colors.white,
        secondary: isDark ? const Color(0xFF16C7B7) : const Color(0xFF07345A),
        surface: card,
        onSurface: primary,
        error: const Color(0xFFE5484D),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.08,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: primary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: isDark
              ? Colors.white.withValues(alpha: 0.74)
              : primary.withValues(alpha: 0.78),
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white54 : const Color(0xFF6A7D85),
        ),
      ).apply(fontFamily: 'Outfit'),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF07345A).withValues(alpha: 0.06),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0A2638) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF07345A).withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF07345A).withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? accentDark : accentLight,
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Outfit',
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark, // Android
          statusBarBrightness: isDark
              ? Brightness.dark
              : Brightness.light, // iOS
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: primary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: isDark
            ? const Color(0xFFE8C766).withValues(alpha: 0.18)
            : const Color(0xFF16C7B7).withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE8C766) : const Color(0xFF0B9F91),
            );
          }
          return TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white60 : Colors.black54,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isDark ? const Color(0xFFE8C766) : const Color(0xFF0B9F91),
            );
          }
          return IconThemeData(color: isDark ? Colors.white60 : Colors.black54);
        }),
      ),
    );
  }
}
