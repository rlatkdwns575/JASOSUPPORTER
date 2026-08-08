import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/year_month_picker.dart';
import 'package:flutter/material.dart';

/// 시작·종료 연월을 [YearMonthField]로 입력하는 공통 기간 필드.
///
/// Notion 경험정리 템플릿의 `기간 (yy.mm-yy.mm)` 형식에 맞춘다.
class PeriodRangeFields extends StatelessWidget {
  const PeriodRangeFields({
    super.key,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
    this.enabled = true,
    this.startLabel = '시작 (yy.mm)',
    this.endLabel = '종료 (yy.mm)',
    this.sectionLabel = '기간',
    this.onClear,
  });

  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime?> onStartChanged;
  final ValueChanged<DateTime?> onEndChanged;
  final bool enabled;
  final String startLabel;
  final String endLabel;
  final String sectionLabel;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = start != null || end != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sectionLabel.trim().isNotEmpty) ...[
          Text(
            sectionLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: YearMonthField(
                label: startLabel,
                value: start,
                enabled: enabled,
                helpText: '시작',
                onChanged: onStartChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: YearMonthField(
                label: endLabel,
                value: end,
                enabled: enabled,
                helpText: '종료',
                onChanged: onEndChanged,
              ),
            ),
          ],
        ),
        if (hasValue && onClear != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: enabled ? onClear : null,
              style: TextButton.styleFrom(foregroundColor: AppColors.experience),
              child: const Text('기간 초기화'),
            ),
          ),
      ],
    );
  }
}
