/// 앱에서 선택하는 도우미 모드.
///
/// 시스템 프롬프트 문자열은 서버(`backend/app/services/prompt_builder.py`)에만 둔다.
/// 클라이언트는 모드 식별자만 전달한다.
///
/// UI 순서: 경험 정리 → 마스터 자소서 → 포트폴리오 개요 → 면접 대비.
enum AssistantMode {
  /// 경험·스펙 STAR 구조화 및 직무 추천.
  experienceSpec,

  /// 마스터 자소서(문항별 전략·STAR·글자 수) 코칭.
  masterResume,

  /// 포트폴리오 개요(포지셔닝·목차·섹션 불릿)만.
  portfolio,

  /// 면접 예상 질문·방어 가능 답변.
  interview,
}
