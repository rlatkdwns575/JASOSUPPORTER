import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_util_fields.dart';
import 'package:chatgptmini/features/experience/global/global_experience_factory.dart';
import 'package:chatgptmini/features/experience/global/global_input_shell.dart';
import 'package:chatgptmini/features/experience/global/global_star_fields.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 워킹홀리데이 전용 입력 화면.
class WorkingHolidayGlobalInputPanel extends StatefulWidget {
  const WorkingHolidayGlobalInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<WorkingHolidayGlobalInputPanel> createState() =>
      _WorkingHolidayGlobalInputPanelState();
}

class _WorkingHolidayGlobalInputPanelState
    extends State<WorkingHolidayGlobalInputPanel> {
  final TextEditingController _place = TextEditingController();
  final TextEditingController _workplace = TextEditingController();
  final TextEditingController _activity = TextEditingController();
  final TextEditingController _language = TextEditingController();
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
    _place.dispose();
    _workplace.dispose();
    _activity.dispose();
    _language.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.workingHoliday);

    return GlobalInputShell(
      subtype: ExperienceSubtype.workingHoliday,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_place.text.trim().isEmpty) {
          return '국가·도시를 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => GlobalExperienceFactory.workingHoliday(
        place: _place.text,
        workplace: _workplace.text,
        activity: _activity.text,
        language: _language.text,
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
                  controller: _place,
                  decoration: globalFieldDecoration(
                    label: '국가·도시',
                    hint: '예: 캐나다 밴쿠버',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _workplace,
                      decoration: globalFieldDecoration(
                        label: '근무지·숙소 기관 (선택)',
                        hint: '예: 카페, 리조트, 호스텔',
                      ),
                    ),
                    TextField(
                      controller: _activity,
                      decoration: globalFieldDecoration(
                        label: '활동·직무',
                        hint: '예: 홀 서빙, 농장 보조',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _language,
                  decoration: globalFieldDecoration(
                    label: '사용 언어 (선택)',
                    hint: '예: 영어',
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
            child: GlobalStarFields(
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
              decoration: globalFieldDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
