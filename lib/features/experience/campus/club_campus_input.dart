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

/// 동아리 전용 입력 화면.
class ClubCampusInputPanel extends StatefulWidget {
  const ClubCampusInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<ClubCampusInputPanel> createState() => _ClubCampusInputPanelState();
}

class _ClubCampusInputPanelState extends State<ClubCampusInputPanel> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _affiliation = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _scale = TextEditingController();
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
    _affiliation.dispose();
    _role.dispose();
    _scale.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.club);

    return CampusInputShell(
      subtype: ExperienceSubtype.club,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_name.text.trim().isEmpty) {
          return '동아리 이름을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => CampusExperienceFactory.club(
        clubName: _name.text,
        affiliation: _affiliation.text,
        role: _role.text,
        scale: _scale.text,
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
                    label: '동아리 이름',
                    hint: '예: OO동아리, 데이터분석학회',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _affiliation,
                      decoration: campusFieldDecoration(
                        label: '소속 대학·단과 (선택)',
                        hint: '예: OO대학교 공과대학',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: campusFieldDecoration(
                        label: '역할 · 참여 형태',
                        hint: '예: 회장, 기획팀장, 멤버',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _scale,
                  decoration: campusFieldDecoration(
                    label: '활동·팀 규모 (선택)',
                    hint: '예: 회원 30명, 기획팀 4명',
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
