import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_library_panel.dart';
import 'package:chatgptmini/features/experience/experience_spec_form.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';

/// 경험·스펙 입력 폼 + (유형 선택 시에만) 하단 라이브러리 패널.
class ExperienceFormWorkspace extends StatelessWidget {
  const ExperienceFormWorkspace({
    super.key,
    required this.enabled,
    required this.focusCategory,
    this.focusSubtype,
    required this.savedExperiences,
    required this.savedSpecs,
    required this.onDeleteSpec,
    required this.onSaveStructured,
    required this.onEditExperience,
    required this.onDeleteExperience,
    required this.onDuplicateExperience,
    required this.onUseForEssay,
    this.onInterviewFromExperience,
    this.onPortfolioOutline,
  });

  final bool enabled;
  final ExperienceCategory? focusCategory;
  final ExperienceSubtype? focusSubtype;
  final List<Experience> savedExperiences;
  final List<SpecItem> savedSpecs;
  final ValueChanged<SpecItem> onDeleteSpec;
  final Future<void> Function(List<Experience> experiences, List<SpecItem> specItems)
      onSaveStructured;
  final ValueChanged<Experience> onEditExperience;
  final ValueChanged<Experience> onDeleteExperience;
  final ValueChanged<Experience> onDuplicateExperience;
  final ValueChanged<Experience> onUseForEssay;
  final ValueChanged<Experience>? onInterviewFromExperience;
  final ValueChanged<Experience>? onPortfolioOutline;

  @override
  Widget build(BuildContext context) {
    // 실제 입력 중에는 하단 라이브러리를 숨겨 폼에 공간을 준다.
    final bool showLibrary = focusSubtype == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ExperienceSpecForm(
            enabled: enabled,
            focusCategory: focusCategory,
            focusSubtype: focusSubtype,
            onSaveStructured: onSaveStructured,
          ),
        ),
        if (showLibrary)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ExperienceLibraryPanel(
              experiences: savedExperiences,
              specs: savedSpecs,
              enabled: enabled,
              onDeleteSpec: onDeleteSpec,
              onEdit: onEditExperience,
              onDelete: onDeleteExperience,
              onDuplicate: onDuplicateExperience,
              onUseForEssay: onUseForEssay,
              onInterviewFromExperience: onInterviewFromExperience,
              onPortfolioOutline: onPortfolioOutline,
            ),
          ),
      ],
    );
  }
}
