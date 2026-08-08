import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_card_editor.dart';
import 'package:flutter/material.dart';

/// 경험 카드 편집 다이얼로그.
class ExperienceCardDialogs {
  const ExperienceCardDialogs._();

  static Future<void> showEdit({
    required BuildContext context,
    required Experience experience,
    required Future<void> Function(Experience experience) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return ExperienceCardEditor(
          initial: experience,
          onSave: onSave,
        );
      },
    );
  }
}
