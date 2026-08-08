import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/other/military_other_input.dart';
import 'package:chatgptmini/features/experience/other/part_time_other_input.dart';
import 'package:chatgptmini/features/experience/other/personal_other_input.dart';
import 'package:flutter/material.dart';

/// 기타 경험 소분류 → 전용 입력 화면 라우터.
class OtherSubtypeInputPanel extends StatelessWidget {
  const OtherSubtypeInputPanel({
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
      ExperienceSubtype.partTime => PartTimeOtherInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.military => MilitaryOtherInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.personal => PersonalOtherInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
