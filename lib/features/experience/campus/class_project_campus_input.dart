import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/campus/campus_experience_factory.dart';
import 'package:chatgptmini/features/experience/campus/campus_input_shell.dart';
import 'package:chatgptmini/features/experience/campus/campus_star_fields.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_util_fields.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 수업 프로젝트 전용 입력 화면.
class ClassProjectCampusInputPanel extends StatefulWidget {
  const ClassProjectCampusInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<ClassProjectCampusInputPanel> createState() =>
      _ClassProjectCampusInputPanelState();
}

class _ClassProjectCampusInputPanelState
    extends State<ClassProjectCampusInputPanel> {
  final TextEditingController _project = TextEditingController();
  final TextEditingController _course = TextEditingController();
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
    _project.dispose();
    _course.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.classProject);

    return CampusInputShell(
      subtype: ExperienceSubtype.classProject,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_project.text.trim().isEmpty) {
          return '프로젝트 이름을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => CampusExperienceFactory.classProject(
        projectName: _project.text,
        courseName: _course.text,
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
                  controller: _project,
                  decoration: campusFieldDecoration(
                    label: '프로젝트 이름',
                    hint: '예: 캡스톤 웹 서비스, 팀 과제',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _course,
                      decoration: campusFieldDecoration(
                        label: '수업 이름',
                        hint: '예: 소프트웨어공학, 데이터베이스',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: campusFieldDecoration(
                        label: '역할 · 담당',
                        hint: '예: 프론트엔드, 발표 담당',
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
            child: CampusStarFields(
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
              decoration: campusFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
