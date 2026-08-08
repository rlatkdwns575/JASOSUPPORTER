import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/global/global_experience_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalExperienceFactory', () {
    test('workingHoliday joins activity and language', () {
      final experience = GlobalExperienceFactory.workingHoliday(
        place: '캐나다 밴쿠버',
        workplace: '카페',
        activity: '홀 서빙',
        language: '영어',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.trainingAbroad);
      expect(experience.title, '워킹홀리데이 · 캐나다 밴쿠버 · 카페');
      expect(experience.organization, '카페');
      expect(experience.role, '홀 서빙 · 영어');
    });

    test('languageTraining prefers institute as organization', () {
      final experience = GlobalExperienceFactory.languageTraining(
        place: '미국 뉴욕',
        institute: 'OO Language School',
        course: 'Intensive',
        language: '영어',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.trainingAbroad);
      expect(experience.title, contains('어학연수'));
      expect(experience.organization, 'OO Language School');
      expect(experience.role, 'Intensive · 영어');
    });

    test('exchange builds title from place and university', () {
      final experience = GlobalExperienceFactory.exchange(
        place: '독일 베를린',
        university: 'TU Berlin',
        program: 'Exchange',
        major: 'CS',
        now: DateTime(2026, 7, 30),
      );
      expect(experience.type, ExperienceType.trainingAbroad);
      expect(experience.title, '교환학생 · 독일 베를린 · TU Berlin');
      expect(experience.organization, 'TU Berlin');
      expect(experience.role, 'Exchange · CS');
    });
  });
}
