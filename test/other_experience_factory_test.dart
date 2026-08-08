import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/other/other_experience_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OtherExperienceFactory', () {
    test('partTime maps workplace and role', () {
      final experience = OtherExperienceFactory.partTime(
        workplaceOrDuty: '카페 아르바이트',
        workplace: 'OO카페',
        role: '홀 서빙',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.partTime);
      expect(experience.title, '카페 아르바이트');
      expect(experience.organization, 'OO카페');
      expect(experience.role, '홀 서빙');
    });

    test('military uses other type and keeps service title', () {
      final experience = OtherExperienceFactory.military(
        serviceType: '육군',
        unit: '공개 가능 범위',
        role: '행정',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.other);
      expect(experience.title, '육군');
      expect(experience.organization, '공개 가능 범위');
      expect(experience.role, '행정');
    });

    test('personal appends memo into learned', () {
      final experience = OtherExperienceFactory.personal(
        experienceTitle: '봉사활동',
        context: '봉사 담당',
        memo: '다음 자소서에 참고',
        learned: '책임감',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.other);
      expect(experience.title, '봉사활동');
      expect(experience.role, '봉사 담당');
      expect(experience.learned, contains('책임감'));
      expect(experience.learned, contains('메모: 다음 자소서에 참고'));
    });
  });
}
