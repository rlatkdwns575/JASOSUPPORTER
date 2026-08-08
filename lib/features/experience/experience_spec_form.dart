import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/campus/campus_subtype_input.dart';
import 'package:chatgptmini/features/experience/contest/contest_subtype_input.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/experience_subtype_picker.dart';
import 'package:chatgptmini/features/experience/external/external_subtype_input.dart';
import 'package:chatgptmini/features/experience/global/global_subtype_input.dart';
import 'package:chatgptmini/features/experience/other/other_subtype_input.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:chatgptmini/features/experience/spec_subtype_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 경험·스펙 구조화 입력 라우터.
///
/// 허브에서 고른 대분류 → 소분류 → 전용 입력 화면으로만 연결한다.
/// 대분류 선택은 허브(`/experience`)에만 둔다.
class ExperienceSpecForm extends StatelessWidget {
  const ExperienceSpecForm({
    super.key,
    required this.enabled,
    required this.onSaveStructured,
    this.focusCategory,
    this.focusSubtype,
  });

  final bool enabled;
  final Future<void> Function(
    List<Experience> experiences,
    List<SpecItem> specItems,
  ) onSaveStructured;
  final ExperienceCategory? focusCategory;
  final ExperienceSubtype? focusSubtype;

  void _queueExperience(Experience item) {
    onSaveStructured(<Experience>[item], const <SpecItem>[]);
  }

  void _queueSpecs(List<SpecItem> items) {
    onSaveStructured(const <Experience>[], items);
  }

  @override
  Widget build(BuildContext context) {
    final ExperienceCategory? focus = focusCategory;
    final ExperienceSubtype? subtype = focusSubtype;

    if (focus == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppRoutes.experience);
        }
      });
      return const SizedBox.shrink();
    }

    if (subtype == null || subtype.category != focus) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        child: ExperienceSubtypePicker(
          category: focus,
          enabled: enabled,
        ),
      );
    }

    final SpecAddKind? specKind = SpecAddKind.fromSubtype(subtype);
    if (specKind != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        child: SpecSubtypeInputPanel(
          kind: specKind,
          enabled: enabled,
          onQueueSpecs: enabled ? _queueSpecs : null,
        ),
      );
    }

    final Widget panel = switch (focus) {
      ExperienceCategory.campus => CampusSubtypeInputPanel(
          subtype: subtype,
          enabled: enabled,
          onQueueExperience: enabled ? _queueExperience : null,
        ),
      ExperienceCategory.external => ExternalSubtypeInputPanel(
          subtype: subtype,
          enabled: enabled,
          onQueueExperience: enabled ? _queueExperience : null,
        ),
      ExperienceCategory.global => GlobalSubtypeInputPanel(
          subtype: subtype,
          enabled: enabled,
          onQueueExperience: enabled ? _queueExperience : null,
        ),
      ExperienceCategory.other => OtherSubtypeInputPanel(
          subtype: subtype,
          enabled: enabled,
          onQueueExperience: enabled ? _queueExperience : null,
        ),
      ExperienceCategory.contest => ContestSubtypeInputPanel(
          subtype: subtype,
          enabled: enabled,
          onQueueExperience: enabled ? _queueExperience : null,
        ),
      ExperienceCategory.spec => const SizedBox.shrink(),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: panel,
    );
  }
}
