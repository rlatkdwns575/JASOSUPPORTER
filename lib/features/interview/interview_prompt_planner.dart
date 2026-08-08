/// 면접 대비 AI 요청 프롬프트 계획.
class InterviewPromptPlan {
  const InterviewPromptPlan({this.prompt, this.errorMessage});

  final String? prompt;
  final String? errorMessage;

  bool get canSend => prompt != null && prompt!.trim().isNotEmpty;
}

/// 면접 예상 질문·답변 초안·첨삭 프롬프트를 조합한다.
class InterviewPromptPlanner {
  const InterviewPromptPlanner();

  InterviewPromptPlan generateQuestions() {
    return const InterviewPromptPlan(
      prompt:
          '선택한 경험을 근거로 면접 예상 질문 5개를 만들고, 각 질문마다 방어 가능한 답변 요지를 짧게 제시해 주세요. 없는 사실은 만들지 마세요.',
    );
  }

  InterviewPromptPlan draftAnswer({required String question}) {
    final String q = question.trim();
    if (q.isEmpty) {
      return const InterviewPromptPlan(errorMessage: '답변을 만들 면접 질문이 없습니다.');
    }
    return InterviewPromptPlan(
      prompt:
          '다음 면접 질문에 대해 선택한 Experience STAR만 근거로 방어 가능한 답변 초안을 작성해 주세요.\n질문: $q',
    );
  }

  InterviewPromptPlan polishAnswer({
    required String question,
    required String answer,
  }) {
    final String q = question.trim();
    final String a = answer.trim();
    if (a.isEmpty) {
      return const InterviewPromptPlan(errorMessage: '첨삭할 면접 답변이 없습니다.');
    }
    return InterviewPromptPlan(
      prompt:
          '다음 면접 답변의 과장·허위 위험을 점검하고 방어 가능한 표현으로 고쳐 주세요.\n질문: $q\n답변: $a',
    );
  }
}
