import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Experience JSON round-trip preserves core fields', () {
    final DateTime now = DateTime(2026, 5, 19);
    final Experience source = Experience(
      id: 'exp-1',
      title: '물류 데이터 분석',
      type: ExperienceType.project,
      period: DateRange(start: DateTime(2025, 1), end: DateTime(2025, 3)),
      organization: 'OO대학교',
      role: '분석 담당',
      situation: '배송 지연 이슈',
      task: '원인 분석',
      action: '데이터 정리',
      result: '리포트 작성',
      learned: '정량 근거의 중요성',
      techStacks: const ['Python'],
      competencyTags: const ['분석력'],
      evidenceLinks: const ['https://example.com'],
      createdAt: now,
      updatedAt: now,
    );

    final Experience restored = Experience.fromJson(source.toJson());

    expect(restored.id, source.id);
    expect(restored.title, source.title);
    expect(restored.type, source.type);
    expect(restored.techStacks, source.techStacks);
    expect(restored.competencyTags, source.competencyTags);
  });

  test('SpecItem JSON round-trip preserves certificate data', () {
    final SpecItem source = SpecItem(
      id: 'spec-1',
      type: SpecItemType.certificate,
      title: 'SQLD',
      value: '2026.05',
      issuedAt: '2026.05',
      createdAt: DateTime(2026, 5, 19),
      updatedAt: DateTime(2026, 5, 19),
    );

    final SpecItem restored = SpecItem.fromJson(source.toJson());

    expect(restored.id, source.id);
    expect(restored.type, source.type);
    expect(restored.title, source.title);
    expect(restored.value, source.value);
  });

  test('PortfolioProject and ApplicationRecord JSON round-trip', () {
    final DateTime now = DateTime(2026, 5, 19);
    final PortfolioProject project = PortfolioProject(
      id: 'portfolio-1',
      title: '프로젝트',
      linkedExperienceIds: const ['exp-1'],
      role: 'PM',
      problem: '문제',
      solution: '해결',
      techStacks: const ['Figma'],
      result: '성과',
      evidenceLinks: const ['https://example.com'],
      portfolioCopy: '카피',
      createdAt: now,
      updatedAt: now,
    );
    final ApplicationRecord record = ApplicationRecord(
      id: 'app-1',
      companyName: 'OO기업',
      position: 'PM',
      status: '준비 중',
      jobPostingUrl: 'https://example.com/jobs/1',
      deadline: DateTime(2026, 6, 1),
      linkedExperienceIds: const ['exp-1'],
      submittedEssayVersionIds: const ['essay-1'],
      linkedInterviewAnswerIds: const ['interview-1'],
      notes: '메모',
      createdAt: now,
      updatedAt: now,
    );

    expect(PortfolioProject.fromJson(project.toJson()).linkedExperienceIds, ['exp-1']);
    final ApplicationRecord restored = ApplicationRecord.fromJson(record.toJson());
    expect(restored.companyName, 'OO기업');
    expect(restored.jobPostingUrl, 'https://example.com/jobs/1');
    expect(restored.linkedInterviewAnswerIds, ['interview-1']);
  });

  test('ApplicationRecord tolerates legacy JSON without new fields', () {
    final ApplicationRecord restored = ApplicationRecord.fromJson({
      'id': 'app-legacy',
      'companyName': '레거시',
      'position': '개발',
      'status': '서류 제출',
      'deadline': null,
      'linkedExperienceIds': const <String>[],
      'submittedEssayVersionIds': const <String>[],
      'notes': '',
      'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
    });
    expect(restored.jobPostingUrl, '');
    expect(restored.linkedInterviewAnswerIds, isEmpty);
  });

  test('InterviewAnswer JSON round-trip preserves source experiences', () {
    final DateTime now = DateTime(2026, 5, 19);
    final InterviewAnswer source = InterviewAnswer(
      id: 'interview-1',
      question: '역할을 설명해 주세요',
      answer: '데이터 분석을 담당했습니다.',
      sourceExperienceIds: const ['exp-1'],
      notes: '',
      createdAt: now,
      updatedAt: now,
    );

    final InterviewAnswer restored = InterviewAnswer.fromJson(source.toJson());
    expect(restored.id, source.id);
    expect(restored.question, source.question);
    expect(restored.answer, source.answer);
    expect(restored.sourceExperienceIds, source.sourceExperienceIds);
  });
}
