import 'package:chatgptmini/features/experience/experience_star_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 글로벌 경험 전용 STAR 입력 블록.
class GlobalStarFields extends StatelessWidget {
  const GlobalStarFields({
    super.key,
    required this.situation,
    required this.task,
    required this.action,
    required this.result,
    required this.learned,
    required this.hints,
  });

  final TextEditingController situation;
  final TextEditingController task;
  final TextEditingController action;
  final TextEditingController result;
  final TextEditingController learned;
  final StarFieldHints hints;

  @override
  Widget build(BuildContext context) {
    return ExperienceStarFields(
      situation: situation,
      task: task,
      action: action,
      result: result,
      learned: learned,
      hints: hints,
    );
  }
}
