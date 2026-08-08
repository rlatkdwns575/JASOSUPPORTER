import 'package:chatgptmini/core/constants/jaso_constants.dart';
import 'package:chatgptmini/data/providers/gemini_models_provider.dart';
import 'package:chatgptmini/data/remote/remote_career_repository.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FastAPI 기반 커리어 저장소. 화면에서는 직접 생성하지 않고 이 Provider만 사용한다.
final careerRepositoryProvider = Provider<RemoteCareerRepository>((Ref ref) {
  return RemoteCareerRepository(apiClient: ref.watch(apiClientProvider));
});

/// 경험 카드 목록.
class ExperiencesNotifier extends AsyncNotifier<List<Experience>> {
  RemoteCareerRepository get _repo => ref.read(careerRepositoryProvider);

  @override
  Future<List<Experience>> build() => _repo.listExperiences();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.listExperiences);
  }

  Future<void> save(Experience experience) async {
    await _repo.saveExperience(experience);
    await refresh();
  }

  Future<void> saveStructured({
    required List<Experience> experiences,
    required List<SpecItem> specItems,
  }) async {
    for (final Experience experience in experiences) {
      await _repo.saveExperience(experience);
    }
    for (final SpecItem item in specItems) {
      await _repo.saveSpecItem(item);
    }
    await refresh();
    await ref.read(specItemsProvider.notifier).refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deleteExperience(id);
    await refresh();
  }
}

final experiencesProvider =
    AsyncNotifierProvider<ExperiencesNotifier, List<Experience>>(ExperiencesNotifier.new);

/// 스펙(학적·전공·학점·자격증) 목록.
class SpecItemsNotifier extends AsyncNotifier<List<SpecItem>> {
  RemoteCareerRepository get _repo => ref.read(careerRepositoryProvider);

  @override
  Future<List<SpecItem>> build() => _repo.listSpecItems();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.listSpecItems);
  }

  Future<void> save(SpecItem item) async {
    await _repo.saveSpecItem(item);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deleteSpecItem(id);
    await refresh();
  }
}

final specItemsProvider = AsyncNotifierProvider<SpecItemsNotifier, List<SpecItem>>(SpecItemsNotifier.new);

/// 포트폴리오 프로젝트 목록.
class PortfolioProjectsNotifier extends AsyncNotifier<List<PortfolioProject>> {
  RemoteCareerRepository get _repo => ref.read(careerRepositoryProvider);

  @override
  Future<List<PortfolioProject>> build() => _repo.listPortfolioProjects();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.listPortfolioProjects);
  }

  Future<void> save(PortfolioProject project) async {
    await _repo.savePortfolioProject(project);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deletePortfolioProject(id);
    await refresh();
  }
}

final portfolioProjectsProvider =
    AsyncNotifierProvider<PortfolioProjectsNotifier, List<PortfolioProject>>(
  PortfolioProjectsNotifier.new,
);

/// 지원 기록 목록.
class ApplicationRecordsNotifier extends AsyncNotifier<List<ApplicationRecord>> {
  RemoteCareerRepository get _repo => ref.read(careerRepositoryProvider);

  @override
  Future<List<ApplicationRecord>> build() => _repo.listApplicationRecords();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.listApplicationRecords);
  }

  Future<void> save(ApplicationRecord record) async {
    await _repo.saveApplicationRecord(record);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deleteApplicationRecord(id);
    await refresh();
  }
}

final applicationRecordsProvider =
    AsyncNotifierProvider<ApplicationRecordsNotifier, List<ApplicationRecord>>(
  ApplicationRecordsNotifier.new,
);

/// 면접 답변 목록.
class InterviewAnswersNotifier extends AsyncNotifier<List<InterviewAnswer>> {
  RemoteCareerRepository get _repo => ref.read(careerRepositoryProvider);

  @override
  Future<List<InterviewAnswer>> build() => _repo.listInterviewAnswers();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.listInterviewAnswers);
  }

  Future<void> save(InterviewAnswer answer) async {
    await _repo.saveInterviewAnswer(answer);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _repo.deleteInterviewAnswer(id);
    await refresh();
  }
}

final interviewAnswersProvider =
    AsyncNotifierProvider<InterviewAnswersNotifier, List<InterviewAnswer>>(
  InterviewAnswersNotifier.new,
);

String masterEssayIdForTab(int tabIndex) {
  final String questionId = tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : "FULL";
  return "master_essay_$questionId";
}

/// 마스터 자소서 탭별 저장 버전 개수(Q1~Q6 + 전체).
class EssayVersionCountsNotifier extends AsyncNotifier<Map<int, int>> {
  RemoteCareerRepository get _repo => ref.read(careerRepositoryProvider);

  Future<Map<int, int>> _fetch() async {
    final Map<int, int> counts = {};
    for (int i = 0; i < 7; i++) {
      final List<EssayVersion> versions = await _repo.listEssayVersions(masterEssayIdForTab(i));
      counts[i] = versions.length;
    }
    return counts;
  }

  @override
  Future<Map<int, int>> build() => _fetch();

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> saveVersion({
    required int tabIndex,
    required String body,
    required List<String> selectedExperienceIds,
    required String targetJob,
  }) async {
    final DateTime now = DateTime.now();
    final String questionId = tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : "FULL";
    final String questionText = tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].body : "전체 초고";
    final String essayId = masterEssayIdForTab(tabIndex);
    final String versionId = "${essayId}_${now.microsecondsSinceEpoch}";

    final MasterEssay? existing = await _repo.getMasterEssay(essayId);
    final MasterEssay essay = MasterEssay(
      id: essayId,
      questionId: questionId,
      questionText: questionText,
      targetJob: targetJob,
      linkedExperienceIds: selectedExperienceIds,
      currentVersionId: versionId,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    final EssayVersion version = EssayVersion(
      id: versionId,
      masterEssayId: essayId,
      body: body.trim(),
      createdAt: now,
      sourceExperienceIds: selectedExperienceIds,
    );

    await _repo.saveMasterEssay(essay);
    await _repo.saveEssayVersion(version);
    await refresh();
  }

  Future<List<EssayVersion>> listVersions(int tabIndex) {
    return _repo.listEssayVersions(masterEssayIdForTab(tabIndex));
  }

  /// Q1~Q6 + 전체 초고 버전을 최신순으로 모은다.
  Future<List<EssayVersion>> listAllVersions() async {
    final List<EssayVersion> all = <EssayVersion>[];
    for (int i = 0; i < 7; i++) {
      all.addAll(await listVersions(i));
    }
    all.sort((EssayVersion a, EssayVersion b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<void> deleteVersion(String versionId) async {
    await _repo.deleteEssayVersion(versionId);
    await refresh();
  }

  /// 탭에 해당하는 MasterEssay와 연결된 버전을 모두 삭제한다.
  Future<void> deleteMasterEssayForTab(int tabIndex) async {
    await _repo.deleteMasterEssay(masterEssayIdForTab(tabIndex));
    await refresh();
  }
}

final essayVersionCountsProvider =
    AsyncNotifierProvider<EssayVersionCountsNotifier, Map<int, int>>(
  EssayVersionCountsNotifier.new,
);
