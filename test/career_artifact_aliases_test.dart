import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 1, 1);

  test('MasterEssay.usedExperienceIds aliases linkedExperienceIds', () {
    final MasterEssay essay = MasterEssay(
      id: 'master_essay_Q1',
      questionId: 'Q1',
      questionText: '지원 동기',
      targetJob: '백엔드',
      linkedExperienceIds: const <String>['exp-1', 'exp-2'],
      currentVersionId: null,
      createdAt: now,
      updatedAt: now,
    );
    expect(essay.usedExperienceIds, same(essay.linkedExperienceIds));
    expect(essay.usedExperienceIds, <String>['exp-1', 'exp-2']);
  });

  test('PortfolioOutline is an alias of PortfolioProject', () {
    final PortfolioOutline outline = PortfolioProject(
      id: 'p-outline',
      title: '개요',
      linkedExperienceIds: const <String>['exp-1'],
      role: '역할',
      problem: '문제',
      solution: '해결',
      techStacks: const <String>[],
      result: '결과',
      evidenceLinks: const <String>[],
      portfolioCopy: '카피',
      createdAt: now,
      updatedAt: now,
    );
    expect(outline, isA<PortfolioProject>());
    expect(outline.sourceExperienceIds, const <String>['exp-1']);
  });

  test('PortfolioProject.sourceExperienceIds aliases linkedExperienceIds', () {
    final PortfolioProject project = PortfolioProject(
      id: 'p1',
      title: '개요',
      linkedExperienceIds: const <String>['exp-9'],
      role: '역할',
      problem: '문제',
      solution: '해결',
      techStacks: const <String>[],
      result: '결과',
      evidenceLinks: const <String>[],
      portfolioCopy: '',
      createdAt: now,
      updatedAt: now,
    );
    expect(project.sourceExperienceIds, same(project.linkedExperienceIds));
  });

  test('ApplicationRecord used* aliases match stored link fields', () {
    final ApplicationRecord record = ApplicationRecord(
      id: 'a1',
      companyName: 'Acme',
      position: 'Backend',
      status: '준비중',
      deadline: null,
      linkedExperienceIds: const <String>['exp-1'],
      submittedEssayVersionIds: const <String>['v1'],
      notes: '',
      createdAt: now,
      updatedAt: now,
    );
    expect(record.usedExperienceIds, same(record.linkedExperienceIds));
    expect(record.usedEssayIds, same(record.submittedEssayVersionIds));
  });
}
