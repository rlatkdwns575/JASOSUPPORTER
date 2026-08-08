import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_form_layout.dart';
import 'package:chatgptmini/features/experience/experience_form_section.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec/spec_input_shell.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 자격증 스펙 전용 입력 화면.
class CertificateSpecInputPanel extends StatefulWidget {
  const CertificateSpecInputPanel({
    super.key,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  State<CertificateSpecInputPanel> createState() =>
      _CertificateSpecInputPanelState();
}

class _CertificateSpecInputPanelState extends State<CertificateSpecInputPanel> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _issuer = TextEditingController();
  final TextEditingController _score = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _evidence = TextEditingController();
  DateTime? _acquired;
  DateTime? _expiry;

  @override
  void dispose() {
    _name.dispose();
    _issuer.dispose();
    _score.dispose();
    _number.dispose();
    _evidence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpecInputShell(
      kind: SpecAddKind.certificate,
      enabled: widget.enabled,
      onQueueSpecs: widget.onQueueSpecs,
      validate: () {
        if (_name.text.trim().isEmpty) {
          return '자격증 이름을 입력해 주세요.';
        }
        return null;
      },
      buildItems: () => <SpecItem>[
        SpecItemFactory.certificate(
          name: _name.text,
          issuer: _issuer.text,
          score: _score.text,
          licenseNumber: _number.text,
          evidence: _evidence.text,
          acquired: _acquired,
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
                        label: '자격증 이름',
                        hint: '예: 정보처리기사',
                      ),
                    ),
                    TextField(
                      controller: _issuer,
                      decoration: specFieldDecoration(
                        label: '발급·주관 기관 (선택)',
                        hint: '예: 한국산업인력공단',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ExperienceFormRow(
                  children: [
                    TextField(
                      controller: _score,
                      decoration: specFieldDecoration(
                        label: '점수·급수 (선택)',
                        hint: '예: 1급, 합격',
                      ),
                    ),
                    TextField(
                      controller: _number,
                      decoration: specFieldDecoration(
                        label: '자격번호 (선택)',
                        hint: '공개해도 되는 번호만',
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
              start: _acquired,
              end: _expiry,
              enabled: widget.enabled,
              sectionLabel: '',
              startLabel: '취득 (yy.mm)',
              endLabel: '만료 (yy.mm)',
              onStartChanged: (DateTime? v) => setState(() => _acquired = v),
              onEndChanged: (DateTime? v) => setState(() => _expiry = v),
              onClear: () => setState(() {
                _acquired = null;
                _expiry = null;
              }),
            ),
          ),
          ExperienceFormSection(
            title: '증빙',
            bottomSpacing: 0,
            child: TextField(
              controller: _evidence,
              minLines: 2,
              maxLines: 3,
              decoration: specFieldDecoration(
                label: '증빙 링크 (선택)',
                hint: '예: 자격증 조회 URL',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
