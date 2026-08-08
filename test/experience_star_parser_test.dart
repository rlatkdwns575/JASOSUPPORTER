import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_star_parser.dart';
import 'package:chatgptmini/features/experience/experience_star_validator.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceStarParser', () {
    final DateTime stamp = DateTime(2026, 7, 30, 4);

    test('unlabeled text stays in action', () {
      final Experience draft = ExperienceStarParser.toDraft(
        '라벨 없는 전체 본문',
        now: stamp,
        id: 'exp_1',
      );
      expect(draft.action, '라벨 없는 전체 본문');
      expect(draft.situation, isEmpty);
      expect(draft.title, 'AI 정리 경험 초안');
    });

    test('parses labeled STAR sections', () {
      const String text = '''
제목: 데이터 분석 동아리
기관: OO대학교
역할: 분석 리드
기간: 24.03-24.12
상황: 신입 모집 후 분석 파이프라인이 없었습니다.
과제: 주간 리포트를 자동화해야 했습니다.
행동: Python으로 수집·집계 스크립트를 만들었습니다.
성과: 리포트 작성 시간을 줄였습니다.
배운 점: 요구사항을 먼저 정리하는 습관을 익혔습니다.
''';
      final Experience draft = ExperienceStarParser.toDraft(text, now: stamp, id: 'exp_2');
      expect(draft.title, '데이터 분석 동아리');
      expect(draft.organization, 'OO대학교');
      expect(draft.role, '분석 리드');
      expect(draft.type, ExperienceType.club);
      expect(draft.situation, contains('파이프라인'));
      expect(draft.task, contains('자동화'));
      expect(draft.action, contains('Python'));
      expect(draft.result, contains('리포트'));
      expect(draft.learned, contains('요구사항'));
      expect(draft.period.start?.year, 2024);
      expect(draft.period.start?.month, 3);
      expect(draft.period.end?.month, 12);
    });
  });

  group('ExperienceStarValidator', () {
    test('flags empty situation and action', () {
      final Experience experience = Experience(
        id: 'e1',
        title: '제목',
        type: ExperienceType.other,
        period: const DateRange(),
        organization: '',
        role: '',
        situation: '',
        task: '과제는 있음',
        action: '',
        result: '',
        learned: '',
        techStacks: const [],
        competencyTags: const [],
        evidenceLinks: const [],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final List<String> messages = ExperienceStarValidator.missingMessages(experience);
      expect(messages, contains('상황(S)이 비어 있습니다.'));
      expect(messages, contains('행동(A)이 비어 있습니다.'));
      expect(ExperienceStarValidator.hasBlockingGaps([experience]), isTrue);
    });
  });

  group('StarFieldHints', () {
    test('internship hints differ from club', () {
      final StarFieldHints club = StarFieldHints.forSubtype(ExperienceSubtype.club);
      final StarFieldHints intern = StarFieldHints.forSubtype(ExperienceSubtype.internship);
      expect(intern.situation, isNot(equals(club.situation)));
      expect(intern.action, contains('업무'));
    });

    test('experience type maps to subtype hints', () {
      expect(
        StarFieldHints.forExperienceType(ExperienceType.internship).situation,
        StarFieldHints.forSubtype(ExperienceSubtype.internship).situation,
      );
      expect(
        StarFieldHints.forExperienceType(ExperienceType.club).action,
        contains('회의'),
      );
    });
  });
}
