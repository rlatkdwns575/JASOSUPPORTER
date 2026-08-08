import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';

/// 스펙 세부 종류 — 카테고리 `spec`의 ExperienceSubtype과 1:1.
enum SpecAddKind {
  highSchool(
    label: '고등학교',
    subtitle: '학교명 · 졸업/재학 정보',
    icon: Icons.school_outlined,
  ),
  university(
    label: '대학교',
    subtitle: '학교명 · 학부 · 재학/졸업',
    icon: Icons.account_balance_outlined,
  ),
  gradSchool(
    label: '대학원',
    subtitle: '학교명 · 과정 · 재학/졸업',
    icon: Icons.menu_book_outlined,
  ),
  certificate(
    label: '자격증',
    subtitle: '자격증명 · 취득 연월',
    icon: Icons.workspace_premium_outlined,
  ),
  language(
    label: '어학 성적',
    subtitle: '시험명 · 점수·등급',
    icon: Icons.translate,
  ),
  scholarship(
    label: '장학',
    subtitle: '장학 명칭 · 기관 · 기간',
    icon: Icons.card_giftcard_outlined,
  ),
  volunteer(
    label: '봉사',
    subtitle: '기관 · 활동 · 시간',
    icon: Icons.volunteer_activism_outlined,
  ),
  other(
    label: '기타 스펙',
    subtitle: '위 유형에 없는 항목',
    icon: Icons.more_horiz,
  );

  const SpecAddKind({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;

  bool get isSchool =>
      this == SpecAddKind.highSchool ||
      this == SpecAddKind.university ||
      this == SpecAddKind.gradSchool;

  ExperienceSubtype get asSubtype => switch (this) {
        SpecAddKind.highSchool => ExperienceSubtype.highSchool,
        SpecAddKind.university => ExperienceSubtype.university,
        SpecAddKind.gradSchool => ExperienceSubtype.gradSchool,
        SpecAddKind.certificate => ExperienceSubtype.certificate,
        SpecAddKind.language => ExperienceSubtype.language,
        SpecAddKind.scholarship => ExperienceSubtype.scholarship,
        SpecAddKind.volunteer => ExperienceSubtype.volunteer,
        SpecAddKind.other => ExperienceSubtype.otherSpec,
      };

  static SpecAddKind? fromSubtype(ExperienceSubtype subtype) {
    return switch (subtype) {
      ExperienceSubtype.highSchool => SpecAddKind.highSchool,
      ExperienceSubtype.university => SpecAddKind.university,
      ExperienceSubtype.gradSchool => SpecAddKind.gradSchool,
      ExperienceSubtype.certificate => SpecAddKind.certificate,
      ExperienceSubtype.language => SpecAddKind.language,
      ExperienceSubtype.scholarship => SpecAddKind.scholarship,
      ExperienceSubtype.volunteer => SpecAddKind.volunteer,
      ExperienceSubtype.otherSpec => SpecAddKind.other,
      _ => null,
    };
  }
}
