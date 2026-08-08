import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

/// P02 포트폴리오 개요 편집 다이얼로그.
class PortfolioOutlineEditor extends StatefulWidget {
  const PortfolioOutlineEditor({
    super.key,
    required this.initial,
    required this.onSave,
    this.availableExperiences = const <Experience>[],
  });

  final PortfolioProject initial;
  final Future<void> Function(PortfolioProject project) onSave;
  final List<Experience> availableExperiences;

  @override
  State<PortfolioOutlineEditor> createState() => _PortfolioOutlineEditorState();
}

class _PortfolioOutlineEditorState extends State<PortfolioOutlineEditor> {
  late final TextEditingController _title;
  late final TextEditingController _positioning;
  late final TextEditingController _outline;
  late final TextEditingController _role;
  late final TextEditingController _result;
  late final Set<String> _linkedIds;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final PortfolioProject p = widget.initial;
    _title = TextEditingController(text: p.title);
    final List<String> lines = p.portfolioCopy.split('\n');
    _positioning = TextEditingController(text: lines.isNotEmpty ? lines.first : '');
    _outline = TextEditingController(
      text: lines.length > 1 ? lines.skip(1).join('\n') : '',
    );
    _role = TextEditingController(text: p.role);
    _result = TextEditingController(text: p.result);
    _linkedIds = Set<String>.from(p.linkedExperienceIds);
  }

  @override
  void dispose() {
    _title.dispose();
    _positioning.dispose();
    _outline.dispose();
    _role.dispose();
    _result.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    final String positioning = _positioning.text.trim();
    final String outline = _outline.text.trim();
    final String copy = [
      if (positioning.isNotEmpty) positioning,
      if (outline.isNotEmpty) outline,
    ].join('\n');
    final PortfolioProject next = widget.initial.copyWith(
      title: _title.text.trim().isEmpty ? widget.initial.title : _title.text.trim(),
      role: _role.text.trim(),
      result: _result.text.trim(),
      portfolioCopy: copy,
      linkedExperienceIds: _linkedIds.toList(growable: false),
      updatedAt: DateTime.now(),
    );
    try {
      await widget.onSave(next);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: '포트폴리오 개요 편집',
                icon: Icons.layers_outlined,
                accent: AppColors.portfolio,
                accentTint: AppColors.portfolioTint,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: '제목'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _positioning,
                      decoration: const InputDecoration(labelText: '한 줄 포지셔닝'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _outline,
                      minLines: 6,
                      maxLines: 12,
                      decoration: const InputDecoration(
                        labelText: '목차·섹션 불릿',
                        alignLabelWithHint: true,
                        hintText: '- 문제 정의\n- 역할\n- 구현\n- 결과\n- 한계·개선',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _role,
                      decoration: const InputDecoration(labelText: '역할'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _result,
                      decoration: const InputDecoration(labelText: '결과 요약'),
                    ),
                    if (widget.availableExperiences.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '연결 경험',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final Experience e in widget.availableExperiences)
                            FilterChip(
                              selected: _linkedIds.contains(e.id),
                              label: Text(
                                e.title.isEmpty ? '(제목 없음)' : e.title,
                              ),
                              selectedColor: AppColors.portfolioTint,
                              checkmarkColor: AppColors.portfolio,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _linkedIds.add(e.id);
                                  } else {
                                    _linkedIds.remove(e.id);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.portfolio),
                    onPressed: _saving ? null : _submit,
                    child: Text(_saving ? '저장 중…' : '저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
