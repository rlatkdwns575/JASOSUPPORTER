import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 봉사 스펙 전용 입력 화면.
class VolunteerSpecInputPanel extends StatefulWidget {
  const VolunteerSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<VolunteerSpecInputPanel> createState() =>
      _VolunteerSpecInputPanelState();
}

class _VolunteerSpecInputPanelState extends State<VolunteerSpecInputPanel> {
  final TextEditingController _organization = TextEditingController();
  final TextEditingController _activity = TextEditingController();
  final TextEditingController _hours = TextEditingController();
  final TextEditingController _note = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _organization.dispose();
    _activity.dispose();
    _hours.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpecInputShell(
      kind: SpecAddKind.volunteer,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_organization.text.trim().isEmpty) {
          return '봉사 기관·활동명을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () => <SpecItem>[
        SpecItemFactory.volunteer(
          organizationOrTitle: _organization.text,
          activity: _activity.text,
          hours: _hours.text,
          note: _note.text,
          start: _start,
          end: _end,
        ),
      ],
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExperienceFormSection(
            title: '기본 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _organization,
                  decoration: specFieldDecoration(
                    label: '봉사 기관·활동명',
                    hint: '예: OO복지관, 헌혈 봉사',
                  ),
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _activity,
                      decoration: specFieldDecoration(
                        label: '활동 내용 (선택)',
                        hint: '예: 학습 멘토링, 환경 정화',
                      ),
                    ),
                    TextField(
                      controller: _hours,
                      decoration: specFieldDecoration(
                        label: '누적 시간 (선택)',
                        hint: '예: 120시간',
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
              startLabel: '시작 (yy.mm)',
              endLabel: '종료 (yy.mm)',
              onStartChanged: (DateTime? v) => setState(() => _start = v),
              onEndChanged: (DateTime? v) => setState(() => _end = v),
              onClear: () => setState(() {
                _start = null;
                _end = null;
              }),
            ),
          ),
          ExperienceFormSection(
            title: '메모',
            bottomSpacing: 0,
            child: TextField(
              controller: _note,
              minLines: 3,
              maxLines: 3,
              decoration: specFieldDecoration(
                label: '메모 (선택)',
                hint: '역할, 증빙 위치 등',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
