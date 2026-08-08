import 'package:chatgptmini/features/interview/interview_prompt_planner.dart';
import 'package:chatgptmini/features/portfolio/portfolio_prompt_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterviewPromptPlanner', () {
    const InterviewPromptPlanner planner = InterviewPromptPlanner();

    test('generateQuestions always ready', () {
      expect(planner.generateQuestions().canSend, isTrue);
    });

    test('draftAnswer requires question', () {
      expect(planner.draftAnswer(question: '  ').canSend, isFalse);
      final InterviewPromptPlan plan = planner.draftAnswer(question: '강점?');
      expect(plan.canSend, isTrue);
      expect(plan.prompt, contains('강점?'));
    });

    test('polishAnswer requires answer body', () {
      expect(planner.polishAnswer(question: 'Q', answer: '').canSend, isFalse);
      final InterviewPromptPlan plan =
          planner.polishAnswer(question: 'Q', answer: '답변');
      expect(plan.prompt, contains('답변'));
    });
  });

  group('PortfolioPromptPlanner', () {
    const PortfolioPromptPlanner planner = PortfolioPromptPlanner();

    test('polishOutline requires copy', () {
      expect(planner.polishOutline(portfolioCopy: ' ').canSend, isFalse);
      final PortfolioPromptPlan plan =
          planner.polishOutline(portfolioCopy: '포지셔닝');
      expect(plan.canSend, isTrue);
      expect(plan.prompt, contains('포지셔닝'));
    });
  });
}
