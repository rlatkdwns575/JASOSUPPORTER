import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ExperienceSubtype maps to category and query', () {
    expect(ExperienceSubtype.club.category, ExperienceCategory.campus);
    expect(ExperienceSubtype.internship.category, ExperienceCategory.external);
    expect(ExperienceSubtype.scholarship.category, ExperienceCategory.spec);
    expect(ExperienceSubtype.volunteer.category, ExperienceCategory.spec);
    expect(ExperienceSubtypeCopy.fromQuery('bootcamp'), ExperienceSubtype.bootcamp);
    expect(
      ExperienceSubtypeCopy.fromQuery('scholarship'),
      ExperienceSubtype.scholarship,
    );
    expect(ExperienceSubtypeCopy.forCategory(ExperienceCategory.global).length, 3);
    final List<ExperienceSubtype> specs =
        ExperienceSubtypeCopy.forCategory(ExperienceCategory.spec);
    expect(specs.length, 8);
    expect(specs, contains(ExperienceSubtype.highSchool));
    expect(specs, contains(ExperienceSubtype.scholarship));
    expect(specs, contains(ExperienceSubtype.volunteer));
    expect(specs.any((ExperienceSubtype s) => s.name == 'major'), isFalse);
    expect(
      ExperienceCategory.other.experienceTypes.contains(ExperienceType.certificate),
      isFalse,
    );
  });

  test('fromQuery matches camelCase subtype names case-insensitively', () {
    const List<(String, ExperienceSubtype)> cases = <(String, ExperienceSubtype)>[
      ('workingHoliday', ExperienceSubtype.workingHoliday),
      ('workingholiday', ExperienceSubtype.workingHoliday),
      ('languageTraining', ExperienceSubtype.languageTraining),
      ('externalProject', ExperienceSubtype.externalProject),
      ('contestEntry', ExperienceSubtype.contestEntry),
      ('partTime', ExperienceSubtype.partTime),
      ('classProject', ExperienceSubtype.classProject),
      ('highSchool', ExperienceSubtype.highSchool),
      ('gradSchool', ExperienceSubtype.gradSchool),
    ];
    for (final (String query, ExperienceSubtype expected) in cases) {
      expect(
        ExperienceSubtypeCopy.fromQuery(query),
        expected,
        reason: 'query=$query',
      );
    }
  });

  test('every subtype resolves to a dedicated form panel kind or category router', () {
    for (final ExperienceSubtype subtype in ExperienceSubtype.values) {
      if (subtype.isSpecSubtype) {
        expect(
          SpecAddKind.fromSubtype(subtype),
          isNotNull,
          reason: subtype.name,
        );
      } else {
        expect(subtype.category, isNot(ExperienceCategory.spec));
      }
    }
  });
}
