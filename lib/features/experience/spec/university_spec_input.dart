import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_gpa_fields.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 대학교 스펙 전용 입력 화면.
class UniversitySpecInputPanel extends StatefulWidget {
  const UniversitySpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<UniversitySpecInputPanel> createState() =>
      _UniversitySpecInputPanelState();
}

class _UniversitySpecInputPanelState extends State<UniversitySpecInputPanel> {
  final TextEditingController _school = TextEditingController();
  final TextEditingController _major = TextEditingController();
  final TextEditingController _college = TextEditingController();
  final TextEditingController _minor = TextEditingController();
  final TextEditingController _double = TextEditingController();
  final TextEditingController _courses = TextEditingController();
  final TextEditingController _gpaScore = TextEditingController();
  final TextEditingController _gpaOther = TextEditingController();
  String _status = '재학';
  String _gpaFullMark = '4.5';
  DateTime? _start;
  DateTime? _end;

  static const List<String> _statusOptions = ['재학', '휴학', '졸업', '수료'];

  @override
  void dispose() {
    _school.dispose();
    _major.dispose();
    _college.dispose();
    _minor.dispose();
    _double.dispose();
    _courses.dispose();
    _gpaScore.dispose();
    _gpaOther.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SpecGpaFields gpaFields = SpecGpaFields(
      score: _gpaScore,
      fullMarkChoice: _gpaFullMark,
      fullMarkOther: _gpaOther,
      enabled: widget.enabled,
      onFullMarkChanged: (String v) => setState(() => _gpaFullMark = v),
    );

    return SpecInputShell(
      kind: SpecAddKind.university,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_school.text.trim().isEmpty) {
          return '대학교명을 입력해 주세요.';
        }
        if (_major.text.trim().isEmpty) {
          return '학과(전공)를 입력해 주세요.';
        }
        if (_gpaFullMark == '기타' &&
            _gpaScore.text.trim().isNotEmpty &&
            _gpaOther.text.trim().isEmpty) {
          return '만점 기준을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () {
        final String detail = [
          if (_college.text.trim().isNotEmpty) _college.text.trim(),
          _major.text.trim(),
          if (_minor.text.trim().isNotEmpty) '부전공 ${_minor.text.trim()}',
          if (_double.text.trim().isNotEmpty) '복수전공 ${_double.text.trim()}',
          if (_courses.text.trim().isNotEmpty) '수업 ${_courses.text.trim()}',
        ].join(' · ');
        final List<SpecItem> items = <SpecItem>[
          SpecItemFactory.school(
            kind: SpecAddKind.university,
            schoolName: _school.text,
            detail: detail,
            status: _status,
            start: _start,
            end: _end,
          ),
        ];
        final SpecItem? gpa = gpaFields.buildItem();
        if (gpa != null) {
          items.add(gpa);
        }
        return items;
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
                    label: '대학교명',
                    hint: '예: OO대학교',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _college,
                      decoration: specFieldDecoration(
                        label: '단과대학 (선택)',
                        hint: '예: 공과대학',
                      ),
                    ),
                    TextField(
                      controller: _major,
                      decoration: specFieldDecoration(
                        label: '학과·전공',
                        hint: '예: 컴퓨터공학과',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _minor,
                      decoration: specFieldDecoration(
                        label: '부전공 (선택)',
                        hint: '예: 경영학',
                      ),
                    ),
                    TextField(
                      controller: _double,
                      decoration: specFieldDecoration(
                        label: '복수전공 (선택)',
                        hint: '예: 데이터사이언스',
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
              endLabel: '졸업/현재 (yy.mm)',
              onStartChanged: (DateTime? v) => setState(() => _start = v),
              onEndChanged: (DateTime? v) => setState(() => _end = v),
              onClear: () => setState(() {
                _start = null;
                _end = null;
              }),
            ),
          ),
          ExperienceFormSection(
            title: '주요 수업',
            child: TextField(
              controller: _courses,
              minLines: 3,
              maxLines: 5,
              decoration: specFieldDecoration(
                label: '주요 수업 (선택)',
                hint: '예: 알고리즘, 데이터베이스',
              ),
            ),
          ),
          ExperienceFormSection(
            title: '학점',
            bottomSpacing: 0,
            child: gpaFields,
          ),
        ],
      ),
    );
  }
}
