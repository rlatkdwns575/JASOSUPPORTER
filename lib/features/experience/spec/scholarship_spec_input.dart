import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 장학 스펙 전용 입력 화면.
class ScholarshipSpecInputPanel extends StatefulWidget {
  const ScholarshipSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<ScholarshipSpecInputPanel> createState() =>
      _ScholarshipSpecInputPanelState();
}

class _ScholarshipSpecInputPanelState extends State<ScholarshipSpecInputPanel> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _organization = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _name.dispose();
    _organization.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpecInputShell(
      kind: SpecAddKind.scholarship,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_name.text.trim().isEmpty) {
          return '장학 명칭을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () => <SpecItem>[
        SpecItemFactory.scholarship(
          name: _name.text,
          organization: _organization.text,
          amount: _amount.text,
          note: _note.text,
          start: _start,
          end: _end,
        ),
      ],
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceFormSection(
            title: '기본 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _name,
                  decoration: specFieldDecoration(
                    label: '장학 명칭',
                    hint: '예: 성적우수장학, 교내 장학금',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _organization,
                      decoration: specFieldDecoration(
                        label: '수여·주관 기관 (선택)',
                        hint: '예: OO대학교, OO재단',
                      ),
                    ),
                    TextField(
                      controller: _amount,
                      decoration: specFieldDecoration(
                        label: '금액·혜택 (선택)',
                        hint: '예: 등록금 전액, 학기당 100만 원',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ExperienceFormSection(
            title: '기간',
            child: PeriodRangeFields(
              start: _start,
              end: _end,
              enabled: widget.enabled,
              sectionLabel: '',
              startLabel: '시작 (yy.mm)',
              endLabel: '종료 (yy.mm)',
              onStartChanged: (DateTime? v) => setState(() => _start = v),
              onEndChanged: (DateTime? v) => setState(() => _end = v),
              onClear: () => setState(() {
                _start = null;
                _end = null;
              }),
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
                hint: '선정 기준, 활용 메모 등',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
