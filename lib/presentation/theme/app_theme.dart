import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color navy = Color(0xFF002A49);
  static const Color orange = Color(0xFFED6739);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      secondary: orange,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
    );
  }
}
