import 'package:flutter/material.dart';

/// Role-based blue/teal visual tokens for JasoSupporter.
abstract final class AppColors {
  static const Color primary = Color(0xFF0B4F6C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFC5E3F2);
  static const Color onPrimaryContainer = Color(0xFF001E2E);
  static const Color secondary = Color(0xFF0A5C72);
  static const Color aiAccent = Color(0xFF0A6358);
  static const Color success = Color(0xFF0F766E);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFBA1A1A);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFF8FA3B4);
  static const Color outlineVariant = Color(0xFFC9D6E3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE8EEF3);
  static const Color surfaceContainerHigh = Color(0xFFDCE4EB);
  static const Color surfaceContainerHighest = Color(0xFFC5D0DB);
  static const Color chipUnselected = Color(0xFFE8EEF3);
  static const Color scaffold = Color(0xFFF1F5F9);

  static ColorScheme get colorScheme =>
      ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        tertiary: aiAccent,
        onTertiary: onPrimary,
        error: error,
        onError: onPrimary,
        surface: surface,
        onSurface: onSurface,
      ).copyWith(
        surfaceTint: Colors.transparent,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondaryContainer: const Color(0xFFB8D9E8),
        onSecondaryContainer: const Color(0xFF001823),
        tertiaryContainer: const Color(0xFFA8E0D8),
        onTertiaryContainer: const Color(0xFF001814),
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        inverseSurface: const Color(0xFF1E293B),
        onInverseSurface: const Color(0xFFF8FAFC),
        inversePrimary: const Color(0xFF8ECAE6),
      );
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
}
