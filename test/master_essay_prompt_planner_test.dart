import 'package:chatgptmini/features/master_resume/master_essay_prompt_planner.dart';
import 'package:chatgptmini/core/constants/jaso_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MasterEssayPromptPlanner planner = MasterEssayPromptPlanner();

  test('questionDraft builds prompt with question id', () {
    final MasterEssayPromptPlan plan = planner.questionDraft(
      index0Based: 0,
      userDraft: '기존 초안',
      targetJob: '백엔드',
      selectedExperienceIds: const ['exp_1'],
    );
    expect(plan.canSend, isTrue);
    expect(plan.prompt, contains(MasterQuestionCopy.all[0].id));
    expect(plan.prompt, contains('기존 초안'));
    expect(plan.prompt, contains('백엔드'));
  });

  test('questionDraft rejects invalid index', () {
    final MasterEssayPromptPlan plan = planner.questionDraft(
      index0Based: 99,
      userDraft: '',
      targetJob: '',
      selectedExperienceIds: const [],
    );
    expect(plan.canSend, isFalse);
    expect(plan.errorMessage, isNotNull);
  });

  test('fullReview requires non-empty draft', () {
    final MasterEssayPromptPlan empty = planner.fullReview(fullDraft: '  ', targetJob: '직무');
    expect(empty.canSend, isFalse);
    expect(empty.errorMessage, contains('전체 초고'));

    final MasterEssayPromptPlan ok = planner.fullReview(fullDraft: '전체 초고 본문', targetJob: '직무');
    expect(ok.canSend, isTrue);
    expect(ok.prompt, contains('전체 초고 본문'));
  });
}
