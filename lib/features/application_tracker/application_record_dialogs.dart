import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/application_tracker/application_record_editor.dart';
import 'package:flutter/material.dart';

/// 지원 기록 추가/수정 다이얼로그 진입점.
class ApplicationRecordDialogs {
  const ApplicationRecordDialogs._();

  static Future<void> showCreate({
    required BuildContext context,
    required List<Experience> experiences,
    required List<EssayVersion> essayVersions,
    List<InterviewAnswer> interviewAnswers = const <InterviewAnswer>[],
    required Future<void> Function(ApplicationRecord record) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return ApplicationRecordEditor(
          availableExperiences: experiences,
          availableEssayVersions: essayVersions,
          availableInterviewAnswers: interviewAnswers,
          onSave: onSave,
        );
      },
    );
  }

  static Future<void> showEdit({
    required BuildContext context,
    required ApplicationRecord record,
    required List<Experience> experiences,
    required List<EssayVersion> essayVersions,
    List<InterviewAnswer> interviewAnswers = const <InterviewAnswer>[],
    required Future<void> Function(ApplicationRecord record) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return ApplicationRecordEditor(
          availableExperiences: experiences,
          availableEssayVersions: essayVersions,
          availableInterviewAnswers: interviewAnswers,
          initial: record,
          onSave: onSave,
        );
      },
    );
  }
}
