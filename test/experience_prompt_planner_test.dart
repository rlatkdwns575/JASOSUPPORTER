import 'package:chatgptmini/features/experience/experience_prompt_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ExperiencePromptPlanner planner = ExperiencePromptPlanner();

  test('table rejects empty payload', () {
    final ExperiencePromptPlan plan = planner.table('  ');
    expect(plan.canSend, isFalse);
    expect(plan.errorMessage, contains('표로 정리'));
  });

  test('recommend builds prompt', () {
    final ExperiencePromptPlan plan = planner.recommend('동아리 경험');
    expect(plan.canSend, isTrue);
    expect(plan.prompt, contains('동아리 경험'));
  });

  test('narrativeMerge builds labeled STAR prompt', () {
    final ExperiencePromptPlan plan = planner.narrativeMerge('항목1');
    expect(plan.canSend, isTrue);
    expect(plan.prompt, contains('상황:'));
    expect(plan.prompt, contains('행동:'));
    expect(plan.prompt, contains('배운 점:'));
  });

  test('labeledStar builds prompt', () {
    final ExperiencePromptPlan plan = planner.labeledStar('동아리 메모');
    expect(plan.canSend, isTrue);
    expect(plan.prompt, contains('제목:'));
    expect(plan.prompt, contains('동아리 메모'));
  });
}
