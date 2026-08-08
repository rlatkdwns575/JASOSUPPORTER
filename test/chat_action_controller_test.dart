import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/data/providers/interview_questions_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/chat/chat_action_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Experience _exp({required String id, required String title}) {
  final DateTime stamp = DateTime(2026, 7, 29);
  return Experience(
    id: id,
    title: title,
    type: ExperienceType.club,
    period: const DateRange(),
    organization: '동아리',
    role: '팀원',
    situation: '',
    task: '',
    action: '',
    result: '',
    learned: '',
    techStacks: const [],
    competencyTags: const [],
    evidenceLinks: const [],
    createdAt: stamp,
    updatedAt: stamp,
  );
}

void main() {
  const ChatActionController controller = ChatActionController();
  final DateTime stamp = DateTime(2026, 7, 29, 12);

  group('planApply', () {
    test('routes interview apply to answer editor', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.interview,
        text: '방어 가능 답변',
        currentLocation: AppRoutes.interview,
        masterTabIndex: 0,
      );
      expect(plan.target, ChatApplyTarget.interviewAnswer);
      expect(plan.navigateTo, AppRoutes.interviewAnswer);
      expect(plan.text, '방어 가능 답변');
    });

    test('routes interview question list to interviewQuestions', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.interview,
        text: '''
1. 역할을 설명해 주세요.
2. 가장 어려웠던 문제는?
3. 배운 점은 무엇인가요?
''',
        currentLocation: AppRoutes.interview,
        masterTabIndex: 0,
      );
      expect(plan.target, ChatApplyTarget.interviewQuestions);
      expect(plan.interviewQuestions.length, greaterThanOrEqualTo(2));
    });

    test('applies experience draft to confirm', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.experienceSpec,
        text: '제목: 인턴\n행동: API 정리',
        currentLocation: AppRoutes.experience,
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.target, ChatApplyTarget.experienceDraft);
      expect(plan.experienceDraft, isNotNull);
      expect(plan.navigateTo, AppRoutes.experienceConfirm);
    });

    test('applies portfolio outline', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.portfolio,
        text: '포지셔닝과 목차',
        currentLocation: AppRoutes.portfolio,
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.target, ChatApplyTarget.portfolioOutline);
      expect(plan.portfolioProject?.portfolioCopy, '포지셔닝과 목차');
    });

    test('applies master draft without navigation', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.masterResume,
        text: '자소서 초안',
        currentLocation: AppRoutes.masterResume,
        masterTabIndex: 2,
      );
      expect(plan.target, ChatApplyTarget.masterDraft);
      expect(plan.masterTabIndex, 2);
      expect(plan.navigateTo, isNull);
    });

    test('applies master experience match ids from recommendation', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.masterResume,
        text: '''
- id: exp_campus_1
  title: 동아리 프로젝트
  reason: 협업 경험이 문항과 맞음
''',
        currentLocation: AppRoutes.masterResume,
        masterTabIndex: 1,
        availableExperiences: [
          _exp(id: 'exp_campus_1', title: '동아리 프로젝트'),
          _exp(id: 'exp_other', title: '다른 경험'),
        ],
      );
      expect(plan.target, ChatApplyTarget.masterExperienceMatch);
      expect(plan.experienceIds, ['exp_campus_1']);
      expect(plan.masterTabIndex, 1);
    });

    test('match-shaped text without ids does not become draft', () {
      final ChatApplyPlan plan = controller.planApply(
        mode: AssistantMode.masterResume,
        text: '''
추천 경험
- id: unknown_id
  title: 없는 카드
  reason: 테스트
''',
        currentLocation: AppRoutes.masterResume,
        masterTabIndex: 0,
        availableExperiences: [
          _exp(id: 'exp_campus_1', title: '동아리 프로젝트'),
        ],
      );
      expect(plan.target, ChatApplyTarget.masterExperienceMatch);
      expect(plan.experienceIds, isEmpty);
      expect(plan.message, contains('찾지 못했습니다'));
    });

    test('empty text yields empty plan', () {
      expect(
        controller
            .planApply(
              mode: AssistantMode.portfolio,
              text: '  ',
              currentLocation: AppRoutes.portfolio,
              masterTabIndex: 0,
            )
            .isEmpty,
        isTrue,
      );
    });
  });

  group('planSave', () {
    test('builds experience draft and confirm route', () {
      final ChatSavePlan plan = controller.planSave(
        mode: AssistantMode.experienceSpec,
        text: 'STAR 정리본',
        interviewSourceExperienceIds: const [],
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.kind, ChatSaveKind.experienceDraft);
      expect(plan.experienceDraft?.action, 'STAR 정리본');
      expect(plan.navigateTo, AppRoutes.experienceConfirm);
      expect(plan.message, isNotEmpty);
    });

    test('parses labeled STAR into experience draft fields', () {
      final ChatSavePlan plan = controller.planSave(
        mode: AssistantMode.experienceSpec,
        text: '''
제목: 인턴십
상황: 팀 온보딩 중이었습니다.
행동: API 문서를 정리했습니다.
성과: 신규 입사자 질문이 줄었습니다.
''',
        interviewSourceExperienceIds: const [],
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.experienceDraft?.title, '인턴십');
      expect(plan.experienceDraft?.situation, contains('온보딩'));
      expect(plan.experienceDraft?.action, contains('API'));
      expect(plan.experienceDraft?.result, contains('질문'));
      expect(plan.experienceDraft?.type.name, 'internship');
    });

    test('builds interview answer with source experiences', () {
      final ChatSavePlan plan = controller.planSave(
        mode: AssistantMode.interview,
        text: '답변 본문',
        interviewSourceExperienceIds: const ['exp_1'],
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.kind, ChatSaveKind.interviewAnswer);
      expect(plan.interviewAnswer?.sourceExperienceIds, ['exp_1']);
      expect(plan.interviewAnswer?.answer, '답변 본문');
    });

    test('saves interview question list', () {
      final ChatSavePlan plan = controller.planSave(
        mode: AssistantMode.interview,
        text: '''
1. 역할을 설명해 주세요.
2. 가장 어려웠던 문제는?
''',
        interviewSourceExperienceIds: const [],
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.kind, ChatSaveKind.interviewQuestions);
      expect(plan.interviewQuestions.length, greaterThanOrEqualTo(2));
    });

    test('builds portfolio outline from assistant text', () {
      final ChatSavePlan plan = controller.planSave(
        mode: AssistantMode.portfolio,
        text: '포지셔닝과 목차',
        interviewSourceExperienceIds: const [],
        masterTabIndex: 0,
        now: stamp,
      );
      expect(plan.kind, ChatSaveKind.portfolioOutline);
      expect(plan.portfolioProject?.portfolioCopy, '포지셔닝과 목차');
    });
  });

  group('InterviewQuestionParser', () {
    test('parses numbered questions', () {
      final List<String> qs = InterviewQuestionParser.parse('''
1. 첫 번째 질문입니다.
2. 두 번째 질문입니다.
3. 세 번째 질문입니다.
''');
      expect(qs.length, 3);
      expect(qs.first, contains('첫 번째'));
    });
  });
}
