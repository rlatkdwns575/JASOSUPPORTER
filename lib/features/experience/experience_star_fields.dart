import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// STAR + 배운 점 공통 입력 블록.
///
/// 동일 높이 스택 + 글자 배지로 한 블록처럼 보이게 한다.
class ExperienceStarFields extends StatelessWidget {
  const ExperienceStarFields({
    super.key,
    required this.situation,
    required this.task,
    required this.action,
    required this.result,
    required this.learned,
    required this.hints,
  });

  final TextEditingController situation;
  final TextEditingController task;
  final TextEditingController action;
  final TextEditingController result;
  final TextEditingController learned;
  final StarFieldHints hints;

  static const int _minLines = 3;
  static const int _maxLines = 6;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StarRow(
          badge: 'S',
          title: '상황',
          controller: situation,
          hint: hints.situation,
        ),
        const Divider(height: 16, thickness: 1, color: AppColors.outlineVariant),
        _StarRow(
          badge: 'T',
          title: '과제',
          controller: task,
          hint: hints.task,
        ),
        const Divider(height: 16, thickness: 1, color: AppColors.outlineVariant),
        _StarRow(
          badge: 'A',
          title: '행동',
          controller: action,
          hint: hints.action,
        ),
        const Divider(height: 16, thickness: 1, color: AppColors.outlineVariant),
        _StarRow(
          badge: 'R',
          title: '성과',
          controller: result,
          hint: hints.result,
        ),
        const Divider(height: 16, thickness: 1, color: AppColors.outlineVariant),
        _StarRow(
          badge: '배움',
          title: '배운 점',
          controller: learned,
          hint: hints.learned,
          softBadge: true,
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.badge,
    required this.title,
    required this.controller,
    required this.hint,
    this.softBadge = false,
  });

  final String badge;
  final String title;
  final TextEditingController controller;
  final String hint;
  final bool softBadge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 28),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: softBadge
                    ? AppColors.surfaceContainer
                    : AppColors.experienceTint,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: softBadge
                      ? AppColors.onSurfaceVariant
                      : AppColors.experience,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: ExperienceStarFields._minLines,
          maxLines: ExperienceStarFields._maxLines,
          style: const TextStyle(fontSize: 14.5, height: 1.45),
          decoration: InputDecoration(
            hintText: hint,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              borderSide:
                  const BorderSide(color: AppColors.experience, width: 1.4),
            ),
            hintStyle: const TextStyle(
              fontSize: 13.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
