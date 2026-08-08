import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 기타 스펙 전용 입력 화면 (장학·봉사 외 항목).
class OtherSpecInputPanel extends StatefulWidget {
  const OtherSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<OtherSpecInputPanel> createState() => _OtherSpecInputPanelState();
}

class _OtherSpecInputPanelState extends State<OtherSpecInputPanel> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _value = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String _category = '기타';

  static const List<String> _categoryOptions = <String>[
    '기타',
    '수상(스펙)',
    '대외활동 요약',
    '보유 기술',
    '관심 분야',
  ];

  @override
  void dispose() {
    _title.dispose();
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpecInputShell(
      kind: SpecAddKind.other,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_title.text.trim().isEmpty) {
          return '항목 이름을 입력해 주세요.';
        }
        if (_value.text.trim().isEmpty) {
          return '내용을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () => <SpecItem>[
        SpecItemFactory.other(
          title: _title.text,
          value: _value.text,
          note: _note.text,
          category: _category == '기타' ? '' : _category,
        ),
      ],
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceFormSection(
            title: '분류',
            child: DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: specFieldDecoration(label: '스펙 분류'),
              items: [
                for (final String opt in _categoryOptions)
                  DropdownMenuItem<String>(value: opt, child: Text(opt)),
              ],
              onChanged: widget.enabled
                  ? (String? v) {
                      if (v != null) {
                        setState(() => _category = v);
                      }
                    }
                  : null,
            ),
          ),
          ExperienceFormSection(
            title: '기본 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _title,
                  decoration: specFieldDecoration(
                    label: '항목 이름',
                    hint: '예: 교내 프로그램, 보유 툴',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _value,
                  minLines: 3,
                  maxLines: 4,
                  decoration: specFieldDecoration(
                    label: '내용',
                    hint: '예: 핵심 내용·수치·기간',
                  ),
                ),
              ],
            ),
          ),
          ExperienceFormSection(
            title: '메모',
            bottomSpacing: 0,
            child: TextField(
              controller: _note,
              minLines: 3,
              maxLines: 3,
              decoration: specFieldDecoration(
                label: '메모 (선택)',
                hint: '자소서에 바로 쓰지 않을 메모',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
