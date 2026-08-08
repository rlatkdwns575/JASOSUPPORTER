import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 경험·스펙 입력 필드 공통 스타일.
InputDecoration experienceFieldDecoration({
  required String label,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      borderSide: const BorderSide(color: AppColors.experience, width: 1.4),
    ),
    hintStyle: const TextStyle(
      fontSize: 13.5,
      color: AppColors.onSurfaceVariant,
    ),
    labelStyle: const TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurfaceVariant,
    ),
  );
}

/// 카테고리별 별칭 — 모두 동일 스타일로 통일.
InputDecoration campusFieldDecoration({required String label, String? hint}) =>
    experienceFieldDecoration(label: label, hint: hint);

InputDecoration externalFieldDecoration({required String label, String? hint}) =>
    experienceFieldDecoration(label: label, hint: hint);

InputDecoration contestFieldDecoration({required String label, String? hint}) =>
    experienceFieldDecoration(label: label, hint: hint);

InputDecoration globalFieldDecoration({required String label, String? hint}) =>
    experienceFieldDecoration(label: label, hint: hint);

InputDecoration otherFieldDecoration({required String label, String? hint}) =>
    experienceFieldDecoration(label: label, hint: hint);

InputDecoration specFieldDecoration({required String label, String? hint}) =>
    experienceFieldDecoration(label: label, hint: hint);
