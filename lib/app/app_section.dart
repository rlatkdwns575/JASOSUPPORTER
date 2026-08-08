import 'package:chatgptmini/data/services/assistant_prompts.dart';

/// 사이드바 네비게이션의 최상위 섹션.
enum AppSection {
  home,
  experience,
  masterResume,
  portfolio,
  interview,
  applications,
  settings,
}

AppSection appSectionForLocation(String location) {
  if (location.startsWith('/experience')) {
    return AppSection.experience;
  }
  if (location.startsWith('/master-resume')) {
    return AppSection.masterResume;
  }
  if (location.startsWith('/portfolio')) {
    return AppSection.portfolio;
  }
  if (location.startsWith('/interview')) {
    return AppSection.interview;
  }
  if (location.startsWith('/applications')) {
    return AppSection.applications;
  }
  if (location.startsWith('/settings')) {
    return AppSection.settings;
  }
  return AppSection.home;
}

AssistantMode assistantModeForLocation(String location) {
  if (location.startsWith('/master-resume')) {
    return AssistantMode.masterResume;
  }
  if (location.startsWith('/portfolio') || location.startsWith('/applications')) {
    return AssistantMode.portfolio;
  }
  if (location.startsWith('/interview')) {
    return AssistantMode.interview;
  }
  return AssistantMode.experienceSpec;
}

/// 워크스페이스 상단 제목·부제.
/// 부제는 비워 둔다 — 안내 문구로 화면을 채우지 않는다.
({String title, String subtitle}) workspaceHeaderCopy({
  required AppSection section,
  required String location,
}) {
  return switch (section) {
    AppSection.masterResume => (
        title: '마스터 자소서',
        subtitle: '',
      ),
    AppSection.portfolio when location.startsWith('/portfolio/preview/') => (
        title: '개요 미리보기',
        subtitle: '',
      ),
    AppSection.portfolio => (
        title: '포트폴리오 개요',
        subtitle: '',
      ),
    AppSection.interview when location.startsWith('/interview/question') => (
        title: '예상 질문 상세',
        subtitle: '',
      ),
    AppSection.interview when location.startsWith('/interview/answer') => (
        title: '방어 가능 답변',
        subtitle: '',
      ),
    AppSection.interview when location.startsWith('/interview/saved/') => (
        title: '저장된 면접 답변',
        subtitle: '',
      ),
    AppSection.interview => (
        title: '면접 대비',
        subtitle: '',
      ),
    AppSection.applications => (
        title: '지원 관리',
        subtitle: '',
      ),
    AppSection.experience when location.startsWith('/experience/confirm') => (
        title: 'STAR 확인',
        subtitle: '',
      ),
    AppSection.experience when location.startsWith('/experience/complete') => (
        title: '저장 완료',
        subtitle: '',
      ),
    AppSection.experience when location.startsWith('/experience/detail/') => (
        title: '경험 상세',
        subtitle: '',
      ),
    AppSection.experience when location.startsWith('/experience/form') => (
        title: '경험 입력',
        subtitle: '',
      ),
    AppSection.experience when location.startsWith('/experience/specs') => (
        title: '스펙 추가',
        subtitle: '',
      ),
    AppSection.experience => (
        title: '경험 정리',
        subtitle: '',
      ),
    AppSection.home || AppSection.settings => (
        title: '경험 정리',
        subtitle: '',
      ),
  };
}
