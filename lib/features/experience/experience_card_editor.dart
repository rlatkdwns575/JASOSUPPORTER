import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

class ExperienceCardEditor extends StatefulWidget {
  const ExperienceCardEditor({
    super.key,
    required this.initial,
    required this.onSave,
  });

  final Experience initial;
  final Future<void> Function(Experience experience) onSave;

  @override
  State<ExperienceCardEditor> createState() => _ExperienceCardEditorState();
}

class _ExperienceCardEditorState extends State<ExperienceCardEditor> {
  late ExperienceType _type;
  late final TextEditingController _title;
  late final TextEditingController _organization;
  late final TextEditingController _role;
  late final TextEditingController _start;
  late final TextEditingController _end;
  late final TextEditingController _situation;
  late final TextEditingController _task;
  late final TextEditingController _action;
  late final TextEditingController _result;
  late final TextEditingController _learned;
  late final TextEditingController _techStacks;
  late final TextEditingController _competencyTags;
  late final TextEditingController _evidenceLinks;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Experience e = widget.initial;
    _type = e.type;
    _title = TextEditingController(text: e.title);
    _organization = TextEditingController(text: e.organization);
    _role = TextEditingController(text: e.role);
    _start = TextEditingController(text: _formatMonth(e.period.start));
    _end = TextEditingController(text: _formatMonth(e.period.end));
    _situation = TextEditingController(text: e.situation);
    _task = TextEditingController(text: e.task);
    _action = TextEditingController(text: e.action);
    _result = TextEditingController(text: e.result);
    _learned = TextEditingController(text: e.learned);
    _techStacks = TextEditingController(text: e.techStacks.join(", "));
    _competencyTags = TextEditingController(text: e.competencyTags.join(", "));
    _evidenceLinks = TextEditingController(text: e.evidenceLinks.join(", "));
  }

  @override
  void dispose() {
    for (final TextEditingController controller in [
      _title,
      _organization,
      _role,
      _start,
      _end,
      _situation,
      _task,
      _action,
      _result,
      _learned,
      _techStacks,
      _competencyTags,
      _evidenceLinks,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("경험 제목을 입력해 주세요.")),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final Experience next = widget.initial.copyWith(
        title: _title.text.trim(),
        type: _type,
        period: DateRange(
          start: _parseMonth(_start.text),
          end: _parseMonth(_end.text),
        ),
        organization: _organization.text.trim(),
        role: _role.text.trim(),
        situation: _situation.text.trim(),
        task: _task.text.trim(),
        action: _action.text.trim(),
        result: _result.text.trim(),
        learned: _learned.text.trim(),
        techStacks: _splitCsv(_techStacks.text),
        competencyTags: _splitCsv(_competencyTags.text),
        evidenceLinks: _splitCsv(_evidenceLinks.text),
        updatedAt: DateTime.now(),
      );
      await widget.onSave(next);
      if (mounted) {
        Navigator.of(context).pop();
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
      surfaceTintColor: Colors.transparent,
      title: const Text("경험 카드 편집"),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Column(
                  children: [
                    DropdownButtonFormField<ExperienceType>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: "경험 유형"),
                      items: [
                        for (final ExperienceType type in ExperienceType.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                      ],
                      onChanged: (ExperienceType? value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _field(_title, "제목", maxLines: 1),
                    Row(
                      children: [
                        Expanded(child: _field(_start, "시작 월", hint: "YYYY-MM", maxLines: 1)),
                        const SizedBox(width: 10),
                        Expanded(child: _field(_end, "종료 월", hint: "YYYY-MM", maxLines: 1)),
                      ],
                    ),
                    _field(_organization, "기관/소속", maxLines: 1),
                    _field(_role, "역할/결과 요약", maxLines: 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Column(
                  children: [
                    _field(_situation, "상황", maxLines: 3),
                    _field(_task, "과제", maxLines: 3),
                    _field(_action, "행동", maxLines: 4),
                    _field(_result, "성과", maxLines: 3),
                    _field(_learned, "배운 점", maxLines: 3),
                    _field(_techStacks, "기술/도구", hint: "쉼표로 구분", maxLines: 1),
                    _field(_competencyTags, "역량 태그", hint: "쉼표로 구분", maxLines: 1),
                    _field(_evidenceLinks, "증빙 링크", hint: "쉼표로 구분", maxLines: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text("취소"),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(_saving ? "저장 중" : "저장"),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {String? hint, int maxLines = 2}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  static String _formatMonth(DateTime? value) {
    if (value == null) {
      return "";
    }
    return "${value.year.toString().padLeft(4, "0")}-${value.month.toString().padLeft(2, "0")}";
  }

  static DateTime? _parseMonth(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return null;
    }
    final List<String> parts = value.split("-");
    if (parts.length != 2) {
      return null;
    }
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) {
      return null;
    }
    return DateTime(year, month);
  }

  static List<String> _splitCsv(String raw) {
    return raw
        .split(",")
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
