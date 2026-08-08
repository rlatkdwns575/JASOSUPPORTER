import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/app/app_section.dart';
import 'package:chatgptmini/app/career_shell_actions.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/utils/prompt_send.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/chat_providers.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/application_tracker/application_record_dialogs.dart';
import 'package:chatgptmini/features/portfolio/career_artifact_view.dart';
import 'package:chatgptmini/features/portfolio/portfolio_outline_dialogs.dart';
import 'package:chatgptmini/features/portfolio/portfolio_from_experience_dialog.dart';
import 'package:chatgptmini/features/portfolio/portfolio_prompt_planner.dart';
import 'package:chatgptmini/features/portfolio/portfolio_route_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 포트폴리오·지원 워크스페이스 + provider/액션 배선.
class PortfolioShellHost extends ConsumerWidget {
  const PortfolioShellHost({
    super.key,
    required this.location,
    required this.section,
    required this.enabled,
    required this.onSendPrompt,
    required this.onApplyResult,
    required this.onSnack,
  });

  final String location;
  final AppSection section;
  final bool enabled;
  final void Function(String prompt, {List<String> selectedExperienceIds})
      onSendPrompt;
  final void Function(ShellActionResult result) onApplyResult;
  final ValueChanged<String> onSnack;

  void _runPlan(PortfolioPromptPlan plan, {List<String>? experienceIds}) {
    final String? prompt = resolvePromptToSend(
      canSend: plan.canSend,
      prompt: plan.prompt,
      errorMessage: plan.errorMessage,
      onError: onSnack,
    );
    if (prompt == null) {
      return;
    }
    onSendPrompt(
      prompt,
      selectedExperienceIds: experienceIds ?? const <String>[],
    );
  }

  Future<void> _editOutline(
    BuildContext context,
    CareerShellActions actions,
    PortfolioProject project,
    List<Experience> experiences,
  ) async {
    await PortfolioOutlineDialogs.showEdit(
      context: context,
      project: project,
      availableExperiences: experiences,
      onSave: (PortfolioProject next) async {
        onApplyResult(await actions.savePortfolioProject(next));
      },
    );
  }

  Future<void> _createApplication(
    BuildContext context,
    CareerShellActions actions,
    List<Experience> experiences,
    List<InterviewAnswer> interviewAnswers,
  ) async {
    final List<EssayVersion> essayVersions = await actions.listAllEssayVersions();
    if (!context.mounted) {
      return;
    }
    await ApplicationRecordDialogs.showCreate(
      context: context,
      experiences: experiences,
      essayVersions: essayVersions,
      interviewAnswers: interviewAnswers,
      onSave: (ApplicationRecord record) async {
        onApplyResult(await actions.saveApplicationRecord(record, isEdit: false));
      },
    );
  }

  Future<void> _editApplication(
    BuildContext context,
    CareerShellActions actions,
    ApplicationRecord record,
    List<Experience> experiences,
    List<InterviewAnswer> interviewAnswers,
  ) async {
    final List<EssayVersion> essayVersions = await actions.listAllEssayVersions();
    if (!context.mounted) {
      return;
    }
    await ApplicationRecordDialogs.showEdit(
      context: context,
      record: record,
      experiences: experiences,
      essayVersions: essayVersions,
      interviewAnswers: interviewAnswers,
      onSave: (ApplicationRecord next) async {
        onApplyResult(await actions.saveApplicationRecord(next, isEdit: true));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CareerShellActions actions = ref.read(careerShellActionsProvider);
    final PortfolioPromptPlanner planner =
        ref.read(portfolioPromptPlannerProvider);

    final List<Experience> experiences =
        ref.watch(experiencesProvider).value ?? const <Experience>[];
    final List<PortfolioProject> projects =
        ref.watch(portfolioProjectsProvider).value ?? const <PortfolioProject>[];
    final List<ApplicationRecord> records =
        ref.watch(applicationRecordsProvider).value ??
            const <ApplicationRecord>[];
    final List<InterviewAnswer> interviewAnswers =
        ref.watch(interviewAnswersProvider).value ?? const <InterviewAnswer>[];

    return PortfolioRouteBody(
      location: location,
      view: section == AppSection.applications
          ? CareerArtifactView.applications
          : CareerArtifactView.portfolio,
      experiences: experiences,
      portfolioProjects: projects,
      applicationRecords: records,
      enabled: enabled,
      onCreatePortfolioProject: (Experience experience) async {
        final bool confirmed = await PortfolioFromExperienceDialog.confirm(
          context: context,
          experience: experience,
        );
        if (!confirmed || !context.mounted) {
          return;
        }
        onApplyResult(await actions.createPortfolioFromExperience(experience));
      },
      onDeletePortfolioProject: (PortfolioProject project) async {
        onApplyResult(await actions.deletePortfolioProject(project.id));
      },
      onCreateApplicationRecord: () =>
          _createApplication(context, actions, experiences, interviewAnswers),
      onDeleteApplicationRecord: (ApplicationRecord record) async {
        onApplyResult(await actions.deleteApplicationRecord(record.id));
      },
      onEditPortfolioProject: (PortfolioProject project) =>
          _editOutline(context, actions, project, experiences),
      onPreviewPortfolioProject: (PortfolioProject project) =>
          context.go(AppRoutes.portfolioPreview(project.id)),
      onEditApplicationRecord: (ApplicationRecord record) =>
          _editApplication(context, actions, record, experiences, interviewAnswers),
      onBackFromPreview: () => context.go(AppRoutes.portfolio),
      onRequestPolish: (PortfolioProject project) {
        _runPlan(
          planner.polishOutline(portfolioCopy: project.portfolioCopy),
          experienceIds: project.linkedExperienceIds,
        );
      },
    );
  }
}
