import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_gpa_fields.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 대학원 스펙 전용 입력 화면.
class GradSchoolSpecInputPanel extends StatefulWidget {
  const GradSchoolSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<GradSchoolSpecInputPanel> createState() =>
      _GradSchoolSpecInputPanelState();
}

class _GradSchoolSpecInputPanelState extends State<GradSchoolSpecInputPanel> {
  final TextEditingController _school = TextEditingController();
  final TextEditingController _major = TextEditingController();
  final TextEditingController _research = TextEditingController();
  final TextEditingController _courses = TextEditingController();
  final TextEditingController _gpaScore = TextEditingController();
  final TextEditingController _gpaOther = TextEditingController();
  String _degree = '석사';
  String _status = '재학';
  String _gpaFullMark = '4.5';
  DateTime? _start;
  DateTime? _end;

  static const List<String> _degreeOptions = ['석사', '박사', '석·박 통합'];
  static const List<String> _statusOptions = ['재학', '휴학', '수료', '졸업'];

  @override
  void dispose() {
    _school.dispose();
    _major.dispose();
    _research.dispose();
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
      kind: SpecAddKind.gradSchool,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_school.text.trim().isEmpty) {
          return '대학원(학교)명을 입력해 주세요.';
        }
        if (_major.text.trim().isEmpty) {
          return '전공·연구 분야를 입력해 주세요.';
        }
        if (_gpaFullMark == '기타' &&
            _gpaScore.text.trim().isNotEmpty &&
            _gpaOther.text.trim().isEmpty) {
          return '만점 기준을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () {
        final List<SpecItem> items = <SpecItem>[
          SpecItemFactory.school(
            kind: SpecAddKind.gradSchool,
            schoolName: _school.text,
            detail: [
              _degree,
              _major.text.trim(),
              if (_research.text.trim().isNotEmpty)
                '연구 ${_research.text.trim()}',
              if (_courses.text.trim().isNotEmpty)
                '수업 ${_courses.text.trim()}',
            ].join(' · '),
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
                    label: '대학원·학교명',
                    hint: '예: OO대학교 대학원',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _degree,
                      decoration: specFieldDecoration(label: '과정'),
                      items: [
                        for (final String opt in _degreeOptions)
                          DropdownMenuItem<String>(
                            value: opt,
                            child: Text(opt),
                          ),
                      ],
                      onChanged: widget.enabled
                          ? (String? v) {
                              if (v != null) {
                                setState(() => _degree = v);
                              }
                            }
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: specFieldDecoration(label: '상태'),
                      items: [
                        for (final String opt in _statusOptions)
                          DropdownMenuItem<String>(
                            value: opt,
                            child: Text(opt),
                          ),
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
                const SizedBox(height: 10),
                TextField(
                  controller: _major,
                  decoration: specFieldDecoration(
                    label: '전공·연구 분야',
                    hint: '예: 인공지능학과, 데이터사이언스',
                  ),
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
            title: '세부 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _research,
                  minLines: 3,
                  maxLines: 5,
                  decoration: specFieldDecoration(
                    label: '연구 주제 (선택)',
                    hint: '예: 추천 시스템, NLP',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _courses,
                  minLines: 3,
                  maxLines: 5,
                  decoration: specFieldDecoration(
                    label: '주요 수업 (선택)',
                    hint: '예: 심층학습, 통계추론',
                  ),
                ),
              ],
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
