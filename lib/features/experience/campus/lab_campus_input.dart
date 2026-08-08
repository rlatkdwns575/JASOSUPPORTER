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

/// 연구실 전용 입력 화면.
class LabCampusInputPanel extends StatefulWidget {
  const LabCampusInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<LabCampusInputPanel> createState() => _LabCampusInputPanelState();
}

class _LabCampusInputPanelState extends State<LabCampusInputPanel> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _professor = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _topic = TextEditingController();
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
    _name.dispose();
    _professor.dispose();
    _role.dispose();
    _topic.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.lab);

    return CampusInputShell(
      subtype: ExperienceSubtype.lab,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_name.text.trim().isEmpty) {
          return '연구실 이름을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => CampusExperienceFactory.lab(
        labName: _name.text,
        professor: _professor.text,
        role: _role.text,
        researchTopic: _topic.text,
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
                  controller: _name,
                  decoration: campusFieldDecoration(
                    label: '연구실 이름',
                    hint: '예: HCI Lab, 데이터마이닝 연구실',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _professor,
                      decoration: campusFieldDecoration(
                        label: '지도교수 (선택)',
                        hint: '예: OO 교수님',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: campusFieldDecoration(
                        label: '역할 · 참여 형태',
                        hint: '예: 학부연구생, 실험 담당',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _topic,
                  decoration: campusFieldDecoration(
                    label: '연구 주제 (선택)',
                    hint: '예: 추천 시스템, 센서 데이터 분석',
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
              decoration: campusFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
