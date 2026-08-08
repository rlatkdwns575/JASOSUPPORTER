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

/// 인턴십 전용 입력 화면.
class InternshipExternalInputPanel extends StatefulWidget {
  const InternshipExternalInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<InternshipExternalInputPanel> createState() =>
      _InternshipExternalInputPanelState();
}

class _InternshipExternalInputPanelState
    extends State<InternshipExternalInputPanel> {
  final TextEditingController _company = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _role = TextEditingController();
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
    _company.dispose();
    _department.dispose();
    _role.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.internship);

    return ExternalInputShell(
      subtype: ExperienceSubtype.internship,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_company.text.trim().isEmpty) {
          return '기업·기관명을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => ExternalExperienceFactory.internship(
        companyName: _company.text,
        department: _department.text,
        role: _role.text,
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
                  controller: _company,
                  decoration: externalFieldDecoration(
                    label: '기업·기관명',
                    hint: '예: OO테크, OO연구소',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _department,
                      decoration: externalFieldDecoration(
                        label: '부서·팀 (선택)',
                        hint: '예: 플랫폼팀, 마케팅팀',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: externalFieldDecoration(
                        label: '역할 · 직무',
                        hint: '예: 백엔드 인턴, 기획 보조',
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
