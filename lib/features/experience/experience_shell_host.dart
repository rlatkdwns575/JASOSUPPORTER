import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/app/career_shell_actions.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/master_essay_selection_provider.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_card_dialogs.dart';
import 'package:chatgptmini/features/experience/experience_delete_dialog.dart';
import 'package:chatgptmini/features/experience/experience_form_workspace.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 경험·스펙 폼 워크스페이스 + provider/액션 배선.
class ExperienceShellHost extends ConsumerWidget {
  const ExperienceShellHost({
    super.key,
    required this.enabled,
    required this.focusCategory,
    this.focusSubtype,
    required this.onApplyResult,
    required this.onSnack,
    this.onInterviewFromExperience,
    this.onPortfolioOutline,
  });

  final bool enabled;
  final ExperienceCategory? focusCategory;
  final ExperienceSubtype? focusSubtype;
  final void Function(ShellActionResult result) onApplyResult;
  final ValueChanged<String> onSnack;
  final ValueChanged<Experience>? onInterviewFromExperience;
  final ValueChanged<Experience>? onPortfolioOutline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CareerShellActions actions = ref.read(careerShellActionsProvider);
    final List<Experience> experiences =
        ref.watch(experiencesProvider).value ?? const <Experience>[];
    final List<SpecItem> specs =
        ref.watch(specItemsProvider).value ?? const <SpecItem>[];

    return ExperienceFormWorkspace(
      enabled: enabled,
      focusCategory: focusCategory,
      focusSubtype: focusSubtype,
      savedExperiences: experiences,
      savedSpecs: specs,
      onDeleteSpec: (SpecItem item) async {
        onApplyResult(await actions.deleteSpecItem(item.id));
      },
      onSaveStructured: (List<Experience> exps, List<SpecItem> items) async {
        onApplyResult(
          actions.queueStructuredDraft(experiences: exps, specItems: items),
        );
      },
      onEditExperience: (Experience experience) async {
        await ExperienceCardDialogs.showEdit(
          context: context,
          experience: experience,
          onSave: (Experience next) async {
            onApplyResult(await actions.saveExperienceCard(next));
          },
        );
      },
      onDeleteExperience: (Experience experience) async {
        final bool confirmed = await ExperienceDeleteDialog.confirm(
          context: context,
          experience: experience,
        );
        if (!confirmed) {
          return;
        }
        onApplyResult(await actions.deleteExperienceCard(experience.id));
      },
      onDuplicateExperience: (Experience experience) async {
        onApplyResult(await actions.duplicateExperienceCard(experience));
      },
      onUseForEssay: (Experience experience) {
        ref.read(masterEssayPendingSelectionProvider.notifier).queue(experience.id);
        context.go(AppRoutes.masterResume);
        onSnack("'${experience.title}'을(를) Q1 경험 선택에 넣었습니다.");
      },
      onInterviewFromExperience: onInterviewFromExperience,
      onPortfolioOutline: onPortfolioOutline,
    );
  }
}
