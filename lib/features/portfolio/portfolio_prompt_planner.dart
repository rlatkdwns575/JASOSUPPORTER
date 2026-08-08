/// 포트폴리오 개요 AI 요청 프롬프트 계획.
class PortfolioPromptPlan {
  const PortfolioPromptPlan({this.prompt, this.errorMessage});

  final String? prompt;
  final String? errorMessage;

  bool get canSend => prompt != null && prompt!.trim().isNotEmpty;
}

/// 포트폴리오 개요 첨삭 프롬프트를 조합한다.
class PortfolioPromptPlanner {
  const PortfolioPromptPlanner();

  PortfolioPromptPlan polishOutline({required String portfolioCopy}) {
    final String copy = portfolioCopy.trim();
    if (copy.isEmpty) {
      return const PortfolioPromptPlan(errorMessage: '첨삭할 포트폴리오 개요가 없습니다.');
    }
    return PortfolioPromptPlan(
      prompt:
          '다음 포트폴리오 개요를 과장 없이 첨삭해 주세요. 시각 레이아웃은 다루지 마세요.\n$copy',
    );
  }
}
