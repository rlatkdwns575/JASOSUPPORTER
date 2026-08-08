import 'package:flutter/material.dart';

/// JasoSupporter 디자인 토큰.
///
/// 모던 인디고 primary + 기능별 accent(경험/자소서/포트폴리오/지원/AI) + 차분한 뉴트럴.
abstract final class AppColors {
  // Brand / primary (Indigo)
  static const Color primary = Color(0xFF4F46E5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEEF0FE);
  static const Color onPrimaryContainer = Color(0xFF312E81);
  static const Color secondary = Color(0xFF2563EB);
  static const Color aiAccent = Color(0xFF7C3AED);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color warningTint = Color(0xFFFFF7ED);
  static const Color error = Color(0xFFDC2626);

  // Feature accents (역할별 색상) + 연한 tint
  static const Color experience = Color(0xFF2563EB);
  static const Color experienceTint = Color(0xFFEAF1FF);
  static const Color master = Color(0xFF4F46E5);
  static const Color masterTint = Color(0xFFEEEDFF);
  static const Color portfolio = Color(0xFF0D9488);
  static const Color portfolioTint = Color(0xFFE5F6F3);
  static const Color application = Color(0xFFD97706);
  static const Color applicationTint = Color(0xFFFBF0E1);
  static const Color coaching = Color(0xFF6D28D9);
  static const Color coachingTint = Color(0xFFF3EBFF);

  // Neutrals
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFE2E8F0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFEEF2F6);
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0);
  static const Color chipUnselected = Color(0xFFF1F5F9);
  static const Color scaffold = Color(0xFFF5F7FA);

  static ColorScheme get colorScheme => ColorScheme.light(
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
        secondaryContainer: const Color(0xFFDBE7FF),
        onSecondaryContainer: const Color(0xFF10275C),
        tertiaryContainer: coachingTint,
        onTertiaryContainer: const Color(0xFF3B0A73),
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
        inversePrimary: const Color(0xFFC7D2FE),
      );
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 22;
  static const double pill = 999;
}

/// 채팅 패널·입력창·말풍선 공통 타이포/간격/외곽선.
abstract final class AppChatStyle {
  static const double panelInset = 12;
  static const double composerRadius = AppRadii.lg;
  static const double bubbleRadius = 14;
  static const double sendSize = 30;
  static const double iconSize = 18;
  static const double borderWidth = 1;

  static const Color border = AppColors.outlineVariant;
  static const Color sendActive = Color(0xFF334155);
  static const Color sendIdle = AppColors.surfaceContainerHigh;

  static const EdgeInsets composerOuter = EdgeInsets.fromLTRB(12, 6, 12, 12);
  static const EdgeInsets composerInner = EdgeInsets.fromLTRB(12, 12, 12, 8);
  static const EdgeInsets toolbarPadding = EdgeInsets.fromLTRB(6, 2, 6, 6);
  static const EdgeInsets bubblePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets bubbleMargin = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(0, 4, 0, 8);

  static const TextStyle body = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 13.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 13.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle meta = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle metaStrong = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    color: AppColors.onSurface,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 11.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: 'ProductSans',
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static BorderSide get hairline =>
      const BorderSide(color: border, width: borderWidth);

  static BoxDecoration get composerDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(composerRadius),
        border: Border.all(color: border, width: borderWidth),
      );
}
