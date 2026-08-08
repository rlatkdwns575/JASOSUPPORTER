import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_util_fields.dart';
import 'package:chatgptmini/features/experience/other/other_experience_factory.dart';
import 'package:chatgptmini/features/experience/other/other_input_shell.dart';
import 'package:chatgptmini/features/experience/other/other_star_fields.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 아르바이트 전용 입력 화면.
class PartTimeOtherInputPanel extends StatefulWidget {
  const PartTimeOtherInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<PartTimeOtherInputPanel> createState() =>
      _PartTimeOtherInputPanelState();
}

class _PartTimeOtherInputPanelState extends State<PartTimeOtherInputPanel> {
  final TextEditingController _primary = TextEditingController();
  final TextEditingController _workplace = TextEditingController();
  final TextEditingController _role = TextEditingController();
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
    _primary.dispose();
    _workplace.dispose();
    _role.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.partTime);

    return OtherInputShell(
      subtype: ExperienceSubtype.partTime,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_primary.text.trim().isEmpty) {
          return '근무지·담당 업무를 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => OtherExperienceFactory.partTime(
        workplaceOrDuty: _primary.text,
        workplace: _workplace.text,
        role: _role.text,
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
                  controller: _primary,
                  decoration: otherFieldDecoration(
                    label: '근무지·담당 업무',
                    hint: '예: 카페 아르바이트, 매장 스태프',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _workplace,
                      decoration: otherFieldDecoration(
                        label: '근무지명 (선택)',
                        hint: '예: OO카페',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: otherFieldDecoration(
                        label: '역할 · 담당 업무',
                        hint: '예: 홀 서빙, 재고 관리',
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
            child: OtherStarFields(
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
              decoration: otherFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
