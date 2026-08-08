import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/data/providers/interview_questions_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_star_parser.dart';
import 'package:chatgptmini/features/master_resume/experience_match_parser.dart';

/// AI 답변을 모드별 작업 영역/저장 산출물로 변환하는 컨트롤러.
///
/// UI·Riverpod 호출은 하지 않고, 결과 객체만 반환한다.
class ChatActionController {
  const ChatActionController();

  /// 적용 버튼: 모드별 대상과 이동 경로를 결정한다.
  ChatApplyPlan planApply({
    required AssistantMode mode,
    required String text,
    required String currentLocation,
    required int masterTabIndex,
    List<String> portfolioLinkedExperienceIds = const [],
    List<Experience> availableExperiences = const [],
    DateTime? now,
  }) {
    final String value = text.trim();
    if (value.isEmpty) {
      return const ChatApplyPlan.empty();
    }
    final DateTime stamp = now ?? DateTime.now();
    switch (mode) {
      case AssistantMode.interview:
        if (InterviewQuestionParser.looksLikeQuestionList(value)) {
          return ChatApplyPlan(
            target: ChatApplyTarget.interviewQuestions,
            text: value,
            interviewQuestions: InterviewQuestionParser.parse(value),
            navigateTo: currentLocation.startsWith(AppRoutes.interview)
                ? null
                : AppRoutes.interview,
            message: '예상 질문 목록에 적용했습니다.',
          );
        }
        return ChatApplyPlan(
          target: ChatApplyTarget.interviewAnswer,
          text: value,
          navigateTo: currentLocation.startsWith(AppRoutes.interviewAnswer)
              ? null
              : AppRoutes.interviewAnswer,
          message: 'AI 답변을 면접 답변 편집에 적용했습니다.',
        );
      case AssistantMode.masterResume:
        if (ExperienceMatchParser.looksLikeMatch(value)) {
          final List<String> matched = ExperienceMatchParser.matchIds(
            value,
            availableExperiences,
          );
          if (matched.isNotEmpty) {
            return ChatApplyPlan(
              target: ChatApplyTarget.masterExperienceMatch,
              text: value,
              masterTabIndex: masterTabIndex,
              experienceIds: matched,
              message: '추천 경험을 현재 문항 선택에 적용했습니다.',
            );
          }
          return ChatApplyPlan(
            target: ChatApplyTarget.masterExperienceMatch,
            text: value,
            masterTabIndex: masterTabIndex,
            experienceIds: const <String>[],
            message: '추천 경험 id를 찾지 못했습니다. 저장 경험과 맞춰 다시 적용해 주세요.',
          );
        }
        return ChatApplyPlan(
          target: ChatApplyTarget.masterDraft,
          text: value,
          masterTabIndex: masterTabIndex,
          message: 'AI 답변을 현재 자소서 초안에 적용했습니다.',
        );
      case AssistantMode.experienceSpec:
        return ChatApplyPlan(
          target: ChatApplyTarget.experienceDraft,
          text: value,
          experienceDraft: ExperienceStarParser.toDraft(
            value,
            now: stamp,
            id: 'exp_ai_${stamp.microsecondsSinceEpoch}',
          ),
          navigateTo: AppRoutes.experienceConfirm,
          message: 'AI 답변을 경험 확인 화면에 적용했습니다. 저장 전에 수정할 수 있습니다.',
        );
      case AssistantMode.portfolio:
        return ChatApplyPlan(
          target: ChatApplyTarget.portfolioOutline,
          text: value,
          portfolioProject: PortfolioProject(
            id: 'portfolio_ai_${stamp.microsecondsSinceEpoch}',
            title: 'AI 포트폴리오 개요',
            linkedExperienceIds: portfolioLinkedExperienceIds,
            role: '',
            problem: '',
            solution: '',
            techStacks: const [],
            result: '',
            evidenceLinks: const [],
            portfolioCopy: value,
            createdAt: stamp,
            updatedAt: stamp,
          ),
          navigateTo: AppRoutes.portfolio,
          message: 'AI 답변을 포트폴리오 개요 편집기에 적용했습니다.',
        );
    }
  }

  ChatApplyPlan planCopyToClipboard(String text) {
    final String value = text.trim();
    if (value.isEmpty) {
      return const ChatApplyPlan.empty();
    }
    return ChatApplyPlan(
      target: ChatApplyTarget.clipboard,
      text: value,
      message: 'AI 답변을 클립보드에 복사했습니다.',
    );
  }

  /// 저장 버튼: 모드별 저장 가능한 산출물 초안을 만든다.
  ChatSavePlan planSave({
    required AssistantMode mode,
    required String text,
    required List<String> interviewSourceExperienceIds,
    required int masterTabIndex,
    List<String> portfolioLinkedExperienceIds = const [],
    DateTime? now,
  }) {
    final String value = text.trim();
    if (value.isEmpty) {
      return const ChatSavePlan.empty();
    }
    final DateTime stamp = now ?? DateTime.now();
    switch (mode) {
      case AssistantMode.masterResume:
        return ChatSavePlan(
          kind: ChatSaveKind.masterEssayVersion,
          text: value,
          masterTabIndex: masterTabIndex,
        );
      case AssistantMode.interview:
        if (InterviewQuestionParser.looksLikeQuestionList(value)) {
          return ChatSavePlan(
            kind: ChatSaveKind.interviewQuestions,
            interviewQuestions: InterviewQuestionParser.parse(value),
            navigateTo: AppRoutes.interview,
            message: '예상 질문을 면접 대비 목록에 저장했습니다.',
          );
        }
        return ChatSavePlan(
          kind: ChatSaveKind.interviewAnswer,
          interviewAnswer: InterviewAnswer(
            id: 'interview_${stamp.microsecondsSinceEpoch}',
            question: 'AI 생성 면접 답변',
            answer: value,
            sourceExperienceIds: interviewSourceExperienceIds,
            createdAt: stamp,
            updatedAt: stamp,
          ),
          message: '면접 답변을 저장했습니다.',
          errorMessagePrefix: '면접 답변 저장 실패',
        );
      case AssistantMode.experienceSpec:
        return ChatSavePlan(
          kind: ChatSaveKind.experienceDraft,
          experienceDraft: ExperienceStarParser.toDraft(
            value,
            now: stamp,
            id: 'exp_ai_${stamp.microsecondsSinceEpoch}',
          ),
          navigateTo: AppRoutes.experienceConfirm,
          message: '경험 초안을 확인 화면에 올렸습니다. 확인 후 저장하세요.',
        );
      case AssistantMode.portfolio:
        return ChatSavePlan(
          kind: ChatSaveKind.portfolioOutline,
          portfolioProject: PortfolioProject(
            id: 'portfolio_ai_${stamp.microsecondsSinceEpoch}',
            title: 'AI 포트폴리오 개요',
            linkedExperienceIds: portfolioLinkedExperienceIds,
            role: '',
            problem: '',
            solution: '',
            techStacks: const [],
            result: '',
            evidenceLinks: const [],
            portfolioCopy: value,
            createdAt: stamp,
            updatedAt: stamp,
          ),
          navigateTo: AppRoutes.portfolio,
          message: '포트폴리오 개요를 저장했습니다.',
          errorMessagePrefix: '포트폴리오 개요 저장 실패',
        );
    }
  }
}

enum ChatApplyTarget {
  interviewAnswer,
  interviewQuestions,
  masterDraft,
  masterExperienceMatch,
  experienceDraft,
  portfolioOutline,
  chatInput,
  clipboard,
}

class ChatApplyPlan {
  const ChatApplyPlan({
    required this.target,
    required this.text,
    this.masterTabIndex = 0,
    this.navigateTo,
    this.message = '',
    this.experienceDraft,
    this.portfolioProject,
    this.interviewQuestions = const <String>[],
    this.experienceIds = const <String>[],
  });

  const ChatApplyPlan.empty()
      : target = ChatApplyTarget.clipboard,
        text = '',
        masterTabIndex = 0,
        navigateTo = null,
        message = '',
        experienceDraft = null,
        portfolioProject = null,
        interviewQuestions = const <String>[],
        experienceIds = const <String>[];

  final ChatApplyTarget target;
  final String text;
  final int masterTabIndex;
  final String? navigateTo;
  final String message;
  final Experience? experienceDraft;
  final PortfolioProject? portfolioProject;
  final List<String> interviewQuestions;
  final List<String> experienceIds;

  bool get isEmpty => text.isEmpty;
}

enum ChatSaveKind {
  masterEssayVersion,
  interviewAnswer,
  interviewQuestions,
  experienceDraft,
  portfolioOutline,
  none,
}

class ChatSavePlan {
  const ChatSavePlan({
    required this.kind,
    this.text = '',
    this.masterTabIndex = 0,
    this.interviewAnswer,
    this.experienceDraft,
    this.portfolioProject,
    this.interviewQuestions = const <String>[],
    this.navigateTo,
    this.message = '',
    this.errorMessagePrefix = '',
  });

  const ChatSavePlan.empty()
      : kind = ChatSaveKind.none,
        text = '',
        masterTabIndex = 0,
        interviewAnswer = null,
        experienceDraft = null,
        portfolioProject = null,
        interviewQuestions = const <String>[],
        navigateTo = null,
        message = '',
        errorMessagePrefix = '';

  final ChatSaveKind kind;
  final String text;
  final int masterTabIndex;
  final InterviewAnswer? interviewAnswer;
  final Experience? experienceDraft;
  final PortfolioProject? portfolioProject;
  final List<String> interviewQuestions;
  final String? navigateTo;
  final String message;
  final String errorMessagePrefix;

  bool get isEmpty => kind == ChatSaveKind.none;
}
