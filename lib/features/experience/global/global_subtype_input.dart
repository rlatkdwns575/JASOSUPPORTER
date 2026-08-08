import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/global/exchange_global_input.dart';
import 'package:chatgptmini/features/experience/global/language_training_global_input.dart';
import 'package:chatgptmini/features/experience/global/working_holiday_global_input.dart';
import 'package:flutter/material.dart';

/// 글로벌 경험 소분류 → 전용 입력 화면 라우터.
class GlobalSubtypeInputPanel extends StatelessWidget {
  const GlobalSubtypeInputPanel({
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
      ExperienceSubtype.workingHoliday => WorkingHolidayGlobalInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.languageTraining => LanguageTrainingGlobalInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      ExperienceSubtype.exchange => ExchangeGlobalInputPanel(
          enabled: enabled,
          onQueueExperience: onQueueExperience,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
