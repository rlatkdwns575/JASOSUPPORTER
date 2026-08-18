import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/interview/interview_prep_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InterviewPrepPanel shows empty saved-answer hint', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InterviewPrepPanel(
            experiences: const <Experience>[],
            savedAnswers: const <InterviewAnswer>[],
            selectedExperienceIds: const <String>{},
            enabled: true,
            onToggleExperience: (_) {},
            onGenerateQuestions: () {},
            onOpenQuestion: (_) {},
            onOpenSavedAnswer: (_) {},
            onDeleteAnswer: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('생성된 예상 질문'), findsOneWidget);
    expect(find.text('저장된 면접 답변'), findsOneWidget);
    expect(find.textContaining('저장한 면접 답변이 없습니다'), findsOneWidget);
  });
}
