import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_util_fields.dart';
import 'package:chatgptmini/features/experience/external/external_experience_factory.dart';
import 'package:chatgptmini/features/experience/external/external_input_shell.dart';
import 'package:chatgptmini/features/experience/external/external_star_fields.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 부트캠프 전용 입력 화면.
class BootcampExternalInputPanel extends StatefulWidget {
  const BootcampExternalInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<BootcampExternalInputPanel> createState() =>
      _BootcampExternalInputPanelState();
}

class _BootcampExternalInputPanelState
    extends State<BootcampExternalInputPanel> {
  final TextEditingController _program = TextEditingController();
  final TextEditingController _operator = TextEditingController();
  final TextEditingController _track = TextEditingController();
  final TextEditingController _tech = TextEditingController();
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
    _program.dispose();
    _operator.dispose();
    _track.dispose();
    _tech.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.bootcamp);

    return ExternalInputShell(
      subtype: ExperienceSubtype.bootcamp,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_program.text.trim().isEmpty) {
          return '부트캠프·프로그램명을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => ExternalExperienceFactory.bootcamp(
        programName: _program.text,
        operator: _operator.text,
        track: _track.text,
        techStackRaw: _tech.text,
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
                  controller: _program,
                  decoration: externalFieldDecoration(
                    label: '부트캠프·프로그램명',
                    hint: '예: 웹 풀스택 과정',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _operator,
                      decoration: externalFieldDecoration(
                        label: '운영 기관 (선택)',
                        hint: '예: OO코딩스쿨',
                      ),
                    ),
                    TextField(
                      controller: _track,
                      decoration: externalFieldDecoration(
                        label: '트랙·역할',
                        hint: '예: 풀스택 과정, 팀 리드',
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
            child: ExternalStarFields(
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
              techStacks: _tech,
              decoration: externalFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
