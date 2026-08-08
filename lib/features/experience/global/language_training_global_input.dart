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

/// 어학연수 전용 입력 화면.
class LanguageTrainingGlobalInputPanel extends StatefulWidget {
  const LanguageTrainingGlobalInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueExperience,
  });

  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  State<LanguageTrainingGlobalInputPanel> createState() =>
      _LanguageTrainingGlobalInputPanelState();
}

class _LanguageTrainingGlobalInputPanelState
    extends State<LanguageTrainingGlobalInputPanel> {
  final TextEditingController _place = TextEditingController();
  final TextEditingController _institute = TextEditingController();
  final TextEditingController _course = TextEditingController();
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
    _institute.dispose();
    _course.dispose();
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
        StarFieldHints.forSubtype(ExperienceSubtype.languageTraining);

    return GlobalInputShell(
      subtype: ExperienceSubtype.languageTraining,
      enabled: widget.enabled,
      onQueueExperience: widget.onQueueExperience,
      validate: () {
        if (_place.text.trim().isEmpty) {
          return '국가·도시를 입력해 주세요.';
        }
        return null;
      },
      buildExperience: () => GlobalExperienceFactory.languageTraining(
        place: _place.text,
        institute: _institute.text,
        course: _course.text,
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
                    hint: '예: 미국 뉴욕, 일본 도쿄',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _institute,
                      decoration: globalFieldDecoration(
                        label: '학교·어학원 (선택)',
                        hint: '예: OO Language School',
                      ),
                    ),
                    TextField(
                      controller: _course,
                      decoration: globalFieldDecoration(
                        label: '과정·레벨',
                        hint: '예: Intensive, Intermediate',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _language,
                  decoration: globalFieldDecoration(
                    label: '학습 언어 (선택)',
                    hint: '예: 영어, 일본어',
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
