import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_copy_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ExperienceCopyFactory.duplicate clones with new id and title', () {
    final Experience source = Experience(
      id: 'exp-1',
      title: '프로젝트',
      type: ExperienceType.project,
      period: DateRange(start: DateTime(2024, 1), end: DateTime(2024, 6)),
      organization: '동아리',
      role: '팀장',
      situation: 's',
      task: 't',
      action: 'a',
      result: 'r',
      learned: 'l',
      techStacks: const ['Flutter'],
      competencyTags: const [],
      evidenceLinks: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final Experience copy = ExperienceCopyFactory.duplicate(
      source,
      now: DateTime(2026, 7, 29),
    );
    expect(copy.id, isNot(source.id));
    expect(copy.title, '프로젝트 복사본');
    expect(copy.action, source.action);
    expect(copy.id, contains('exp-1_copy_'));
  });
}
