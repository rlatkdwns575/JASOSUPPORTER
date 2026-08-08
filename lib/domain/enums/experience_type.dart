enum ExperienceType {
  club,
  campusActivity,
  internship,
  partTime,
  contest,
  bootcamp,
  project,
  trainingAbroad,
  certificate,
  education,
  other,
}

extension ExperienceTypeLabel on ExperienceType {
  String get label {
    return switch (this) {
      ExperienceType.club => "동아리",
      ExperienceType.campusActivity => "교내 활동",
      ExperienceType.internship => "인턴십",
      ExperienceType.partTime => "아르바이트",
      ExperienceType.contest => "수상·공모전",
      ExperienceType.bootcamp => "부트캠프",
      ExperienceType.project => "프로젝트",
      ExperienceType.trainingAbroad => "글로벌 경험",
      ExperienceType.certificate => "자격증",
      ExperienceType.education => "학적",
      ExperienceType.other => "기타",
    };
  }
}
