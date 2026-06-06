import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A1A2E),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1A1A2E),
      secondary: const Color(0xFF0D7A3E),
      tertiary: const Color(0xFFFBB040),
      error: const Color(0xFFD92B2B),
      surface: const Color(0xFFFFFFFF),
      surfaceContainerHighest: const Color(0xFFF5F6FA),
      onSurface: const Color(0xFF1A1A2E),
      onSurfaceVariant: const Color(0xFF6B7280),
      outline: const Color(0xFFE5E7EB),
      outlineVariant: const Color(0xFFE5E7EB),
    ),
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
