import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:chatgptmini/core/constants/jaso_constants.dart';

/// 마스터 자소서 AI 요청 프롬프트 계획 결과.
class MasterEssayPromptPlan {
  const MasterEssayPromptPlan({
    this.prompt,
    this.errorMessage,
  });

  final String? prompt;
  final String? errorMessage;

  bool get canSend => prompt != null && prompt!.trim().isNotEmpty;
}

/// 마스터 자소서 문항 초안·전체 첨삭 프롬프트를 조합한다.
class MasterEssayPromptPlanner {
  const MasterEssayPromptPlanner({
    this.promptBuilder = const PromptBuilder(),
  });

  final PromptBuilder promptBuilder;

  MasterEssayPromptPlan questionDraft({
    required int index0Based,
    required String userDraft,
    required String targetJob,
    required List<String> selectedExperienceIds,
    String selectedExperienceContext = '',
  }) {
    if (index0Based < 0 || index0Based >= MasterQuestionCopy.all.length) {
      return const MasterEssayPromptPlan(errorMessage: '문항 인덱스가 올바르지 않습니다.');
    }
    final MasterQuestionCopy question = MasterQuestionCopy.all[index0Based];
    return MasterEssayPromptPlan(
      prompt: promptBuilder.masterQuestionDraftRequest(
        question: question,
        index0Based: index0Based,
        userDraft: userDraft,
        targetJob: targetJob,
        selectedExperienceIds: selectedExperienceIds,
        selectedExperienceContext: selectedExperienceContext,
      ),
    );
  }

  MasterEssayPromptPlan fullReview({
    required String fullDraft,
    required String targetJob,
  }) {
    final String draft = fullDraft.trim();
    if (draft.isEmpty) {
      return const MasterEssayPromptPlan(
        errorMessage: '전체 초고를 입력 칸에 붙여 넣어 주세요.',
      );
    }
    return MasterEssayPromptPlan(
      prompt: promptBuilder.masterFullReviewRequest(
        fullDraft: draft,
        targetJob: targetJob,
      ),
    );
  }

  MasterEssayPromptPlan experienceMatch({
    required int index0Based,
    required String targetJob,
    required List<ExperienceSummaryLine> experiences,
  }) {
    if (index0Based < 0 || index0Based >= MasterQuestionCopy.all.length) {
      return const MasterEssayPromptPlan(errorMessage: '문항 인덱스가 올바르지 않습니다.');
    }
    if (experiences.isEmpty) {
      return const MasterEssayPromptPlan(
        errorMessage: '매칭할 저장된 경험이 없습니다. 경험 정리에서 먼저 저장하세요.',
      );
    }
    final MasterQuestionCopy question = MasterQuestionCopy.all[index0Based];
    return MasterEssayPromptPlan(
      prompt: promptBuilder.masterExperienceMatchRequest(
        question: question,
        index0Based: index0Based,
        targetJob: targetJob,
        experiences: experiences,
      ),
    );
  }
}
