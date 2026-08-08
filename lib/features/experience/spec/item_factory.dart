import 'package:chatgptmini/core/widgets/year_month_picker.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';

/// 스펙 입력 값을 SpecItem으로 조립한다.
abstract final class SpecItemFactory {
  static String formatPeriod(DateTime? start, DateTime? end) {
    final String s = YearMonthField.formatYearMonth(start);
    final String e = YearMonthField.formatYearMonth(end);
    if (s.isEmpty && e.isEmpty) {
      return '';
    }
    if (s.isNotEmpty && e.isNotEmpty) {
      return '$s-$e';
    }
    if (s.isNotEmpty) {
      return '$s-';
    }
    return '-$e';
  }

  static SpecItem school({
    required SpecAddKind kind,
    required String schoolName,
    required String detail,
    required String status,
    DateTime? start,
    DateTime? end,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final List<String> parts = <String>[
      schoolName.trim(),
      if (detail.trim().isNotEmpty) detail.trim(),
      if (status.trim().isNotEmpty) status.trim(),
    ];
    return SpecItem(
      id: 'spec_school_${kind.name}_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.school,
      title: kind.label,
      value: parts.join(' · '),
      issuedAt: formatPeriod(start, end),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static SpecItem certificate({
    required String name,
    String issuer = '',
    String score = '',
    String licenseNumber = '',
    String evidence = '',
    DateTime? acquired,
    DateTime? expiry,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String trimmedName = name.trim();
    final List<String> valueParts = <String>[
      trimmedName,
      if (issuer.trim().isNotEmpty) issuer.trim(),
      if (score.trim().isNotEmpty) score.trim(),
      if (licenseNumber.trim().isNotEmpty) '번호 ${licenseNumber.trim()}',
      if (evidence.trim().isNotEmpty) evidence.trim(),
      if (YearMonthField.formatYearMonth(expiry).isNotEmpty)
        '만료 ${YearMonthField.formatYearMonth(expiry)}',
    ];
    return SpecItem(
      id: 'spec_cert_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.certificate,
      title: trimmedName,
      value: valueParts.join(' · '),
      issuedAt: YearMonthField.formatYearMonth(acquired),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  /// 학점. 점수가 비어 있으면 null.
  static SpecItem? gpa({
    required String score,
    required String fullMark,
    DateTime? now,
  }) {
    final String trimmedScore = score.trim();
    if (trimmedScore.isEmpty) {
      return null;
    }
    final String mark = fullMark.trim().isEmpty ? '4.5' : fullMark.trim();
    final DateTime stamp = now ?? DateTime.now();
    return SpecItem(
      id: 'spec_gpa_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.gpa,
      title: '평균 학점',
      value: '$trimmedScore / $mark',
      issuedAt: '',
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  /// 주·부·복수전공 + 선택 주요 수업. 비어 있는 항목은 제외.
  static List<SpecItem> majors({
    required String mainMajor,
    String minorMajor = '',
    String doubleMajor = '',
    String keyCourses = '',
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final List<SpecItem> items = <SpecItem>[];
    void add(String title, String raw) {
      final String value = raw.trim();
      if (value.isEmpty) {
        return;
      }
      items.add(
        SpecItem(
          id: 'spec_major_${title}_${stamp.microsecondsSinceEpoch}_${items.length}',
          type: SpecItemType.major,
          title: title,
          value: value,
          issuedAt: '',
          createdAt: stamp,
          updatedAt: stamp,
        ),
      );
    }

    add('주전공', mainMajor);
    add('부전공', minorMajor);
    add('복수전공', doubleMajor);
    add('주요 수업', keyCourses);
    return items;
  }

  static SpecItem language({
    required String name,
    required String score,
    String issuer = '',
    DateTime? taken,
    DateTime? expiry,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String trimmedName = name.trim();
    final List<String> valueParts = <String>[
      score.trim(),
      if (issuer.trim().isNotEmpty) issuer.trim(),
      if (YearMonthField.formatYearMonth(expiry).isNotEmpty)
        '유효 ${YearMonthField.formatYearMonth(expiry)}',
    ];
    return SpecItem(
      id: 'spec_lang_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.language,
      title: trimmedName,
      value: valueParts.where((String p) => p.isNotEmpty).join(' · '),
      issuedAt: YearMonthField.formatYearMonth(taken),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static SpecItem scholarship({
    required String name,
    String organization = '',
    String amount = '',
    String note = '',
    DateTime? start,
    DateTime? end,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String body = [
      if (organization.trim().isNotEmpty) organization.trim(),
      if (amount.trim().isNotEmpty) amount.trim(),
      if (note.trim().isNotEmpty) note.trim(),
    ].join(' · ');
    return SpecItem(
      id: 'spec_scholarship_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.other,
      title: name.trim().isEmpty ? '장학' : name.trim(),
      value: body.isEmpty ? '장학' : body,
      issuedAt: formatPeriod(start, end),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static SpecItem volunteer({
    required String organizationOrTitle,
    String activity = '',
    String hours = '',
    String note = '',
    DateTime? start,
    DateTime? end,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String body = [
      if (activity.trim().isNotEmpty) activity.trim(),
      if (hours.trim().isNotEmpty) '누적 ${hours.trim()}',
      if (note.trim().isNotEmpty) note.trim(),
    ].join(' · ');
    return SpecItem(
      id: 'spec_volunteer_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.other,
      title: organizationOrTitle.trim().isEmpty
          ? '봉사'
          : organizationOrTitle.trim(),
      value: body.isEmpty ? '봉사' : body,
      issuedAt: formatPeriod(start, end),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static SpecItem other({
    required String title,
    required String value,
    String note = '',
    String category = '',
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String body = [
      if (category.trim().isNotEmpty) category.trim(),
      value.trim(),
      if (note.trim().isNotEmpty) note.trim(),
    ].where((String s) => s.isNotEmpty).join(' · ');
    return SpecItem(
      id: 'spec_other_${stamp.microsecondsSinceEpoch}',
      type: SpecItemType.other,
      title: title.trim(),
      value: body,
      issuedAt: '',
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
