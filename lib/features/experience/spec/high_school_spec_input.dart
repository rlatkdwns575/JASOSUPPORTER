import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 고등학교 스펙 전용 입력 화면.
class HighSchoolSpecInputPanel extends StatefulWidget {
  const HighSchoolSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<HighSchoolSpecInputPanel> createState() =>
      _HighSchoolSpecInputPanelState();
}

class _HighSchoolSpecInputPanelState extends State<HighSchoolSpecInputPanel> {
  final TextEditingController _school = TextEditingController();
  final TextEditingController _track = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final TextEditingController _activities = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  String _status = '졸업';
  DateTime? _start;
  DateTime? _end;

  static const List<String> _statusOptions = ['재학', '졸업', '중퇴'];

  @override
  void dispose() {
    _school.dispose();
    _track.dispose();
    _region.dispose();
    _activities.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpecInputShell(
      kind: SpecAddKind.highSchool,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_school.text.trim().isEmpty) {
          return '고등학교명을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () {
        final String detail = [
          if (_track.text.trim().isNotEmpty) _track.text.trim(),
          if (_region.text.trim().isNotEmpty) _region.text.trim(),
          if (_activities.text.trim().isNotEmpty)
            '활동: ${_activities.text.trim()}',
          if (_notes.text.trim().isNotEmpty) '메모: ${_notes.text.trim()}',
        ].join(' · ');
        return <SpecItem>[
          SpecItemFactory.school(
            kind: SpecAddKind.highSchool,
            schoolName: _school.text,
            detail: detail,
            status: _status,
            start: _start,
            end: _end,
          ),
        ];
      },
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceFormSection(
            title: '기본 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _school,
                  decoration: specFieldDecoration(
                    label: '고등학교명',
                    hint: '예: OO고등학교',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _track,
                      decoration: specFieldDecoration(
                        label: '계열·과정 (선택)',
                        hint: '예: 문과, 이과, 특성화',
                      ),
                    ),
                    TextField(
                      controller: _region,
                      decoration: specFieldDecoration(
                        label: '지역 (선택)',
                        hint: '예: 서울, 경기 수원',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: specFieldDecoration(label: '상태'),
                  items: [
                    for (final String opt in _statusOptions)
                      DropdownMenuItem<String>(value: opt, child: Text(opt)),
                  ],
                  onChanged: widget.enabled
                      ? (String? v) {
                          if (v != null) {
                            setState(() => _status = v);
                          }
                        }
                      : null,
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
              startLabel: '입학 (yy.mm)',
              endLabel: '졸업/종료 (yy.mm)',
              onStartChanged: (DateTime? v) => setState(() => _start = v),
              onEndChanged: (DateTime? v) => setState(() => _end = v),
              onClear: () => setState(() {
                _start = null;
                _end = null;
              }),
            ),
          ),
          ExperienceFormSection(
            title: '세부 정보',
            bottomSpacing: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _activities,
                  minLines: 3,
                  maxLines: 5,
                  decoration: specFieldDecoration(
                    label: '주요 활동 (선택)',
                    hint: '예: 동아리, 학생회, 봉사',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 5,
                  decoration: specFieldDecoration(
                    label: '특이 사항 (선택)',
                    hint: '자소서에 바로 쓰지 않을 메모',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
