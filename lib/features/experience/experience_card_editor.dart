import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/period_range_fields.dart';
import 'package:chatgptmini/features/experience/star_field_hints.dart';
import 'package:flutter/material.dart';

/// 경험 카드 상세 편집 모달(시안: Dialog — Experience Card Editor).
///
/// Notion E09처럼 1) 기본 정보 → 2) STAR → 3) 활용 정보 단계로 나눈다.
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
  DateTime? _startDate;
  DateTime? _endDate;
  late final TextEditingController _situation;
  late final TextEditingController _task;
  late final TextEditingController _action;
  late final TextEditingController _result;
  late final TextEditingController _learned;
  late final TextEditingController _techStacks;
  late final TextEditingController _competencyTags;
  late final TextEditingController _evidenceLinks;
  bool _saving = false;
  int _step = 0;

  static const List<String> _stepLabels = ['기본 정보', 'STAR 내용', '활용 정보'];

  @override
  void initState() {
    super.initState();
    final Experience e = widget.initial;
    _type = e.type;
    _title = TextEditingController(text: e.title);
    _organization = TextEditingController(text: e.organization);
    _role = TextEditingController(text: e.role);
    _startDate = e.period.start;
    _endDate = e.period.end;
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
      setState(() => _step = 0);
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
        period: DateRange(start: _startDate, end: _endDate),
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
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 12, 12),
              child: Row(
                children: [
                  const AccentIconChip(
                    icon: Icons.edit_note_outlined,
                    color: AppColors.experience,
                    tint: AppColors.experienceTint,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "경험 카드 편집",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  for (int i = 0; i < _stepLabels.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _StepChip(
                        index: i + 1,
                        label: _stepLabels[i],
                        selected: _step == i,
                        onTap: _saving ? null : () => setState(() => _step = i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                child: switch (_step) {
                  0 => _basicsStep(),
                  1 => _starStep(),
                  _ => _usageStep(),
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text("취소"),
                  ),
                  if (_step > 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _saving ? null : () => setState(() => _step -= 1),
                      child: const Text("이전"),
                    ),
                  ],
                  const Spacer(),
                  if (_step < 2)
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.experience),
                      onPressed: _saving
                          ? null
                          : () {
                              if (_step == 0 && _title.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("경험 제목을 입력해 주세요.")),
                                );
                                return;
                              }
                              setState(() => _step += 1);
                            },
                      child: const Text("다음"),
                    )
                  else
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.experience),
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(_saving ? "저장 중" : "저장"),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicsStep() {
    return _section(
      title: "1단계 · 기본 정보",
      child: Column(
        children: [
          DropdownButtonFormField<ExperienceType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: "경험 유형"),
            items: [
              for (final ExperienceType type in ExperienceType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (ExperienceType? value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
          const SizedBox(height: 10),
          _field(_title, "제목", maxLines: 1),
          PeriodRangeFields(
            start: _startDate,
            end: _endDate,
            startLabel: "시작 (yy.mm)",
            endLabel: "종료 (yy.mm)",
            onStartChanged: (DateTime? value) => setState(() => _startDate = value),
            onEndChanged: (DateTime? value) => setState(() => _endDate = value),
            onClear: () => setState(() {
              _startDate = null;
              _endDate = null;
            }),
          ),
          const SizedBox(height: 10),
          _field(_organization, "기관/소속", maxLines: 1),
          _field(_role, "역할 · 참여 형태", maxLines: 2, padBottom: false),
        ],
      ),
    );
  }

  Widget _starStep() {
    final StarFieldHints hints = StarFieldHints.forExperienceType(_type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          title: "S 상황",
          child: _field(
            _situation,
            "상황",
            hint: hints.situation,
            maxLines: 4,
            padBottom: false,
          ),
        ),
        const SizedBox(height: 14),
        _section(
          title: "T 과제",
          child: _field(
            _task,
            "과제",
            hint: hints.task,
            maxLines: 4,
            padBottom: false,
          ),
        ),
        const SizedBox(height: 14),
        _section(
          title: "A 행동",
          child: _field(
            _action,
            "행동",
            hint: hints.action,
            maxLines: 5,
            padBottom: false,
          ),
        ),
        const SizedBox(height: 14),
        _section(
          title: "R 성과 · 배운 점",
          child: Column(
            children: [
              _field(_result, "성과", hint: hints.result, maxLines: 4),
              _field(
                _learned,
                "배운 점",
                hint: hints.learned,
                maxLines: 4,
                padBottom: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _usageStep() {
    return _section(
      title: "3단계 · 활용 정보",
      child: Column(
        children: [
          _field(_competencyTags, "역량 태그", hint: "쉼표로 구분", maxLines: 1),
          _field(_techStacks, "기술/도구", hint: "쉼표로 구분", maxLines: 1),
          _field(
            _evidenceLinks,
            "증빙 링크",
            hint: "쉼표로 구분",
            maxLines: 1,
            padBottom: false,
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: title,
            icon: Icons.inventory_2_outlined,
            accent: AppColors.experience,
            accentTint: AppColors.experienceTint,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 2,
    bool padBottom = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: padBottom ? 10 : 0),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  static List<String> _splitCsv(String raw) {
    return raw
        .split(",")
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.experienceTint : AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor:
                    selected ? AppColors.experience : AppColors.outlineVariant,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.experience : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
