import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF7F9FC);
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4DD0E1);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF2D2D3A);
  static const Color textMid = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFB0B7C3);
  static const Color gold = Color(0xFFFFB300);
  static const Color success = Color(0xFF4CAF50);

  // Ball colors
  static const List<Color> ballColors = [
    Color(0xFFFF6B9D), // pink
    Color(0xFF6C63FF), // purple
    Color(0xFF4DD0E1), // cyan
    Color(0xFF81C784), // green
    Color(0xFFFFB300), // yellow
    Color(0xFFFF7043), // orange
    Color(0xFF29B6F6), // blue
    Color(0xFFAB47BC), // violet
  ];
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Nunito',
      );
}

class AppRoutes {
  static const String splash = '/';
  static const String menu = '/menu';
  static const String game = '/game';
  static const String about = '/about';
  static const String privacy = '/privacy';
}
