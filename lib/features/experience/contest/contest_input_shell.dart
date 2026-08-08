import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_input_chrome.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:chatgptmini/features/experience/experience_field_style.dart'
    show contestFieldDecoration;

/// 수상·공모전 소분류 입력 화면 공통 셸.
class ContestInputShell extends StatefulWidget {
  const ContestInputShell({
    super.key,
    required this.subtype,
    required this.enabled,
    required this.onQueueExperience,
    required this.buildExperience,
    required this.form,
    this.validate,
  });

  final ExperienceSubtype subtype;
  final bool enabled;
  final ValueChanged<Experience>? onQueueExperience;
  final Experience? Function() buildExperience;
  final Widget form;
  final String? Function()? validate;

  @override
  State<ContestInputShell> createState() => _ContestInputShellState();
}

class _ContestInputShellState extends State<ContestInputShell> {
  bool _saving = false;

  Future<void> _save() async {
    if (!widget.enabled || _saving) {
      return;
    }
    final String? error = widget.validate?.call();
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    final Experience? item = widget.buildExperience();
    if (item == null) {
      return;
    }

    setState(() => _saving = true);
    try {
      final ValueChanged<Experience>? onQueue = widget.onQueueExperience;
      if (onQueue != null) {
        onQueue(item);
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 경로가 연결되지 않았습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExperienceSubtype subtype = widget.subtype;
    return ExperienceInputChrome(
      title: subtype.title,
      categoryLabel: '수상·공모전',
      categoryIcon: Icons.emoji_events_outlined,
      backLabel: '세부 유형으로 돌아가기',
      onBack: () => context.go(AppRoutes.experienceFormCategory('contest')),
      form: widget.form,
      onSubmit: _save,
      submitLabel:
          widget.onQueueExperience != null ? '확인 화면으로' : '저장하기',
      enabled: widget.enabled,
      saving: _saving,
    );
  }
}
