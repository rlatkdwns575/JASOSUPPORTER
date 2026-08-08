import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/app/career_shell_actions.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/utils/prompt_send.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/chat_providers.dart';
import 'package:chatgptmini/data/providers/interview_questions_provider.dart';
import 'package:chatgptmini/data/providers/interview_selection_provider.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/interview/interview_prompt_planner.dart';
import 'package:chatgptmini/features/interview/interview_route_body.dart';
import 'package:chatgptmini/features/interview/interview_workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 면접 워크스페이스 + provider/액션 배선.
class InterviewShellHost extends ConsumerWidget {
  const InterviewShellHost({
    super.key,
    required this.location,
    required this.enabled,
    required this.onSendPrompt,
    required this.onApplyResult,
    required this.onSnack,
  });

  final String location;
  final bool enabled;
  final void Function(String prompt, {List<String> selectedExperienceIds})
      onSendPrompt;
  final void Function(ShellActionResult result) onApplyResult;
  final ValueChanged<String> onSnack;

  void _runPlan(InterviewPromptPlan plan, List<String> selectedIds) {
    final String? prompt = resolvePromptToSend(
      canSend: plan.canSend,
      prompt: plan.prompt,
      errorMessage: plan.errorMessage,
      onError: onSnack,
    );
    if (prompt == null) {
      return;
    }
    onSendPrompt(prompt, selectedExperienceIds: selectedIds);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InterviewWorkspaceController workspace =
        ref.read(interviewWorkspaceControllerProvider);
    final InterviewPromptPlanner planner =
        ref.read(interviewPromptPlannerProvider);
    final CareerShellActions actions = ref.read(careerShellActionsProvider);
    final InterviewSelectionNotifier selection =
        ref.read(interviewSelectionProvider.notifier);
    final List<String> selectedIds =
        ref.read(interviewSelectionProvider).toList(growable: false);

    final List<Experience> experiences =
        ref.watch(experiencesProvider).value ?? const <Experience>[];
    final List<InterviewAnswer> answers =
        ref.watch(interviewAnswersProvider).value ?? const <InterviewAnswer>[];
    final Set<String> selectedSet = ref.watch(interviewSelectionProvider);
    final List<String> generatedQuestions = ref.watch(interviewQuestionsProvider);

    return InterviewRouteBody(
      location: location,
      experiences: experiences,
      savedAnswers: answers,
      selectedExperienceIds: selectedSet,
      generatedQuestions: generatedQuestions,
      questionController: workspace.question,
      answerController: workspace.answer,
      enabled: enabled,
      onToggleExperience: selection.toggle,
      onGenerateQuestions: () => _runPlan(planner.generateQuestions(), selectedIds),
      onOpenQuestion: (String question) {
        workspace.openQuestion(question);
        context.go(AppRoutes.interviewQuestion);
      },
      onOpenSavedAnswer: (InterviewAnswer answer) =>
          context.go(AppRoutes.interviewSaved(answer.id)),
      onDeleteAnswer: (InterviewAnswer answer) async {
        onApplyResult(await actions.deleteInterviewAnswer(answer.id));
      },
      onDraftAnswer: () =>
          _runPlan(workspace.draftAnswerPlan(planner), selectedIds),
      onOpenDefend: () => context.go(AppRoutes.interviewAnswer),
      onBackToPrep: () => context.go(AppRoutes.interview),
      onBackToQuestion: () => context.go(AppRoutes.interviewQuestion),
      onSaveAnswer: () async {
        List<String> sourceIds = selectedIds;
        if (sourceIds.isEmpty && workspace.editingAnswerId != null) {
          for (final InterviewAnswer a in answers) {
            if (a.id == workspace.editingAnswerId) {
              sourceIds = a.sourceExperienceIds;
              break;
            }
          }
        }
        final InterviewAnswerBuildResult built = workspace.buildAnswer(
          sourceExperienceIds: sourceIds,
        );
        if (!built.isOk) {
          onSnack(built.errorMessage ?? '저장할 답변이 없습니다.');
          return;
        }
        onApplyResult(await actions.saveInterviewAnswer(built.answer!));
        workspace.clearEditing();
      },
      onRequestPolish: () =>
          _runPlan(workspace.polishAnswerPlan(planner), selectedIds),
      onDeleteSavedAnswer: (InterviewAnswer answer) async {
        onApplyResult(
          await actions.deleteInterviewAnswer(answer.id, navigateHome: true),
        );
      },
      onEditSavedAnswer: (InterviewAnswer answer) {
        workspace.loadSavedAnswer(answer);
        if (answer.sourceExperienceIds.isNotEmpty) {
          selection.replaceWith(answer.sourceExperienceIds);
        }
        context.go(AppRoutes.interviewAnswer);
      },
    );
  }
}
