import 'package:chatgptmini/data/services/api_client.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/domain/repositories/experience_repository.dart';

/// FastAPI 백엔드 기반 커리어 저장소.
///
/// 기존 [JsonCareerRepository]와 동일한 인터페이스를 구현하되, 로컬 파일 대신
/// 서버 REST API를 사용한다. Flutter Web에서도 동작하며 API 키를 노출하지 않는다.
class RemoteCareerRepository
    implements
        ExperienceRepository,
        SpecItemRepository,
        MasterEssayRepository,
        PortfolioProjectRepository,
        ApplicationRecordRepository,
        InterviewAnswerRepository {
  RemoteCareerRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<Map<String, Object?>> _asList(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    return raw.whereType<Map>().map((Map item) => Map<String, Object?>.from(item)).toList();
  }

  // --- Experiences ---
  @override
  Future<List<Experience>> listExperiences() async {
    final Object? raw = await _api.getJson('/experiences');
    return _asList(raw).map(Experience.fromJson).toList(growable: false);
  }

  @override
  Future<Experience?> getExperience(String id) async {
    final Object? raw = await _api.getJson('/experiences/$id');
    if (raw is! Map) {
      return null;
    }
    return Experience.fromJson(Map<String, Object?>.from(raw));
  }

  @override
  Future<void> saveExperience(Experience experience) async {
    await _api.postJson('/experiences', experience.toJson());
  }

  @override
  Future<void> deleteExperience(String id) async {
    await _api.delete('/experiences/$id');
  }

  // --- Spec items ---
  @override
  Future<List<SpecItem>> listSpecItems() async {
    final Object? raw = await _api.getJson('/spec-items');
    return _asList(raw).map(SpecItem.fromJson).toList(growable: false);
  }

  @override
  Future<void> saveSpecItem(SpecItem item) async {
    await _api.postJson('/spec-items', item.toJson());
  }

  @override
  Future<void> deleteSpecItem(String id) async {
    await _api.delete('/spec-items/$id');
  }

  // --- Master essays ---
  @override
  Future<List<MasterEssay>> listMasterEssays() async {
    final Object? raw = await _api.getJson('/master-essays');
    return _asList(raw).map(MasterEssay.fromJson).toList(growable: false);
  }

  @override
  Future<MasterEssay?> getMasterEssay(String id) async {
    final Object? raw = await _api.getJson('/master-essays/$id');
    if (raw is! Map) {
      return null;
    }
    return MasterEssay.fromJson(Map<String, Object?>.from(raw));
  }

  @override
  Future<void> saveMasterEssay(MasterEssay essay) async {
    await _api.postJson('/master-essays', essay.toJson());
  }

  @override
  Future<void> deleteMasterEssay(String id) async {
    await _api.delete('/master-essays/$id');
  }

  @override
  Future<List<EssayVersion>> listEssayVersions(String masterEssayId) async {
    final Object? raw = await _api.getJson(
      '/essay-versions',
      query: {'masterEssayId': masterEssayId},
    );
    return _asList(raw).map(EssayVersion.fromJson).toList(growable: false);
  }

  @override
  Future<void> saveEssayVersion(EssayVersion version) async {
    await _api.postJson('/essay-versions', version.toJson());
  }

  @override
  Future<void> deleteEssayVersion(String id) async {
    await _api.delete('/essay-versions/$id');
  }

  // --- Portfolio projects ---
  @override
  Future<List<PortfolioProject>> listPortfolioProjects() async {
    final Object? raw = await _api.getJson('/portfolio-projects');
    return _asList(raw).map(PortfolioProject.fromJson).toList(growable: false);
  }

  @override
  Future<void> savePortfolioProject(PortfolioProject project) async {
    await _api.postJson('/portfolio-projects', project.toJson());
  }

  @override
  Future<void> deletePortfolioProject(String id) async {
    await _api.delete('/portfolio-projects/$id');
  }

  // --- Application records ---
  @override
  Future<List<ApplicationRecord>> listApplicationRecords() async {
    final Object? raw = await _api.getJson('/application-records');
    return _asList(raw).map(ApplicationRecord.fromJson).toList(growable: false);
  }

  @override
  Future<void> saveApplicationRecord(ApplicationRecord record) async {
    await _api.postJson('/application-records', record.toJson());
  }

  @override
  Future<void> deleteApplicationRecord(String id) async {
    await _api.delete('/application-records/$id');
  }

  // --- Interview answers ---
  @override
  Future<List<InterviewAnswer>> listInterviewAnswers() async {
    final Object? raw = await _api.getJson('/interview-answers');
    return _asList(raw).map(InterviewAnswer.fromJson).toList(growable: false);
  }

  @override
  Future<void> saveInterviewAnswer(InterviewAnswer answer) async {
    await _api.postJson('/interview-answers', answer.toJson());
  }

  @override
  Future<void> deleteInterviewAnswer(String id) async {
    await _api.delete('/interview-answers/$id');
  }
}
