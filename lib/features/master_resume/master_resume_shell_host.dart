import 'package:chatgptmini/app/career_shell_actions.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/utils/prompt_send.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/chat_providers.dart';
import 'package:chatgptmini/data/providers/master_essay_selection_provider.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:chatgptmini/features/master_resume/essay_version_picker_dialog.dart';
import 'package:chatgptmini/features/master_resume/master_essay_prompt_planner.dart';
import 'package:chatgptmini/features/master_resume/master_resume_workspace.dart';
import 'package:chatgptmini/features/master_resume/master_resume_workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마스터 자소서 워크스페이스 + 저장/프롬프트 배선.
class MasterResumeShellHost extends ConsumerWidget {
  const MasterResumeShellHost({
    super.key,
    required this.workspace,
    required this.enabled,
    required this.onSendPrompt,
    required this.onApplyResult,
    required this.onSnack,
  });

  final MasterResumeWorkspaceController workspace;
  final bool enabled;
  final void Function(String prompt, {List<String> selectedExperienceIds})
      onSendPrompt;
  final void Function(ShellActionResult result) onApplyResult;
  final ValueChanged<String> onSnack;

  void _runPlan(
    MasterEssayPromptPlan plan, {
    List<String> selectedExperienceIds = const [],
  }) {
    final String? prompt = resolvePromptToSend(
      canSend: plan.canSend,
      prompt: plan.prompt,
      errorMessage: plan.errorMessage,
      onError: onSnack,
    );
    if (prompt == null) {
      return;
    }
    onSendPrompt(prompt, selectedExperienceIds: selectedExperienceIds);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MasterEssayPromptPlanner planner =
        ref.read(masterEssayPromptPlannerProvider);
    final CareerShellActions actions = ref.read(careerShellActionsProvider);
    final List<Experience> experiences =
        ref.watch(experiencesProvider).value ?? const <Experience>[];
    final Map<int, int> versionCounts =
        ref.watch(essayVersionCountsProvider).value ?? const <int, int>{};

    return MasterResumeWorkspace(
      tabController: workspace.tabController,
      qControllers: workspace.qControllers,
      fullDraftController: workspace.fullDraft,
      targetJobController: workspace.targetJob,
      availableExperiences: experiences,
      savedVersionCounts: versionCounts,
      enabled: enabled,
      onAiForQuestion: (int index0Based, List<String> selectedExperienceIds) {
        // 선택 경험의 사실 주입은 서버 RAG가 selectedExperienceIds로 처리한다.
        _runPlan(
          workspace.questionDraftPlan(
            planner: planner,
            index0Based: index0Based,
            selectedExperienceIds: selectedExperienceIds,
          ),
          selectedExperienceIds: selectedExperienceIds,
        );
      },
      onAiExperienceMatch: (int index0Based) {
        _runPlan(
          planner.experienceMatch(
            index0Based: index0Based,
            targetJob: workspace.targetJobText,
            experiences: [
              for (final Experience e in experiences)
                ExperienceSummaryLine(
                  id: e.id,
                  title: e.title,
                  organization: e.organization,
                  role: e.role,
                ),
            ],
          ),
          selectedExperienceIds: [for (final Experience e in experiences) e.id],
        );
      },
      onAiFullReview: () {
        _runPlan(
          workspace.fullReviewPlan(planner: planner),
          selectedExperienceIds:
              ref.read(masterEssaySelectionProvider.notifier).allSelectedIds,
        );
      },
      onSaveEssayVersion: (
        int tabIndex,
        String body,
        List<String> selectedExperienceIds,
      ) async {
        onApplyResult(
          await actions.saveMasterEssayVersion(
            tabIndex: tabIndex,
            body: body,
            selectedExperienceIds: selectedExperienceIds,
            targetJob: workspace.targetJobText,
          ),
        );
      },
      onLoadEssayVersion: (int tabIndex) async {
        try {
          final List<EssayVersion> versions =
              await actions.listEssayVersions(tabIndex);
          if (!context.mounted) {
            return null;
          }
          if (versions.isEmpty) {
            onSnack('불러올 저장 버전이 없습니다.');
            return null;
          }
          final EssayVersion? selected = await EssayVersionPickerDialog.show(
            context: context,
            versions: versions,
          );
          if (selected == null || !context.mounted) {
            return null;
          }
          workspace.applyDraft(tabIndex: tabIndex, text: selected.body);
          onSnack('저장된 버전을 불러왔습니다.');
          return selected.sourceExperienceIds;
        } catch (e) {
          onSnack('자소서 버전 불러오기 실패: $e');
          return null;
        }
      },
    );
  }
}
