import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/remote/remote_career_repository.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCareerRepository extends RemoteCareerRepository {
  final List<Experience> experiences = [];

  @override
  Future<List<Experience>> listExperiences() async => List<Experience>.from(experiences);

  @override
  Future<void> saveExperience(Experience experience) async {
    experiences.removeWhere((Experience e) => e.id == experience.id);
    experiences.add(experience);
  }

  @override
  Future<void> deleteExperience(String id) async {
    experiences.removeWhere((Experience e) => e.id == id);
  }

  @override
  Future<void> saveSpecItem(SpecItem item) async {}

  @override
  Future<List<PortfolioProject>> listPortfolioProjects() async => const [];

  @override
  Future<List<ApplicationRecord>> listApplicationRecords() async => const [];

  @override
  Future<List<EssayVersion>> listEssayVersions(String masterEssayId) async => const [];
}

Experience _sample(String id) {
  final DateTime now = DateTime(2026, 1, 1);
  return Experience(
    id: id,
    title: "샘플 $id",
    type: ExperienceType.project,
    period: const DateRange(),
    organization: "Org",
    role: "Role",
    situation: "S",
    task: "T",
    action: "A",
    result: "R",
    learned: "L",
    techStacks: const [],
    competencyTags: const [],
    evidenceLinks: const [],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('ExperiencesNotifier save/delete updates shared list state', () async {
    final _FakeCareerRepository fake = _FakeCareerRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        careerRepositoryProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(experiencesProvider.future), isEmpty);

    await container.read(experiencesProvider.notifier).save(_sample("e1"));
    expect(container.read(experiencesProvider).value?.map((e) => e.id), ["e1"]);

    await container.read(experiencesProvider.notifier).delete("e1");
    expect(container.read(experiencesProvider).value, isEmpty);
  });
}
