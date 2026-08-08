import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/spec/certificate_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/grad_school_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/high_school_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/language_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/other_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/scholarship_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/university_spec_input.dart';
import 'package:chatgptmini/features/experience/spec/volunteer_spec_input.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';

/// 스펙 소분류 → 전용 입력 화면 라우터.
class SpecSubtypeInputPanel extends StatelessWidget {
  const SpecSubtypeInputPanel({
    super.key,
    required this.kind,
    this.enabled = true,
    this.onQueueSpecs,
  });

  final SpecAddKind kind;
  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      SpecAddKind.highSchool => HighSchoolSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.university => UniversitySpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.gradSchool => GradSchoolSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.certificate => CertificateSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.language => LanguageSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.scholarship => ScholarshipSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.volunteer => VolunteerSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
      SpecAddKind.other => OtherSpecInputPanel(
          enabled: enabled,
          onQueueSpecs: onQueueSpecs,
        ),
    };
  }
}
