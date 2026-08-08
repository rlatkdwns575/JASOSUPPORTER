import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 대학교·대학원용 학점 입력 블록.
class SpecGpaFields extends StatelessWidget {
  const SpecGpaFields({
    super.key,
    required this.score,
    required this.fullMarkChoice,
    required this.fullMarkOther,
    required this.onFullMarkChanged,
    this.enabled = true,
  });

  final TextEditingController score;
  final String fullMarkChoice;
  final TextEditingController fullMarkOther;
  final ValueChanged<String> onFullMarkChanged;
  final bool enabled;

  static const List<String> fullMarkOptions = <String>[
    '4.5',
    '4.3',
    '4.0',
    '100',
    '기타',
  ];

  /// 점수가 비어 있으면 null.
  SpecItem? buildItem({DateTime? now}) {
    return SpecItemFactory.gpa(
      score: score.text,
      fullMark: fullMarkChoice == '기타'
          ? fullMarkOther.text.trim()
          : fullMarkChoice,
      now: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExperienceFormRow(
          children: [
            TextField(
              controller: score,
              enabled: enabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: specFieldDecoration(
                label: '평균 학점',
                hint: '예: 3.8',
              ),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(fullMarkChoice),
              initialValue: fullMarkChoice,
              decoration: specFieldDecoration(label: '만점 기준'),
              items: [
                for (final String opt in fullMarkOptions)
                  DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt == '기타' ? '기타 (직접 입력)' : '$opt 만점'),
                  ),
              ],
              onChanged: enabled
                  ? (String? v) {
                      if (v != null) {
                        onFullMarkChanged(v);
                      }
                    }
                  : null,
            ),
          ],
        ),
        if (fullMarkChoice == '기타') ...[
          const SizedBox(height: 10),
          TextField(
            controller: fullMarkOther,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: specFieldDecoration(
              label: '만점 (직접 입력)',
              hint: '예: 4.5',
            ),
          ),
        ],
      ],
    );
  }
}
