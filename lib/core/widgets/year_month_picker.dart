import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 연/월만 선택하는 다이얼로그. 일(day)은 선택하지 않고 1일로 고정한다.
///
/// 반환값이 `null` 이면 취소한 것이다.
Future<DateTime?> showYearMonthPicker(
  BuildContext context, {
  DateTime? initial,
  int firstYear = 1980,
  int lastYear = 2038,
  String helpText = "연·월 선택",
}) {
  final DateTime now = DateTime.now();
  final DateTime init = initial ?? DateTime(now.year, now.month);
  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext ctx) {
      return Theme(
        data: Theme.of(ctx).copyWith(colorScheme: AppColors.colorScheme),
        child: _YearMonthDialog(
          initial: DateTime(init.year, init.month),
          firstYear: firstYear,
          lastYear: lastYear,
          helpText: helpText,
        ),
      );
    },
  );
}

class _YearMonthDialog extends StatefulWidget {
  const _YearMonthDialog({
    required this.initial,
    required this.firstYear,
    required this.lastYear,
    required this.helpText,
  });

  final DateTime initial;
  final int firstYear;
  final int lastYear;
  final String helpText;

  @override
  State<_YearMonthDialog> createState() => _YearMonthDialogState();
}

class _YearMonthDialogState extends State<_YearMonthDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year.clamp(widget.firstYear, widget.lastYear);
    _month = widget.initial.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      title: Text(
        widget.helpText,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.experience),
      ),
      content: SizedBox(
        width: 320,
        child: Row(
          children: [
            Expanded(
              child: _Dropdown<int>(
                label: "연도",
                value: _year,
                items: [
                  for (int y = widget.lastYear; y >= widget.firstYear; y--)
                    DropdownMenuItem(value: y, child: Text("$y년")),
                ],
                onChanged: (int? v) {
                  if (v != null) {
                    setState(() => _year = v);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Dropdown<int>(
                label: "월",
                value: _month,
                items: [
                  for (int m = 1; m <= 12; m++)
                    DropdownMenuItem(value: m, child: Text("$m월")),
                ],
                onChanged: (int? v) {
                  if (v != null) {
                    setState(() => _month = v);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("취소"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(DateTime(_year, _month)),
          child: const Text("확인"),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

/// 텍스트 입력 대신 연/월을 선택하는 필드형 위젯.
///
/// 탭하면 [showYearMonthPicker] 를 열고, 값이 있으면 지우기 버튼을 노출한다.
class YearMonthField extends StatelessWidget {
  const YearMonthField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helpText,
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? helpText;
  final bool enabled;

  static String formatYearMonth(DateTime? value) {
    if (value == null) {
      return "";
    }
    final String y = value.year.toString().padLeft(4, "0");
    final String m = value.month.toString().padLeft(2, "0");
    return "$y.$m";
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasValue = value != null;
    final String text = hasValue ? formatYearMonth(value) : "$label 선택";
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      onTap: !enabled
          ? null
          : () async {
              final DateTime? picked = await showYearMonthPicker(
                context,
                initial: value,
                helpText: helpText ?? "$label 선택",
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabled: enabled,
          suffixIcon: hasValue && enabled
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: "지우기",
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_month_outlined, size: 20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: hasValue ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
