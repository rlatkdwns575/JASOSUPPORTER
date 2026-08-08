import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 어학 성적 스펙 전용 입력 화면.
class LanguageSpecInputPanel extends StatefulWidget {
  const LanguageSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<LanguageSpecInputPanel> createState() => _LanguageSpecInputPanelState();
}

class _LanguageSpecInputPanelState extends State<LanguageSpecInputPanel> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _score = TextEditingController();
  final TextEditingController _issuer = TextEditingController();
  DateTime? _taken;
  DateTime? _expiry;

  @override
  void dispose() {
    _name.dispose();
    _score.dispose();
    _issuer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpecInputShell(
      kind: SpecAddKind.language,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_name.text.trim().isEmpty) {
          return '시험·어학 명칭을 입력해 주세요.';
        }
        if (_score.text.trim().isEmpty) {
          return '점수·등급을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () => <SpecItem>[
        SpecItemFactory.language(
          name: _name.text,
          score: _score.text,
          issuer: _issuer.text,
          taken: _taken,
          expiry: _expiry,
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
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _name,
                      decoration: specFieldDecoration(
                        label: '시험·어학 명칭',
                        hint: '예: TOEIC, OPIc, JLPT',
                      ),
                    ),
                    TextField(
                      controller: _score,
                      decoration: specFieldDecoration(
                        label: '점수·등급',
                        hint: '예: 850, IH, N2',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _issuer,
                  decoration: specFieldDecoration(
                    label: '주관·발급 기관 (선택)',
                    hint: '예: ETS, ACTFL',
                  ),
                ),
              ],
            ),
          ),
          ExperienceFormSection(
            title: '기간',
            bottomSpacing: 0,
            child: PeriodRangeFields(
              start: _taken,
              end: _expiry,
              enabled: widget.enabled,
              sectionLabel: '',
              startLabel: '응시 (yy.mm)',
              endLabel: '유효 (yy.mm)',
              onStartChanged: (DateTime? v) => setState(() => _taken = v),
              onEndChanged: (DateTime? v) => setState(() => _expiry = v),
              onClear: () => setState(() {
                _taken = null;
                _expiry = null;
              }),
            ),
          ),
        ],
      ),
    );
  }
}
