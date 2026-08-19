import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/data/providers/career_draft_provider.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/interview_questions_provider.dart';
import 'package:chatgptmini/features/chat/chat_action_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [ChatSavePlan]을 저장소에 반영한다.
class ChatSaveExecutor {
  ChatSaveExecutor(this.ref);

  final Ref ref;

  Future<ShellActionResult> execute(
    ChatSavePlan plan, {
    required Future<ShellActionResult> Function(int tabIndex, String body)
        saveMasterEssayVersion,
  }) async {
    if (plan.isEmpty) {
      return const ShellActionResult.cancelled();
    }
    try {
      switch (plan.kind) {
        case ChatSaveKind.masterEssayVersion:
          return await saveMasterEssayVersion(plan.masterTabIndex, plan.text);
        case ChatSaveKind.interviewAnswer:
          await ref
              .read(interviewAnswersProvider.notifier)
              .save(plan.interviewAnswer!);
          return ShellActionResult(snack: plan.message);
        case ChatSaveKind.interviewQuestions:
          ref
              .read(interviewQuestionsProvider.notifier)
              .replaceWith(plan.interviewQuestions);
          return ShellActionResult(
            navigateTo: plan.navigateTo,
            snack: plan.message,
          );
        case ChatSaveKind.experienceDraft:
          ref.read(careerDraftProvider.notifier).setPending(
                experiences: [plan.experienceDraft!],
                specItems: const [],
              );
          return ShellActionResult(
            navigateTo: plan.navigateTo,
            snack: plan.message,
          );
        case ChatSaveKind.portfolioOutline:
          final project = plan.portfolioProject!;
          await ref.read(portfolioProjectsProvider.notifier).save(project);
          return ShellActionResult(
            snack: plan.message,
            navigateTo: plan.navigateTo ?? AppRoutes.portfolio,
            editPortfolio: project,
          );
        case ChatSaveKind.none:
          return const ShellActionResult.cancelled();
      }
    } catch (e) {
      final String prefix =
          plan.errorMessagePrefix.isEmpty ? '저장 실패' : plan.errorMessagePrefix;
      return ShellActionResult(snack: actionErrorMessage(prefix, e));
    }
  }
}

final chatSaveExecutorProvider = Provider<ChatSaveExecutor>((Ref ref) {
  return ChatSaveExecutor(ref);
});
