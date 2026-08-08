import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/contest/contest_experience_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContestExperienceFactory', () {
    test('award joins role with award result', () {
      final experience = ContestExperienceFactory.award(
        eventName: 'OO 해커톤',
        organizer: 'OO기관',
        awardResult: '우수상',
        role: '팀장',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.contest);
      expect(experience.title, 'OO 해커톤');
      expect(experience.organization, 'OO기관');
      expect(experience.role, '팀장 · 우수상');
      expect(experience.result, '우수상');
    });

    test('contestEntry keeps evidence links and outcome', () {
      final experience = ContestExperienceFactory.contestEntry(
        contestName: '아이디어 공모전',
        organizer: 'OO재단',
        participation: '팀',
        role: '기획',
        outcome: '본선',
        evidenceRaw: 'https://github.com/a',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.contest);
      expect(experience.title, '아이디어 공모전');
      expect(experience.role, '팀 · 기획');
      expect(experience.result, '본선');
      expect(experience.evidenceLinks, <String>['https://github.com/a']);
    });
  });
}
