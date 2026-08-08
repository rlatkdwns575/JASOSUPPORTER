import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/features/interview/interview_prompt_planner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 면접 답변 작성 결과. UI는 [errorMessage]만 보여주면 된다.
class InterviewAnswerBuildResult {
  const InterviewAnswerBuildResult({this.answer, this.errorMessage});

  final InterviewAnswer? answer;
  final String? errorMessage;

  bool get isOk => answer != null;
}

/// 면접 질문·답변 입력 컨트롤러. dispose는 Provider가 담당한다.
class InterviewWorkspaceController {
  InterviewWorkspaceController();

  final TextEditingController question = TextEditingController();
  final TextEditingController answer = TextEditingController();

  /// 수정 중인 저장 답변 id. null이면 새로 저장한다.
  String? editingAnswerId;
  DateTime? editingCreatedAt;

  void openQuestion(String value) {
    editingAnswerId = null;
    editingCreatedAt = null;
    question.text = value;
    answer.clear();
  }

  void applyAnswer(String value) {
    answer.text = value.trim();
  }

  void loadSavedAnswer(InterviewAnswer saved) {
    editingAnswerId = saved.id;
    editingCreatedAt = saved.createdAt;
    question.text = saved.question;
    answer.text = saved.answer;
  }

  void clearEditing() {
    editingAnswerId = null;
    editingCreatedAt = null;
  }

  InterviewPromptPlan draftAnswerPlan(InterviewPromptPlanner planner) {
    return planner.draftAnswer(question: question.text);
  }

  InterviewPromptPlan polishAnswerPlan(InterviewPromptPlanner planner) {
    return planner.polishAnswer(
      question: question.text,
      answer: answer.text,
    );
  }

  /// 현재 편집값으로 저장용 [InterviewAnswer]를 만든다.
  InterviewAnswerBuildResult buildAnswer({
    required List<String> sourceExperienceIds,
    DateTime? now,
  }) {
    final String value = answer.text.trim();
    if (value.isEmpty) {
      return const InterviewAnswerBuildResult(errorMessage: '저장할 답변이 없습니다.');
    }
    final DateTime stamp = now ?? DateTime.now();
    final String q = question.text.trim();
    final String? existingId = editingAnswerId;
    return InterviewAnswerBuildResult(
      answer: InterviewAnswer(
        id: existingId ?? 'interview_${stamp.microsecondsSinceEpoch}',
        question: q.isEmpty ? '면접 질문' : q,
        answer: value,
        sourceExperienceIds: List<String>.from(sourceExperienceIds),
        createdAt: editingCreatedAt ?? stamp,
        updatedAt: stamp,
      ),
    );
  }

  void dispose() {
    question.dispose();
    answer.dispose();
  }
}

final interviewWorkspaceControllerProvider =
    Provider<InterviewWorkspaceController>((Ref ref) {
  final InterviewWorkspaceController controller = InterviewWorkspaceController();
  ref.onDispose(controller.dispose);
  return controller;
});
