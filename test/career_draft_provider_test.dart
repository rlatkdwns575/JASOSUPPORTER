import 'package:chatgptmini/data/providers/career_draft_provider.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Experience _exp(String id) {
  final DateTime now = DateTime(2026, 7, 29);
  return Experience(
    id: id,
    title: 't',
    type: ExperienceType.other,
    period: const DateRange(),
    organization: '',
    role: '',
    situation: '',
    task: '',
    action: 'a',
    result: '',
    learned: '',
    techStacks: const [],
    competencyTags: const [],
    evidenceLinks: const [],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('CareerDraftNotifier pending and markSaved', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final CareerDraftNotifier notifier = container.read(careerDraftProvider.notifier);
    expect(container.read(careerDraftProvider).isEmpty, isTrue);

    notifier.setPending(
      experiences: [_exp('e1')],
      specItems: const <SpecItem>[],
    );
    expect(container.read(careerDraftProvider).pendingCount, 1);

    notifier.updatePendingExperience(_exp('e1').copyWith(title: 'updated'));
    expect(container.read(careerDraftProvider).pendingExperiences.first.title, 'updated');

    final SpecItem spec = SpecItem(
      id: 's1',
      type: SpecItemType.certificate,
      title: '자격',
      value: '정보처리',
      issuedAt: '25.03',
      createdAt: DateTime(2026, 7, 29),
      updatedAt: DateTime(2026, 7, 29),
    );
    notifier.setPending(experiences: [_exp('e1')], specItems: [spec]);
    notifier.updatePendingSpec(
      SpecItem(
        id: 's1',
        type: SpecItemType.certificate,
        title: '자격 수정',
        value: '정보처리',
        issuedAt: '25.03',
        createdAt: spec.createdAt,
        updatedAt: DateTime(2026, 7, 30),
      ),
    );
    expect(container.read(careerDraftProvider).pendingSpecs.first.title, '자격 수정');

    notifier.markSaved();
    expect(container.read(careerDraftProvider).pendingExperiences, isEmpty);
    expect(container.read(careerDraftProvider).lastSavedCount, 2);
    expect(container.read(careerDraftProvider).lastSavedExperienceIds, ['e1']);

    notifier.setExperienceDraft(_exp('e2'));
    expect(container.read(careerDraftProvider).pendingExperiences.single.id, 'e2');
  });
}
