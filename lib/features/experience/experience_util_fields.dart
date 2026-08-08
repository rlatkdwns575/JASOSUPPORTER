import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:flutter/material.dart';

typedef ExperienceFieldDecoration = InputDecoration Function({
  required String label,
  String? hint,
});

/// 역량 태그·증빙 링크 공통 입력.
class ExperienceUtilFields extends StatelessWidget {
  const ExperienceUtilFields({
    super.key,
    required this.competencyTags,
    required this.evidenceLinks,
    required this.decoration,
    this.techStacks,
  });

  final TextEditingController competencyTags;
  final TextEditingController evidenceLinks;
  final TextEditingController? techStacks;
  final ExperienceFieldDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (techStacks != null) ...[
          TextField(
            controller: techStacks,
            decoration: decoration(
              label: '사용 기술·도구 (선택)',
              hint: '예: Flutter, Python, Figma',
            ),
          ),
          const SizedBox(height: 10),
        ],
        ExperienceFormRow(
          children: [
            TextField(
              controller: competencyTags,
              decoration: decoration(
                label: '역량 태그 (선택)',
                hint: '예: 협업, 문제해결, 리더십',
              ),
            ),
            TextField(
              controller: evidenceLinks,
              decoration: decoration(
                label: '증빙 링크 (선택)',
                hint: '예: GitHub, 발표자료 URL',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static List<String> splitCsv(String raw) {
    return raw
        .split(RegExp(r'[,/\n·|]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }
}
