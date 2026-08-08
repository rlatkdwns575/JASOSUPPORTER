import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/campus/class_project_campus_input.dart';
import 'package:chatgptmini/features/experience/campus/club_campus_input.dart';
import 'package:chatgptmini/features/experience/campus/lab_campus_input.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';

/// 교내활동 소분류 → 전용 입력 화면 라우터.
class CampusSubtypeInputPanel extends StatelessWidget {
  const CampusSubtypeInputPanel({
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
      ExperienceSubtype.club => ClubCampusInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.lab => LabCampusInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.classProject => ClassProjectCampusInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
