import 'package:chatgptmini/data/services/ai_service.dart';
import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:chatgptmini/features/chat/chat_action_controller.dart';
import 'package:chatgptmini/features/chat/chat_flow_controller.dart';
import 'package:chatgptmini/features/experience/experience_prompt_planner.dart';
import 'package:chatgptmini/features/interview/interview_prompt_planner.dart';
import 'package:chatgptmini/features/master_resume/master_essay_prompt_planner.dart';
import 'package:chatgptmini/features/portfolio/portfolio_prompt_planner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서버 통신용 AI 서비스. 화면에서 직접 생성하지 않는다.
final aiServiceProvider = Provider<AiService>((Ref ref) {
  return HttpAiService();
});

/// 모드별 프롬프트 문구 조합.
final promptBuilderProvider = Provider<PromptBuilder>((Ref ref) {
  return const PromptBuilder();
});

/// 채팅 턴 생성·스트리밍 진입점.
final chatFlowControllerProvider = Provider<ChatFlowController>((Ref ref) {
  return ChatFlowController(aiService: ref.watch(aiServiceProvider));
});

/// AI 답변 적용/저장 계획.
final chatActionControllerProvider = Provider<ChatActionController>((Ref ref) {
  return const ChatActionController();
});

/// 마스터 자소서 AI 프롬프트 계획.
final masterEssayPromptPlannerProvider = Provider<MasterEssayPromptPlanner>((Ref ref) {
  return MasterEssayPromptPlanner(promptBuilder: ref.watch(promptBuilderProvider));
});

/// 경험 폼 AI 프롬프트 계획.
final experiencePromptPlannerProvider = Provider<ExperiencePromptPlanner>((Ref ref) {
  return ExperiencePromptPlanner(promptBuilder: ref.watch(promptBuilderProvider));
});

/// 면접 대비 AI 프롬프트 계획.
final interviewPromptPlannerProvider = Provider<InterviewPromptPlanner>((Ref ref) {
  return const InterviewPromptPlanner();
});

/// 포트폴리오 개요 AI 프롬프트 계획.
final portfolioPromptPlannerProvider = Provider<PortfolioPromptPlanner>((Ref ref) {
  return const PortfolioPromptPlanner();
});
