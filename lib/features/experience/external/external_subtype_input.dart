import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/external/bootcamp_external_input.dart';
import 'package:chatgptmini/features/experience/external/external_project_external_input.dart';
import 'package:chatgptmini/features/experience/external/internship_external_input.dart';
import 'package:flutter/material.dart';

/// 교외활동 소분류 → 전용 입력 화면 라우터.
class ExternalSubtypeInputPanel extends StatelessWidget {
  const ExternalSubtypeInputPanel({
    super.key,
    required this.subtype,
    this.enabled = true,
    this.onQueueExperience,
  });

  final ExperienceSubtype subtype;
  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;

  @override
  Widget build(BuildContext context) {
    return switch (subtype) {
      ExperienceSubtype.internship => InternshipExternalInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.bootcamp => BootcampExternalInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.externalProject => ExternalProjectExternalInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
