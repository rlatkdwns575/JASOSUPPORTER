import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';

abstract class ExperienceRepository {
  Future<List<Experience>> listExperiences();

  Future<Experience?> getExperience(String id);

  Future<void> saveExperience(Experience experience);

  Future<void> deleteExperience(String id);
}

abstract class SpecItemRepository {
  Future<List<SpecItem>> listSpecItems();

  Future<void> saveSpecItem(SpecItem item);

  Future<void> deleteSpecItem(String id);
}

abstract class MasterEssayRepository {
  Future<List<MasterEssay>> listMasterEssays();

  Future<MasterEssay?> getMasterEssay(String id);

  Future<void> saveMasterEssay(MasterEssay essay);

  Future<List<EssayVersion>> listEssayVersions(String masterEssayId);

  Future<void> saveEssayVersion(EssayVersion version);
}

abstract class PortfolioProjectRepository {
  Future<List<PortfolioProject>> listPortfolioProjects();

  Future<void> savePortfolioProject(PortfolioProject project);

  Future<void> deletePortfolioProject(String id);
}

abstract class ApplicationRecordRepository {
  Future<List<ApplicationRecord>> listApplicationRecords();

  Future<void> saveApplicationRecord(ApplicationRecord record);

  Future<void> deleteApplicationRecord(String id);
}

abstract class InterviewAnswerRepository {
  Future<List<InterviewAnswer>> listInterviewAnswers();

  Future<void> saveInterviewAnswer(InterviewAnswer answer);

  Future<void> deleteInterviewAnswer(String id);
}
