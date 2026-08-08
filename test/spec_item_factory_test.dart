import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/spec/item_factory.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpecItemFactory', () {
    test('school joins name, detail, status and period', () {
      final SpecItem item = SpecItemFactory.school(
        kind: SpecAddKind.university,
        schoolName: 'OO대학교',
        detail: '공과대학 컴퓨터공학과',
        status: '재학',
        start: DateTime(2022, 3),
        end: DateTime(2026, 2),
        now: DateTime(2026, 7, 30),
      );
      expect(item.type, SpecItemType.school);
      expect(item.title, '대학교');
      expect(item.value, 'OO대학교 · 공과대학 컴퓨터공학과 · 재학');
      expect(item.issuedAt, isNotEmpty);
    });

    test('certificate keeps name as title', () {
      final SpecItem item = SpecItemFactory.certificate(
        name: 'TOEIC',
        issuer: 'ETS',
        score: '850',
        acquired: DateTime(2025, 1),
        expiry: DateTime(2027, 1),
        now: DateTime(2026, 7, 30),
      );
      expect(item.type, SpecItemType.certificate);
      expect(item.title, 'TOEIC');
      expect(item.value, contains('ETS'));
      expect(item.value, contains('850'));
      expect(item.value, contains('만료'));
    });

    test('gpa returns null when score empty', () {
      expect(
        SpecItemFactory.gpa(score: '  ', fullMark: '4.5'),
        isNull,
      );
    });

    test('gpa formats score and full mark', () {
      final SpecItem? item = SpecItemFactory.gpa(
        score: '3.8',
        fullMark: '4.5',
        now: DateTime(2026, 7, 30),
      );
      expect(item, isNotNull);
      expect(item!.type, SpecItemType.gpa);
      expect(item.title, '평균 학점');
      expect(item.value, '3.8 / 4.5');
    });
    test('majors skips empty rows and keeps titles', () {
      final List<SpecItem> items = SpecItemFactory.majors(
        mainMajor: '컴퓨터공학과',
        minorMajor: '  ',
        doubleMajor: '데이터사이언스',
        keyCourses: '알고리즘',
        now: DateTime(2026, 7, 30),
      );
      expect(items.length, 3);
      expect(items.map((SpecItem e) => e.title).toList(), [
        '주전공',
        '복수전공',
        '주요 수업',
      ]);
      expect(items.first.type, SpecItemType.major);
    });

    test('language uses SpecItemType.language', () {
      final SpecItem item = SpecItemFactory.language(
        name: 'TOEIC',
        score: '850',
        issuer: 'ETS',
        taken: DateTime(2025, 1),
        expiry: DateTime(2027, 1),
        now: DateTime(2026, 7, 30),
      );
      expect(item.type, SpecItemType.language);
      expect(item.title, 'TOEIC');
      expect(item.value, contains('850'));
      expect(item.value, contains('ETS'));
      expect(item.issuedAt, isNotEmpty);
    });

    test('other keeps title and value', () {
      final SpecItem item = SpecItemFactory.other(
        title: '교내 프로그램',
        value: '리더십 캠프',
        note: '메모',
        category: '대외활동 요약',
        now: DateTime(2026, 7, 30),
      );
      expect(item.type, SpecItemType.other);
      expect(item.title, '교내 프로그램');
      expect(item.value, contains('대외활동 요약'));
      expect(item.value, contains('리더십'));
      expect(item.value, contains('메모'));
    });

    test('scholarship keeps name and period', () {
      final SpecItem item = SpecItemFactory.scholarship(
        name: '성적우수장학',
        organization: 'OO대학교',
        amount: '등록금 전액',
        start: DateTime(2024, 3),
        end: DateTime(2024, 8),
        now: DateTime(2026, 7, 30),
      );
      expect(item.type, SpecItemType.other);
      expect(item.title, '성적우수장학');
      expect(item.value, contains('OO대학교'));
      expect(item.issuedAt, isNotEmpty);
    });

    test('volunteer keeps organization and hours', () {
      final SpecItem item = SpecItemFactory.volunteer(
        organizationOrTitle: 'OO복지관',
        activity: '학습 멘토링',
        hours: '120시간',
        now: DateTime(2026, 7, 30),
      );
      expect(item.type, SpecItemType.other);
      expect(item.title, 'OO복지관');
      expect(item.value, contains('학습 멘토링'));
      expect(item.value, contains('120시간'));
    });
  });
}
