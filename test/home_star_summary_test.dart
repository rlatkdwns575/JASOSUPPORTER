import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_star_validator.dart';
import 'package:flutter_test/flutter_test.dart';

Experience _exp({
  required String id,
  String title = '제목',
  String situation = '상황',
  String action = '행동',
}) {
  return Experience(
    id: id,
    title: title,
    type: ExperienceType.other,
    period: const DateRange(),
    organization: '',
    role: '',
    situation: situation,
    task: '',
    action: action,
    result: '',
    learned: '',
    techStacks: const [],
    competencyTags: const [],
    evidenceLinks: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('home incomplete STAR count uses validator issues', () {
    final List<Experience> items = [
      _exp(id: 'ok'),
      _exp(id: 'gap', situation: '', action: ''),
      _exp(id: 'partial', situation: '', action: '행동만'),
    ];
    expect(ExperienceStarValidator.issuesFor(items).length, 2);
  });
}
