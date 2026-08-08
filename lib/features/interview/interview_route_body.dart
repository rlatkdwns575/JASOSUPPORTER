import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/interview/interview_flow_panels.dart';
import 'package:chatgptmini/features/interview/interview_prep_panel.dart';
import 'package:flutter/material.dart';

/// 면접 섹션 서브라우트 본문.
class InterviewRouteBody extends StatelessWidget {
  const InterviewRouteBody({
    super.key,
    required this.location,
    required this.experiences,
    required this.savedAnswers,
    required this.selectedExperienceIds,
    required this.questionController,
    required this.answerController,
    required this.enabled,
    required this.onToggleExperience,
    required this.onGenerateQuestions,
    required this.onOpenQuestion,
    required this.onOpenSavedAnswer,
    required this.onDeleteAnswer,
    required this.onDraftAnswer,
    required this.onOpenDefend,
    required this.onBackToPrep,
    required this.onBackToQuestion,
    required this.onSaveAnswer,
    required this.onRequestPolish,
    required this.onDeleteSavedAnswer,
    this.onEditSavedAnswer,
    this.generatedQuestions = const <String>[],
  });

  final String location;
  final List<Experience> experiences;
  final List<InterviewAnswer> savedAnswers;
  final Set<String> selectedExperienceIds;
  final TextEditingController questionController;
  final TextEditingController answerController;
  final bool enabled;
  final ValueChanged<String> onToggleExperience;
  final VoidCallback onGenerateQuestions;
  final ValueChanged<String> onOpenQuestion;
  final ValueChanged<InterviewAnswer> onOpenSavedAnswer;
  final ValueChanged<InterviewAnswer> onDeleteAnswer;
  final VoidCallback onDraftAnswer;
  final VoidCallback onOpenDefend;
  final VoidCallback onBackToPrep;
  final VoidCallback onBackToQuestion;
  final VoidCallback onSaveAnswer;
  final VoidCallback onRequestPolish;
  final ValueChanged<InterviewAnswer> onDeleteSavedAnswer;
  final ValueChanged<InterviewAnswer>? onEditSavedAnswer;
  final List<String> generatedQuestions;

  InterviewAnswer? _answerById(String id) {
    for (final InterviewAnswer answer in savedAnswers) {
      if (answer.id == id) {
        return answer;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (location.startsWith('/interview/question')) {
      return InterviewQuestionDetailPanel(
        questionController: questionController,
        experiences: experiences,
        selectedExperienceIds: selectedExperienceIds,
        enabled: enabled,
        onToggleExperience: onToggleExperience,
        onDraftAnswer: onDraftAnswer,
        onOpenDefend: onOpenDefend,
        onBack: onBackToPrep,
      );
    }
    if (location.startsWith('/interview/answer')) {
      return InterviewAnswerDefendPanel(
        question: questionController.text.trim(),
        answerController: answerController,
        enabled: enabled,
        onSave: onSaveAnswer,
        onRequestPolish: onRequestPolish,
        onBack: onBackToQuestion,
      );
    }
    if (location.startsWith('/interview/saved/')) {
      final String id = location.split('/').last;
      final InterviewAnswer? found = _answerById(id);
      if (found == null) {
        return const Center(child: Text('저장된 답변을 찾을 수 없습니다.'));
      }
      final InterviewAnswer answer = found;
      return InterviewSavedAnswerPanel(
        answer: answer,
        enabled: enabled,
        onBack: onBackToPrep,
        onDelete: () => onDeleteSavedAnswer(answer),
        onEdit: onEditSavedAnswer == null
            ? null
            : () => onEditSavedAnswer!(answer),
      );
    }
    return InterviewPrepPanel(
      experiences: experiences,
      savedAnswers: savedAnswers,
      selectedExperienceIds: selectedExperienceIds,
      generatedQuestions: generatedQuestions,
      enabled: enabled,
      onToggleExperience: onToggleExperience,
      onGenerateQuestions: onGenerateQuestions,
      onOpenQuestion: onOpenQuestion,
      onOpenSavedAnswer: onOpenSavedAnswer,
      onDeleteAnswer: onDeleteAnswer,
    );
  }
}
