import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:flutter/material.dart';

/// 모드별 메인 작업 영역 분기.
class AppMainWorkspace extends StatelessWidget {
  const AppMainWorkspace({
    super.key,
    required this.mode,
    required this.experience,
    required this.masterResume,
    required this.interview,
    required this.portfolio,
  });

  final AssistantMode mode;
  final Widget experience;
  final Widget masterResume;
  final Widget interview;
  final Widget portfolio;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case AssistantMode.experienceSpec:
        return experience;
      case AssistantMode.masterResume:
        return masterResume;
      case AssistantMode.interview:
        return interview;
      case AssistantMode.portfolio:
        return portfolio;
    }
  }
}
