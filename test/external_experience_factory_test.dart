import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/external/external_experience_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExternalExperienceFactory', () {
    test('internship maps company and tech stacks', () {
      final experience = ExternalExperienceFactory.internship(
        companyName: 'OO테크',
        department: '플랫폼팀',
        role: '백엔드 인턴',
        techStackRaw: 'Python, SQL',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.internship);
      expect(experience.title, 'OO테크');
      expect(experience.organization, '플랫폼팀');
      expect(experience.role, '백엔드 인턴');
      expect(experience.techStacks, <String>['Python', 'SQL']);
    });

    test('bootcamp uses bootcamp experience type', () {
      final experience = ExternalExperienceFactory.bootcamp(
        programName: '웹 풀스택',
        operator: 'OO스쿨',
        track: '풀스택',
        techStackRaw: 'React / Node',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.bootcamp);
      expect(experience.title, '웹 풀스택');
      expect(experience.organization, 'OO스쿨');
      expect(experience.techStacks, <String>['React', 'Node']);
    });

    test('externalProject keeps evidence links', () {
      final experience = ExternalExperienceFactory.externalProject(
        projectName: '커리어 앱',
        teamOrClient: '사이드',
        role: '프론트',
        evidenceRaw: 'https://github.com/a https://demo.app',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.project);
      expect(experience.title, '커리어 앱');
      expect(experience.evidenceLinks, <String>[
        'https://github.com/a',
        'https://demo.app',
      ]);
    });
  });
}
