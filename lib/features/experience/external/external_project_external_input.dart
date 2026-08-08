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

/// 외부 프로젝트 전용 입력 화면.
class ExternalProjectExternalInputPanel extends StatefulWidget {
  const ExternalProjectExternalInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<ExternalProjectExternalInputPanel> createState() =>
      _ExternalProjectExternalInputPanelState();
}

class _ExternalProjectExternalInputPanelState
    extends State<ExternalProjectExternalInputPanel> {
  final TextEditingController _project = TextEditingController();
  final TextEditingController _team = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _tech = TextEditingController();
  final TextEditingController _evidenceLinks = TextEditingController();
  final TextEditingController _situation = TextEditingController();
  final TextEditingController _task = TextEditingController();
  final TextEditingController _action = TextEditingController();
  final TextEditingController _result = TextEditingController();
  final TextEditingController _learned = TextEditingController();
  final TextEditingController _competencyTags = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _project.dispose();
    _team.dispose();
    _role.dispose();
    _tech.dispose();
    _evidenceLinks.dispose();
    _situation.dispose();
    _task.dispose();
    _action.dispose();
    _result.dispose();
    _learned.dispose();
    _competencyTags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StarFieldHints hints =
        StarFieldHints.forSubtype(ExperienceSubtype.externalProject);

    return ExternalInputShell(
      subtype: ExperienceSubtype.externalProject,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_project.text.trim().isEmpty) {
          return '프로젝트명을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => ExternalExperienceFactory.externalProject(
        projectName: _project.text,
        teamOrClient: _team.text,
        role: _role.text,
        techStackRaw: _tech.text,
        evidenceRaw: _evidenceLinks.text,
        start: _start,
        end: _end,
        situation: _situation.text,
        task: _task.text,
        action: _action.text,
        result: _result.text,
        learned: _learned.text,
        competencyTags: ExperienceUtilFields.splitCsv(_competencyTags.text),
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
                  controller: _project,
                  decoration: externalFieldDecoration(
                    label: '프로젝트명',
                    hint: '예: 커리어 포트폴리오 앱',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _team,
                      decoration: externalFieldDecoration(
                        label: '팀·클라이언트 (선택)',
                        hint: '예: 사이드 프로젝트, OO사',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: externalFieldDecoration(
                        label: '역할 · 담당',
                        hint: '예: 백엔드, 기획',
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
