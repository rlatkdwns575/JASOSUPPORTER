import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/campus/campus_experience_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CampusExperienceFactory', () {
    test('club joins role and scale', () {
      final experience = CampusExperienceFactory.club(
        clubName: '데이터동아리',
        affiliation: 'OO대학교',
        role: '기획팀장',
        scale: '팀 4명',
        start: DateTime(2024, 3),
        end: DateTime(2025, 12),
        situation: '신입 모집 전환기',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.club);
      expect(experience.title, '데이터동아리');
      expect(experience.organization, 'OO대학교');
      expect(experience.role, '기획팀장 · 팀 4명');
      expect(experience.situation, '신입 모집 전환기');
    });

    test('lab prepends research topic to situation', () {
      final experience = CampusExperienceFactory.lab(
        labName: 'HCI Lab',
        professor: '김교수',
        role: '학부연구생',
        researchTopic: '추천 시스템',
        situation: '주 1회 미팅',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.campusActivity);
      expect(experience.title, 'HCI Lab');
      expect(experience.organization, '김교수');
      expect(experience.situation, contains('연구 주제: 추천 시스템'));
      expect(experience.situation, contains('주 1회 미팅'));
    });

    test('classProject parses tech stacks', () {
      final experience = CampusExperienceFactory.classProject(
        projectName: '캡스톤',
        courseName: '소프트웨어공학',
        role: '프론트엔드',
        techStackRaw: 'Flutter, Firebase / Dart',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.campusActivity);
      expect(experience.title, '캡스톤');
      expect(experience.organization, '소프트웨어공학');
      expect(experience.techStacks, <String>['Flutter', 'Firebase', 'Dart']);
    });
  });
}
