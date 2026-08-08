import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter/material.dart';

/// 스펙 항목 간단 편집 다이얼로그.
class SpecItemDialogs {
  const SpecItemDialogs._();

  static Future<void> showEdit({
    required BuildContext context,
    required SpecItem item,
    required Future<void> Function(SpecItem next) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return _SpecItemEditorDialog(initial: item, onSave: onSave);
      },
    );
  }
}

class _SpecItemEditorDialog extends StatefulWidget {
  const _SpecItemEditorDialog({
    required this.initial,
    required this.onSave,
  });

  final SpecItem initial;
  final Future<void> Function(SpecItem next) onSave;

  @override
  State<_SpecItemEditorDialog> createState() => _SpecItemEditorDialogState();
}

class _SpecItemEditorDialogState extends State<_SpecItemEditorDialog> {
  late final TextEditingController _title;
  late final TextEditingController _value;
  late final TextEditingController _issuedAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial.title);
    _value = TextEditingController(text: widget.initial.value);
    _issuedAt = TextEditingController(text: widget.initial.issuedAt);
  }

  @override
  void dispose() {
    _title.dispose();
    _value.dispose();
    _issuedAt.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해 주세요.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(
        SpecItem(
          id: widget.initial.id,
          type: widget.initial.type,
          title: _title.text.trim(),
          value: _value.text.trim(),
          issuedAt: _issuedAt.text.trim(),
          createdAt: widget.initial.createdAt,
          updatedAt: DateTime.now(),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('스펙 수정'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _value,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: '내용'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _issuedAt,
              decoration: const InputDecoration(
                labelText: '취득·기간 (선택)',
                hintText: '예: 25.03 또는 22.03-26.02',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? '저장 중…' : '저장'),
        ),
      ],
    );
  }
}
