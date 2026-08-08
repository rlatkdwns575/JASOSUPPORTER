import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/contest/contest_experience_factory.dart';
import 'package:chatgptmini/features/experience/contest/contest_input_shell.dart';
import 'package:chatgptmini/features/experience/contest/contest_star_fields.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_util_fields.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 공모전 전용 입력 화면.
class ContestEntryContestInputPanel extends StatefulWidget {
  const ContestEntryContestInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<ContestEntryContestInputPanel> createState() =>
      _ContestEntryContestInputPanelState();
}

class _ContestEntryContestInputPanelState
    extends State<ContestEntryContestInputPanel> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _organizer = TextEditingController();
  final TextEditingController _participation = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _outcome = TextEditingController();
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
    _name.dispose();
    _organizer.dispose();
    _participation.dispose();
    _role.dispose();
    _outcome.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.contestEntry);

    return ContestInputShell(
      subtype: ExperienceSubtype.contestEntry,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_name.text.trim().isEmpty) {
          return '공모전 명칭을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => ContestExperienceFactory.contestEntry(
        contestName: _name.text,
        organizer: _organizer.text,
        participation: _participation.text,
        role: _role.text,
        outcome: _outcome.text,
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
                  controller: _name,
                  decoration: contestFieldDecoration(
                    label: '공모전 명칭',
                    hint: '예: OO 아이디어 공모전',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _organizer,
                      decoration: contestFieldDecoration(
                        label: '주최·주관 (선택)',
                        hint: '예: OO재단',
                      ),
                    ),
                    TextField(
                      controller: _participation,
                      decoration: contestFieldDecoration(
                        label: '참가 형태',
                        hint: '예: 팀, 개인',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _role,
                      decoration: contestFieldDecoration(
                        label: '역할 · 담당',
                        hint: '예: 기획, 발표',
                      ),
                    ),
                    TextField(
                      controller: _outcome,
                      decoration: contestFieldDecoration(
                        label: '결과 (선택)',
                        hint: '예: 본선, 미수상, 장려상',
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
            child: ContestStarFields(
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
              decoration: contestFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
