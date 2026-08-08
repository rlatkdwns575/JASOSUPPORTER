/// 앱 라우트 경로 상수·헬퍼.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String experience = '/experience';
  static const String experienceForm = '/experience/form';
  static const String experienceSpecs = '/experience/specs';
  static const String experienceConfirm = '/experience/confirm';
  static const String experienceComplete = '/experience/complete';
  static const String masterResume = '/master-resume';
  static const String portfolio = '/portfolio';
  static const String interview = '/interview';
  static const String interviewQuestion = '/interview/question';
  static const String interviewAnswer = '/interview/answer';
  static const String applications = '/applications';
  static const String settings = '/settings';

  static String experienceFormCategory(String categoryQuery) =>
      '$experienceForm?category=$categoryQuery';

  static String experienceFormSubtype(String categoryQuery, String subtypeQuery) =>
      '$experienceForm?category=$categoryQuery&subtype=$subtypeQuery';

  static String experienceDetail(String id) => '$experience/detail/$id';

  static String portfolioPreview(String id) => '$portfolio/preview/$id';

  static String interviewSaved(String id) => '$interview/saved/$id';
}
