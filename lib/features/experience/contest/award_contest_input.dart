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

/// 수상 전용 입력 화면.
class AwardContestInputPanel extends StatefulWidget {
  const AwardContestInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<AwardContestInputPanel> createState() => _AwardContestInputPanelState();
}

class _AwardContestInputPanelState extends State<AwardContestInputPanel> {
  final TextEditingController _event = TextEditingController();
  final TextEditingController _organizer = TextEditingController();
  final TextEditingController _award = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _situation = TextEditingController();
  final TextEditingController _task = TextEditingController();
  final TextEditingController _action = TextEditingController();
  final TextEditingController _result = TextEditingController();
  final TextEditingController _learned = TextEditingController();
  final TextEditingController _competencyTags = TextEditingController();
  final TextEditingController _evidenceLinks = TextEditingController();
  String _participation = '팀';
  DateTime? _start;
  DateTime? _end;

  static const List<String> _participationOptions = ['팀', '개인'];

  @override
  void dispose() {
    _event.dispose();
    _organizer.dispose();
    _award.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.award);

    return ContestInputShell(
      subtype: ExperienceSubtype.award,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_event.text.trim().isEmpty) {
          return '대회·행사 명칭을 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => ContestExperienceFactory.award(
        eventName: _event.text,
        organizer: _organizer.text,
        awardResult: _award.text,
        role: '$_participation · ${_role.text.trim()}'.trim(),
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
                  controller: _event,
                  decoration: contestFieldDecoration(
                    label: '대회·행사 명칭',
                    hint: '예: OO 해커톤, OO 학술대회',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _organizer,
                      decoration: contestFieldDecoration(
                        label: '주최·주관 (선택)',
                        hint: '예: OO기관, OO학회',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _participation,
                      decoration: contestFieldDecoration(label: '참가 형태'),
                      items: [
                        for (final String opt in _participationOptions)
                          DropdownMenuItem<String>(
                            value: opt,
                            child: Text(opt),
                          ),
                      ],
                      onChanged: widget.enabled
                          ? (String? v) {
                              if (v != null) {
                                setState(() => _participation = v);
                              }
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _award,
                      decoration: contestFieldDecoration(
                        label: '수상 결과',
                        hint: '예: 대상, 우수상, 장려상',
                      ),
                    ),
                    TextField(
                      controller: _role,
                      decoration: contestFieldDecoration(
                        label: '역할 · 담당',
                        hint: '예: 팀장, 발표',
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
