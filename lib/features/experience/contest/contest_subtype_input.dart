import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/contest/award_contest_input.dart';
import 'package:chatgptmini/features/experience/contest/contest_entry_contest_input.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';

/// 수상·공모전 소분류 → 전용 입력 화면 라우터.
class ContestSubtypeInputPanel extends StatelessWidget {
  const ContestSubtypeInputPanel({
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
      ExperienceSubtype.award => AwardContestInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.contestEntry => ContestEntryContestInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
