import 'package:chatgptmini/features/experience/experience_star_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 기타 경험 전용 STAR 입력 블록.
class OtherStarFields extends StatelessWidget {
  const OtherStarFields({
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
