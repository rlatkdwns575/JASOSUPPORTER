import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_input_chrome.dart';
import 'package:chatgptmini/features/experience/spec_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:chatgptmini/features/experience/experience_field_style.dart'
    show specFieldDecoration;

/// 스펙 소분류 입력 화면 공통 셸.
class SpecInputShell extends ConsumerStatefulWidget {
  const SpecInputShell({
    super.key,
    required this.kind,
    required this.enabled,
    required this.onQueueSpecs,
    required this.buildItems,
    required this.form,
    this.validate,
  });

  final SpecAddKind kind;
  final bool enabled;
  final ValueChanged<List<SpecItem>>? onQueueSpecs;
  final List<SpecItem> Function() buildItems;
  final Widget form;
  final String? Function()? validate;

  @override
  ConsumerState<SpecInputShell> createState() => _SpecInputShellState();
}

class _SpecInputShellState extends ConsumerState<SpecInputShell> {
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
    final List<SpecItem> items = widget.buildItems();
    if (items.isEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      final ValueChanged<List<SpecItem>>? onQueue = widget.onQueueSpecs;
      if (onQueue != null) {
        onQueue(items);
        return;
      }
      for (final SpecItem item in items) {
        await ref.read(specItemsProvider.notifier).save(item);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.kind.label} 스펙을 저장했습니다.')),
      );
      context.go(AppRoutes.experience);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionErrorMessage('저장 실패', e))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SpecAddKind kind = widget.kind;
    return ExperienceInputChrome(
      title: kind.label,
      categoryLabel: '스펙',
      categoryIcon: Icons.school_outlined,
      backLabel: '세부 유형으로 돌아가기',
      onBack: () => context.go(AppRoutes.experienceFormCategory('spec')),
      form: widget.form,
      onSubmit: _save,
      submitLabel:
          widget.onQueueSpecs != null ? '확인 화면으로' : '저장하고 돌아가기',
      enabled: widget.enabled,
      saving: _saving,
    );
  }
}
