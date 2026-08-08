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

/// 개인적 경험 전용 입력 화면.
class PersonalOtherInputPanel extends StatefulWidget {
  const PersonalOtherInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<PersonalOtherInputPanel> createState() =>
      _PersonalOtherInputPanelState();
}

class _PersonalOtherInputPanelState extends State<PersonalOtherInputPanel> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _context = TextEditingController();
  final TextEditingController _org = TextEditingController();
  final TextEditingController _memo = TextEditingController();
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
    _title.dispose();
    _context.dispose();
    _org.dispose();
    _memo.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.personal);

    return OtherInputShell(
      subtype: ExperienceSubtype.personal,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_title.text.trim().isEmpty) {
          return '경험 제목을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => OtherExperienceFactory.personal(
        experienceTitle: _title.text,
        context: _context.text,
        organization: _org.text,
        memo: _memo.text,
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
                  controller: _title,
                  decoration: otherFieldDecoration(
                    label: '경험 제목',
                    hint: '예: 봉사활동, 개인 프로젝트',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _context,
                      decoration: otherFieldDecoration(
                        label: '역할 · 맥락',
                        hint: '예: 개인 프로젝트, 봉사 담당',
                      ),
                    ),
                    TextField(
                      controller: _org,
                      decoration: otherFieldDecoration(
                        label: '관련 단체 (선택)',
                        hint: '없으면 비워 두세요',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _memo,
                  minLines: 3,
                  maxLines: 4,
                  decoration: otherFieldDecoration(
                    label: '추가 메모 (선택)',
                    hint: '자소서에 바로 쓰지 않을 메모',
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
