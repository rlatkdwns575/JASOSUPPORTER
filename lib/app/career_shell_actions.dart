import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/constants/jaso_constants.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/data/providers/career_draft_provider.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_copy_factory.dart';
import 'package:chatgptmini/features/portfolio/portfolio_project_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 셸에서 쓰는 경험·포트폴리오·지원·초안 저장 액션.
///
/// UI(snack/다이얼로그)는 호출부 책임이다.
class CareerShellActions {
  CareerShellActions(this.ref);

  final Ref ref;

  Future<ShellActionResult> saveExperienceCard(Experience experience) async {
    try {
      await ref.read(experiencesProvider.notifier).save(experience);
      return const ShellActionResult(snack: '경험 카드를 저장했습니다.');
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('경험 카드 저장 실패', e));
    }
  }

  Future<ShellActionResult> deleteExperienceCard(String id) async {
    try {
      await ref.read(experiencesProvider.notifier).delete(id);
      return const ShellActionResult(snack: '경험 카드를 삭제했습니다.');
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('경험 카드 삭제 실패', e));
    }
  }

  Future<ShellActionResult> duplicateExperienceCard(Experience experience) {
    return saveExperienceCard(ExperienceCopyFactory.duplicate(experience));
  }

  Future<ShellActionResult> deleteSpecItem(String id) async {
    try {
      await ref.read(specItemsProvider.notifier).delete(id);
      return const ShellActionResult(snack: '스펙을 삭제했습니다.');
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('스펙 삭제 실패', e));
    }
  }

  ShellActionResult queueStructuredDraft({
    required List<Experience> experiences,
    required List<SpecItem> specItems,
  }) {
    if (experiences.isEmpty && specItems.isEmpty) {
      return const ShellActionResult(snack: '저장할 경험·스펙이 없습니다.');
    }
    ref.read(careerDraftProvider.notifier).setPending(
          experiences: experiences,
          specItems: specItems,
        );
    return const ShellActionResult(navigateTo: AppRoutes.experienceConfirm);
  }

  Future<ShellActionResult> confirmPendingDraft() async {
    final CareerDraftState draft = ref.read(careerDraftProvider);
    if (draft.isEmpty) {
      return const ShellActionResult(snack: '확인할 경험·스펙이 없습니다.');
    }
    try {
      await ref.read(experiencesProvider.notifier).saveStructured(
            experiences: draft.pendingExperiences,
            specItems: draft.pendingSpecs,
          );
      ref.read(careerDraftProvider.notifier).markSaved();
      return const ShellActionResult(navigateTo: AppRoutes.experienceComplete);
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('경험 카드 저장 실패', e));
    }
  }

  Future<ShellActionResult> createPortfolioFromExperience(Experience experience) async {
    final PortfolioProject project =
        PortfolioProjectFactory.fromExperience(experience);
    await ref.read(portfolioProjectsProvider.notifier).save(project);
    return ShellActionResult(
      snack: '포트폴리오 개요를 저장했습니다.',
      navigateTo: AppRoutes.portfolio,
      editPortfolio: project,
    );
  }

  Future<ShellActionResult> deletePortfolioProject(String id) async {
    await ref.read(portfolioProjectsProvider.notifier).delete(id);
    return const ShellActionResult(snack: '포트폴리오 프로젝트를 삭제했습니다.');
  }

  Future<ShellActionResult> savePortfolioProject(PortfolioProject project) async {
    await ref.read(portfolioProjectsProvider.notifier).save(project);
    return const ShellActionResult(snack: '포트폴리오 개요를 저장했습니다.');
  }

  Future<ShellActionResult> saveApplicationRecord(ApplicationRecord record, {required bool isEdit}) async {
    await ref.read(applicationRecordsProvider.notifier).save(record);
    return ShellActionResult(
      snack: isEdit ? '지원 기록을 수정했습니다.' : '지원 기록을 저장했습니다.',
    );
  }

  Future<ShellActionResult> deleteApplicationRecord(String id) async {
    await ref.read(applicationRecordsProvider.notifier).delete(id);
    return const ShellActionResult(snack: '지원 기록을 삭제했습니다.');
  }

  Future<ShellActionResult> saveInterviewAnswer(InterviewAnswer answer) async {
    try {
      await ref.read(interviewAnswersProvider.notifier).save(answer);
      return const ShellActionResult(
        snack: '면접 답변을 저장했습니다.',
        navigateTo: AppRoutes.interview,
      );
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('면접 답변 저장 실패', e));
    }
  }

  Future<ShellActionResult> deleteInterviewAnswer(String id, {bool navigateHome = false}) async {
    try {
      await ref.read(interviewAnswersProvider.notifier).delete(id);
      return ShellActionResult(
        snack: '면접 답변을 삭제했습니다.',
        navigateTo: navigateHome ? AppRoutes.interview : null,
      );
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('면접 답변 삭제 실패', e));
    }
  }

  Future<ShellActionResult> saveMasterEssayVersion({
    required int tabIndex,
    required String body,
    required List<String> selectedExperienceIds,
    required String targetJob,
  }) async {
    if (body.trim().isEmpty) {
      return const ShellActionResult(snack: '저장할 자소서 내용이 없습니다.');
    }
    final String questionId =
        tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : 'FULL';
    try {
      await ref.read(essayVersionCountsProvider.notifier).saveVersion(
            tabIndex: tabIndex,
            body: body,
            selectedExperienceIds: selectedExperienceIds,
            targetJob: targetJob,
          );
      return ShellActionResult(snack: '$questionId 자소서 버전을 저장했습니다.');
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('자소서 버전 저장 실패', e));
    }
  }

  Future<List<EssayVersion>> listAllEssayVersions() {
    return ref.read(essayVersionCountsProvider.notifier).listAllVersions();
  }

  Future<List<EssayVersion>> listEssayVersions(int tabIndex) {
    return ref.read(essayVersionCountsProvider.notifier).listVersions(tabIndex);
  }

  Future<ShellActionResult> deleteEssayVersion(String versionId) async {
    try {
      await ref.read(essayVersionCountsProvider.notifier).deleteVersion(versionId);
      return const ShellActionResult(snack: '자소서 버전을 삭제했습니다.');
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('자소서 버전 삭제 실패', e));
    }
  }

  Future<ShellActionResult> deleteMasterEssayForTab(int tabIndex) async {
    final String questionId =
        tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : 'FULL';
    try {
      await ref.read(essayVersionCountsProvider.notifier).deleteMasterEssayForTab(tabIndex);
      return ShellActionResult(snack: '$questionId 자소서와 버전을 삭제했습니다.');
    } catch (e) {
      return ShellActionResult(snack: actionErrorMessage('자소서 삭제 실패', e));
    }
  }
}

final careerShellActionsProvider = Provider<CareerShellActions>((Ref ref) {
  return CareerShellActions(ref);
});
