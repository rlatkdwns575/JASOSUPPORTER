import 'package:chatgptmini/data/services/prompt_builder.dart';

/// 경험·스펙 폼 AI 요청 프롬프트 계획.
class ExperiencePromptPlan {
  const ExperiencePromptPlan({this.prompt, this.errorMessage});

  final String? prompt;
  final String? errorMessage;

  bool get canSend => prompt != null && prompt!.trim().isNotEmpty;
}

/// 경험 폼의 표 정리·직무 추천·서술 통합 프롬프트를 조합한다.
class ExperiencePromptPlanner {
  const ExperiencePromptPlanner({
    this.promptBuilder = const PromptBuilder(),
  });

  final PromptBuilder promptBuilder;

  ExperiencePromptPlan table(String payload) {
    final String value = payload.trim();
    if (value.isEmpty) {
      return const ExperiencePromptPlan(errorMessage: '표로 정리할 입력 내용이 없습니다.');
    }
    return ExperiencePromptPlan(prompt: promptBuilder.experienceTableRequest(value));
  }

  ExperiencePromptPlan recommend(String payload) {
    final String value = payload.trim();
    if (value.isEmpty) {
      return const ExperiencePromptPlan(errorMessage: '직무 추천에 사용할 입력 내용이 없습니다.');
    }
    return ExperiencePromptPlan(prompt: promptBuilder.experienceRecommendationRequest(value));
  }

  ExperiencePromptPlan narrativeMerge(String payload) {
    final String value = payload.trim();
    if (value.isEmpty) {
      return const ExperiencePromptPlan(errorMessage: 'STAR로 정리할 입력 내용이 없습니다.');
    }
    return ExperiencePromptPlan(prompt: promptBuilder.experienceNarrativeMergeRequest(value));
  }

  ExperiencePromptPlan labeledStar(String payload) {
    final String value = payload.trim();
    if (value.isEmpty) {
      return const ExperiencePromptPlan(errorMessage: 'STAR로 정리할 입력 내용이 없습니다.');
    }
    return ExperiencePromptPlan(prompt: promptBuilder.experienceLabeledStarRequest(value));
  }
}
