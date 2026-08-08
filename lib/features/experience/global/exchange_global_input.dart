import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_util_fields.dart';
import 'package:chatgptmini/features/experience/global/global_experience_factory.dart';
import 'package:chatgptmini/features/experience/global/global_input_shell.dart';
import 'package:chatgptmini/features/experience/global/global_star_fields.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 교환학생 전용 입력 화면.
class ExchangeGlobalInputPanel extends StatefulWidget {
  const ExchangeGlobalInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<ExchangeGlobalInputPanel> createState() =>
      _ExchangeGlobalInputPanelState();
}

class _ExchangeGlobalInputPanelState extends State<ExchangeGlobalInputPanel> {
  final TextEditingController _place = TextEditingController();
  final TextEditingController _university = TextEditingController();
  final TextEditingController _program = TextEditingController();
  final TextEditingController _major = TextEditingController();
  final TextEditingController _situation = TextEditingController();
  final TextEditingController _task = TextEditingController();
  final TextEditingController _action = TextEditingController();
  final TextEditingController _result = TextEditingController();
  final TextEditingController _learned = TextEditingController();
  final TextEditingController _competencyTags = TextEditingController();
  final TextEditingController _evidenceLinks = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _place.dispose();
    _university.dispose();
    _program.dispose();
    _major.dispose();
    _situation.dispose();
    _task.dispose();
    _action.dispose();
    _result.dispose();
    _learned.dispose();
    _competencyTags.dispose();
    _evidenceLinks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StarFieldHints hints =
        StarFieldHints.forSubtype(ExperienceSubtype.exchange);

    return GlobalInputShell(
      subtype: ExperienceSubtype.exchange,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_place.text.trim().isEmpty) {
          return '국가·도시를 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => GlobalExperienceFactory.exchange(
        place: _place.text,
        university: _university.text,
        program: _program.text,
        major: _major.text,
        start: _start,
        end: _end,
        situation: _situation.text,
        task: _task.text,
        action: _action.text,
        result: _result.text,
        learned: _learned.text,
        competencyTags: ExperienceUtilFields.splitCsv(_competencyTags.text),
        evidenceLinks: ExperienceUtilFields.splitCsv(_evidenceLinks.text),
      ),
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceFormSection(
            title: '기본 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _place,
                  decoration: globalFieldDecoration(
                    label: '국가·도시',
                    hint: '예: 독일 베를린',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _university,
                      decoration: globalFieldDecoration(
                        label: '교환 학교 (선택)',
                        hint: '예: OO University',
                      ),
                    ),
                    TextField(
                      controller: _program,
                      decoration: globalFieldDecoration(
                        label: '프로그램·학기',
                        hint: '예: Exchange Fall 2024',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _major,
                  decoration: globalFieldDecoration(
                    label: '수강·전공 분야 (선택)',
                    hint: '예: Computer Science',
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
              onStartChanged: (DateTime? d) => setState(() => _start = d),
              onEndChanged: (DateTime? d) => setState(() => _end = d),
              onClear: () => setState(() {
                _start = null;
                _end = null;
              }),
            ),
          ),
          ExperienceFormSection(
            title: '경험 내용 (STAR)',
            child: GlobalStarFields(
              situation: _situation,
              task: _task,
              action: _action,
              result: _result,
              learned: _learned,
              hints: hints,
            ),
          ),
          ExperienceFormSection(
            title: '활용 정보',
            bottomSpacing: 0,
            child: ExperienceUtilFields(
              competencyTags: _competencyTags,
              evidenceLinks: _evidenceLinks,
              decoration: globalFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
