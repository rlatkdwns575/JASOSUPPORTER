import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:flutter/material.dart';

/// Notion E04~E08 세부 유형.
enum ExperienceSubtype {
  highSchool,
  university,
  gradSchool,
  certificate,
  language,
  scholarship,
  volunteer,
  otherSpec,
  club,
  lab,
  classProject,
  internship,
  bootcamp,
  externalProject,
  award,
  contestEntry,
  workingHoliday,
  languageTraining,
  exchange,
  partTime,
  military,
  personal,
}

extension ExperienceSubtypeCopy on ExperienceSubtype {
  String get queryValue => name;

  ExperienceCategory get category => switch (this) {
        ExperienceSubtype.highSchool ||
        ExperienceSubtype.university ||
        ExperienceSubtype.gradSchool ||
        ExperienceSubtype.certificate ||
        ExperienceSubtype.language ||
        ExperienceSubtype.scholarship ||
        ExperienceSubtype.volunteer ||
        ExperienceSubtype.otherSpec =>
          ExperienceCategory.spec,
        ExperienceSubtype.club ||
        ExperienceSubtype.lab ||
        ExperienceSubtype.classProject =>
          ExperienceCategory.campus,
        ExperienceSubtype.internship ||
        ExperienceSubtype.bootcamp ||
        ExperienceSubtype.externalProject =>
          ExperienceCategory.external,
        ExperienceSubtype.award || ExperienceSubtype.contestEntry =>
          ExperienceCategory.contest,
        ExperienceSubtype.workingHoliday ||
        ExperienceSubtype.languageTraining ||
        ExperienceSubtype.exchange =>
          ExperienceCategory.global,
        ExperienceSubtype.partTime ||
        ExperienceSubtype.military ||
        ExperienceSubtype.personal =>
          ExperienceCategory.other,
      };

  bool get isSpecSubtype => category == ExperienceCategory.spec;

  String get title => switch (this) {
        ExperienceSubtype.highSchool => '고등학교',
        ExperienceSubtype.university => '대학교',
        ExperienceSubtype.gradSchool => '대학원',
        ExperienceSubtype.certificate => '자격증',
        ExperienceSubtype.language => '어학 성적',
        ExperienceSubtype.scholarship => '장학',
        ExperienceSubtype.volunteer => '봉사',
        ExperienceSubtype.otherSpec => '기타 스펙',
        ExperienceSubtype.club => '동아리',
        ExperienceSubtype.lab => '연구실',
        ExperienceSubtype.classProject => '수업 프로젝트',
        ExperienceSubtype.internship => '인턴십',
        ExperienceSubtype.bootcamp => '부트캠프',
        ExperienceSubtype.externalProject => '외부 프로젝트',
        ExperienceSubtype.award => '수상',
        ExperienceSubtype.contestEntry => '공모전',
        ExperienceSubtype.workingHoliday => '워킹홀리데이',
        ExperienceSubtype.languageTraining => '어학연수',
        ExperienceSubtype.exchange => '교환학생',
        ExperienceSubtype.partTime => '아르바이트',
        ExperienceSubtype.military => '군 복무',
        ExperienceSubtype.personal => '개인적 경험',
      };

  String get subtitle => switch (this) {
        ExperienceSubtype.highSchool => '학교명 · 졸업/재학 · 기간',
        ExperienceSubtype.university => '학교명 · 학부 · 재학/졸업 · 기간',
        ExperienceSubtype.gradSchool => '학교명 · 과정 · 재학/졸업 · 기간',
        ExperienceSubtype.certificate => '자격증명 · 취득·만료 연월',
        ExperienceSubtype.language => '시험명 · 점수·등급 · 응시 연월',
        ExperienceSubtype.scholarship => '장학 명칭 · 기관 · 기간·금액',
        ExperienceSubtype.volunteer => '봉사 기관 · 활동 · 시간·기간',
        ExperienceSubtype.otherSpec => '기타 스펙 항목',
        ExperienceSubtype.club => '동아리 이름 · 기간 · 활동·느낀 점',
        ExperienceSubtype.lab => '연구실 이름 · 기간 · 활동·느낀 점',
        ExperienceSubtype.classProject => '수업·프로젝트명 · 기간 · 내용·느낀 점',
        ExperienceSubtype.internship => '기업 · 기간 · 직무·업무·느낀 점',
        ExperienceSubtype.bootcamp => '프로그램명 · 기간 · 학습·프로젝트',
        ExperienceSubtype.externalProject => '프로젝트명 · 기간 · 내용·성과',
        ExperienceSubtype.award => '대회명 · 주최 · 기간 · 역할·결과',
        ExperienceSubtype.contestEntry => '공모전명 · 주최 · 기간 · 출품·결과',
        ExperienceSubtype.workingHoliday => '국가·도시 · 기간 · 활동·언어',
        ExperienceSubtype.languageTraining => '국가·기관 · 기간 · 언어 성장',
        ExperienceSubtype.exchange => '국가·학교 · 기간 · 수업·경험',
        ExperienceSubtype.partTime => '근무지 · 기간 · 역할·배운 점',
        ExperienceSubtype.military => '필요 범위만 · 기간 · 역할·변화',
        ExperienceSubtype.personal => '제목 · 기간 · 상황·행동·결과',
      };

  IconData get icon => switch (this) {
        ExperienceSubtype.highSchool => Icons.school_outlined,
        ExperienceSubtype.university => Icons.account_balance_outlined,
        ExperienceSubtype.gradSchool => Icons.menu_book_outlined,
        ExperienceSubtype.certificate => Icons.workspace_premium_outlined,
        ExperienceSubtype.language => Icons.translate,
        ExperienceSubtype.scholarship => Icons.card_giftcard_outlined,
        ExperienceSubtype.volunteer => Icons.volunteer_activism_outlined,
        ExperienceSubtype.otherSpec => Icons.more_horiz,
        ExperienceSubtype.club => Icons.groups_outlined,
        ExperienceSubtype.lab => Icons.science_outlined,
        ExperienceSubtype.classProject => Icons.school_outlined,
        ExperienceSubtype.internship => Icons.work_outline,
        ExperienceSubtype.bootcamp => Icons.terminal,
        ExperienceSubtype.externalProject => Icons.rocket_launch_outlined,
        ExperienceSubtype.award => Icons.emoji_events_outlined,
        ExperienceSubtype.contestEntry => Icons.flag_outlined,
        ExperienceSubtype.workingHoliday => Icons.flight_takeoff,
        ExperienceSubtype.languageTraining => Icons.translate,
        ExperienceSubtype.exchange => Icons.public_outlined,
        ExperienceSubtype.partTime => Icons.storefront_outlined,
        ExperienceSubtype.military => Icons.shield_outlined,
        ExperienceSubtype.personal => Icons.person_outline,
      };

  String get primaryLabel => switch (this) {
        ExperienceSubtype.highSchool => '고등학교명 · 과정',
        ExperienceSubtype.university => '대학교명 · 학과',
        ExperienceSubtype.gradSchool => '대학원명 · 과정',
        ExperienceSubtype.certificate => '자격증명',
        ExperienceSubtype.language => '시험·어학 명칭',
        ExperienceSubtype.scholarship => '장학 명칭',
        ExperienceSubtype.volunteer => '봉사 기관·활동명',
        ExperienceSubtype.otherSpec => '항목 이름',
        ExperienceSubtype.club => '동아리 이름',
        ExperienceSubtype.lab => '연구실 이름',
        ExperienceSubtype.classProject => '수업·프로젝트 이름',
        ExperienceSubtype.internship => '기업·기관명',
        ExperienceSubtype.bootcamp => '부트캠프·프로그램명',
        ExperienceSubtype.externalProject => '프로젝트명',
        ExperienceSubtype.award => '대회·행사 명칭',
        ExperienceSubtype.contestEntry => '공모전 명칭',
        ExperienceSubtype.workingHoliday => '국가·도시',
        ExperienceSubtype.languageTraining => '국가·도시',
        ExperienceSubtype.exchange => '국가·도시',
        ExperienceSubtype.partTime => '근무지·담당 업무',
        ExperienceSubtype.military => '복무 구분·부대(선택)',
        ExperienceSubtype.personal => '경험 제목',
      };

  static List<ExperienceSubtype> forCategory(ExperienceCategory category) {
    return ExperienceSubtype.values
        .where((ExperienceSubtype s) => s.category == category)
        .toList(growable: false);
  }

  static ExperienceSubtype? fromQuery(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final String key = raw.trim().toLowerCase();
    for (final ExperienceSubtype subtype in ExperienceSubtype.values) {
      if (subtype.name.toLowerCase() == key) {
        return subtype;
      }
    }
    return null;
  }
}
