import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

/// Experience STAR 필드를 읽기 전용으로 보여주는 공통 위젯.
class ExperienceStarPreview extends StatelessWidget {
  const ExperienceStarPreview({
    super.key,
    required this.experience,
    this.compact = false,
    this.accent = AppColors.experience,
  });

  final Experience experience;
  final bool compact;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final double labelSize = compact ? 11.5 : 12;
    final double bodySize = compact ? 12.5 : 13.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StarLine(
          label: '상황',
          value: experience.situation,
          accent: accent,
          labelSize: labelSize,
          bodySize: bodySize,
          maxLines: compact ? 2 : null,
        ),
        _StarLine(
          label: '과제',
          value: experience.task,
          accent: accent,
          labelSize: labelSize,
          bodySize: bodySize,
          maxLines: compact ? 2 : null,
        ),
        _StarLine(
          label: '행동',
          value: experience.action,
          accent: accent,
          labelSize: labelSize,
          bodySize: bodySize,
          maxLines: compact ? 3 : null,
        ),
        _StarLine(
          label: '성과',
          value: experience.result,
          accent: accent,
          labelSize: labelSize,
          bodySize: bodySize,
          maxLines: compact ? 2 : null,
        ),
        _StarLine(
          label: '배운 점',
          value: experience.learned,
          accent: accent,
          labelSize: labelSize,
          bodySize: bodySize,
          maxLines: compact ? 2 : null,
          padBottom: false,
        ),
      ],
    );
  }
}

class _StarLine extends StatelessWidget {
  const _StarLine({
    required this.label,
    required this.value,
    required this.accent,
    required this.labelSize,
    required this.bodySize,
    this.maxLines,
    this.padBottom = true,
  });

  final String label;
  final String value;
  final Color accent;
  final double labelSize;
  final double bodySize;
  final int? maxLines;
  final bool padBottom;

  @override
  Widget build(BuildContext context) {
    final String body = value.trim().isEmpty ? '(미입력)' : value.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: padBottom ? 10 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body.softWrapWords(),
            maxLines: maxLines,
            overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(fontSize: bodySize, height: 1.4),
          ),
        ],
      ),
    );
  }
}
