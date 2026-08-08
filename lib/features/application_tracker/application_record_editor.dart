import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/core/widgets/year_month_picker.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_star_validator.dart';
import 'package:flutter/material.dart';

/// 지원 기록 추가/수정. Experience·자소서·면접 답변 연결을 포함한다.
class ApplicationRecordEditor extends StatefulWidget {
  const ApplicationRecordEditor({
    super.key,
    required this.availableExperiences,
    this.availableEssayVersions = const [],
    this.availableInterviewAnswers = const [],
    this.initial,
    required this.onSave,
  });

  final List<Experience> availableExperiences;
  final List<EssayVersion> availableEssayVersions;
  final List<InterviewAnswer> availableInterviewAnswers;
  final ApplicationRecord? initial;
  final Future<void> Function(ApplicationRecord record) onSave;

  @override
  State<ApplicationRecordEditor> createState() => _ApplicationRecordEditorState();
}

class _ApplicationRecordEditorState extends State<ApplicationRecordEditor> {
  static const List<String> _statusPresets = [
    '준비 중',
    '서류 제출',
    '서류 합격',
    '면접',
    '최종 합격',
    '불합격',
  ];

  late final TextEditingController _company;
  late final TextEditingController _position;
  late final TextEditingController _status;
  late final TextEditingController _jobUrl;
  late final TextEditingController _notes;
  late Set<String> _linkedExperienceIds;
  late Set<String> _linkedEssayVersionIds;
  late Set<String> _linkedInterviewAnswerIds;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ApplicationRecord? initial = widget.initial;
    _company = TextEditingController(text: initial?.companyName ?? '');
    _position = TextEditingController(text: initial?.position ?? '');
    _status = TextEditingController(text: initial?.status ?? '준비 중');
    _jobUrl = TextEditingController(text: initial?.jobPostingUrl ?? '');
    _notes = TextEditingController(text: initial?.notes ?? '');
    _linkedExperienceIds = {...?initial?.linkedExperienceIds};
    _linkedEssayVersionIds = {...?initial?.submittedEssayVersionIds};
    _linkedInterviewAnswerIds = {...?initial?.linkedInterviewAnswerIds};
    final DateTime? deadline = initial?.deadline;
    _deadline = deadline == null ? null : DateTime(deadline.year, deadline.month);
  }

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _status.dispose();
    _jobUrl.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final String company = _company.text.trim();
    final String position = _position.text.trim();
    if (company.isEmpty || position.isEmpty) {
      return;
    }
    setState(() => _saving = true);
    final DateTime now = DateTime.now();
    final ApplicationRecord? initial = widget.initial;
    final ApplicationRecord record = ApplicationRecord(
      id: initial?.id ?? 'application_${now.microsecondsSinceEpoch}',
      companyName: company,
      position: position,
      status: _status.text.trim().isEmpty ? '준비 중' : _status.text.trim(),
      jobPostingUrl: _jobUrl.text.trim(),
      deadline: _deadline,
      linkedExperienceIds: _linkedExperienceIds.toList(growable: false),
      submittedEssayVersionIds: _linkedEssayVersionIds.toList(growable: false),
      linkedInterviewAnswerIds: _linkedInterviewAnswerIds.toList(growable: false),
      notes: _notes.text.trim(),
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      await widget.onSave(record);
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

  String _essayChipLabel(EssayVersion version) {
    final String question = version.masterEssayId.replaceFirst('master_essay_', '');
    final String questionLabel = switch (question) {
      'Q1' || 'Q2' || 'Q3' || 'Q4' || 'Q5' || 'Q6' => question,
      'FULL' => '전체초고',
      _ => question.isEmpty ? '문항' : question,
    };
    final DateTime created = version.createdAt;
    final String date =
        '${created.year}.${created.month.toString().padLeft(2, '0')}.${created.day.toString().padLeft(2, '0')}';
    final String preview = version.body.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (preview.isEmpty) {
      return '$questionLabel · $date';
    }
    final String short = preview.length > 20 ? '${preview.substring(0, 20)}…' : preview;
    return '$questionLabel · $date · $short';
  }

  String _interviewChipLabel(InterviewAnswer answer) {
    final String q = answer.question.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (q.isEmpty) {
      return '면접 답변';
    }
    return q.length > 28 ? '${q.substring(0, 28)}…' : q;
  }

  List<Experience> get _selectedExperiences {
    return widget.availableExperiences
        .where((Experience e) => _linkedExperienceIds.contains(e.id))
        .toList(growable: false);
  }

  List<String> get _orphanExperienceIds {
    final Set<String> available =
        widget.availableExperiences.map((Experience e) => e.id).toSet();
    return _linkedExperienceIds.where((String id) => !available.contains(id)).toList();
  }

  List<String> get _orphanEssayVersionIds {
    final Set<String> available =
        widget.availableEssayVersions.map((EssayVersion v) => v.id).toSet();
    return _linkedEssayVersionIds.where((String id) => !available.contains(id)).toList();
  }

  List<String> get _orphanInterviewAnswerIds {
    final Set<String> available =
        widget.availableInterviewAnswers.map((InterviewAnswer a) => a.id).toSet();
    return _linkedInterviewAnswerIds
        .where((String id) => !available.contains(id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: widget.initial == null ? '지원 기록 추가' : '지원 기록 수정',
                icon: Icons.work_outline,
                accent: AppColors.application,
                accentTint: AppColors.applicationTint,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: _company,
                      decoration: const InputDecoration(labelText: '회사명'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _position,
                      decoration: const InputDecoration(labelText: '직무'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _status,
                      decoration: const InputDecoration(labelText: '상태'),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final String preset in _statusPresets)
                          ChoiceChip(
                            label: Text(preset),
                            selected: _status.text.trim() == preset,
                            selectedColor: AppColors.applicationTint,
                            onSelected: (bool selected) {
                              if (!selected) {
                                return;
                              }
                              setState(() => _status.text = preset);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _jobUrl,
                      decoration: const InputDecoration(
                        labelText: '공고 링크',
                        hintText: 'https://',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 10),
                    YearMonthField(
                      label: '지원 마감',
                      value: _deadline,
                      helpText: '마감',
                      onChanged: (DateTime? value) => setState(() => _deadline = value),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: '메모'),
                    ),
                    const SizedBox(height: 16),
                    const Text('연결 경험', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    if (widget.availableExperiences.isEmpty)
                      const Text(
                        '저장된 경험이 없습니다.',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final Experience e in widget.availableExperiences)
                            FilterChip(
                              selected: _linkedExperienceIds.contains(e.id),
                              label: Text(
                                [
                                  e.title.isEmpty ? '(제목 없음)' : e.title,
                                  if (ExperienceStarValidator.missingMessages(e).isNotEmpty)
                                    '· STAR 보완',
                                ].join(' '),
                              ),
                              selectedColor: AppColors.applicationTint,
                              checkmarkColor: AppColors.application,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _linkedExperienceIds.add(e.id);
                                  } else {
                                    _linkedExperienceIds.remove(e.id);
                                  }
                                });
                              },
                            ),
                          for (final String orphanId in _orphanExperienceIds)
                            FilterChip(
                              selected: true,
                              label: Text(
                                '삭제된 경험 · ${orphanId.length > 12 ? '${orphanId.substring(0, 12)}…' : orphanId}',
                              ),
                              selectedColor: AppColors.warningTint,
                              checkmarkColor: AppColors.warning,
                              onSelected: (bool selected) {
                                if (!selected) {
                                  setState(() => _linkedExperienceIds.remove(orphanId));
                                }
                              },
                            ),
                        ],
                      ),
                    if (_selectedExperiences.isNotEmpty &&
                        ExperienceStarValidator.issuesFor(_selectedExperiences).isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warningTint,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          'STAR 보완 필요 '
                          '${ExperienceStarValidator.issuesFor(_selectedExperiences).length}건',
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    const Text('연결 자소서 버전', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    if (widget.availableEssayVersions.isEmpty)
                      const Text(
                        '저장된 자소서 버전이 없습니다.',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final EssayVersion version in widget.availableEssayVersions)
                            FilterChip(
                              selected: _linkedEssayVersionIds.contains(version.id),
                              label: Text(_essayChipLabel(version)),
                              selectedColor: AppColors.masterTint,
                              checkmarkColor: AppColors.master,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _linkedEssayVersionIds.add(version.id);
                                  } else {
                                    _linkedEssayVersionIds.remove(version.id);
                                  }
                                });
                              },
                            ),
                          for (final String orphanId in _orphanEssayVersionIds)
                            FilterChip(
                              selected: true,
                              label: Text(
                                '삭제된 버전 · ${orphanId.length > 12 ? '${orphanId.substring(0, 12)}…' : orphanId}',
                              ),
                              selectedColor: AppColors.warningTint,
                              checkmarkColor: AppColors.warning,
                              onSelected: (bool selected) {
                                if (!selected) {
                                  setState(() => _linkedEssayVersionIds.remove(orphanId));
                                }
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    const Text('연결 면접 답변', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    if (widget.availableInterviewAnswers.isEmpty)
                      const Text(
                        '저장된 면접 답변이 없습니다.',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final InterviewAnswer answer
                              in widget.availableInterviewAnswers)
                            FilterChip(
                              selected: _linkedInterviewAnswerIds.contains(answer.id),
                              label: Text(_interviewChipLabel(answer)),
                              selectedColor: AppColors.coachingTint,
                              checkmarkColor: AppColors.coaching,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _linkedInterviewAnswerIds.add(answer.id);
                                  } else {
                                    _linkedInterviewAnswerIds.remove(answer.id);
                                  }
                                });
                              },
                            ),
                          for (final String orphanId in _orphanInterviewAnswerIds)
                            FilterChip(
                              selected: true,
                              label: Text(
                                '삭제된 답변 · ${orphanId.length > 12 ? '${orphanId.substring(0, 12)}…' : orphanId}',
                              ),
                              selectedColor: AppColors.warningTint,
                              checkmarkColor: AppColors.warning,
                              onSelected: (bool selected) {
                                if (!selected) {
                                  setState(
                                    () => _linkedInterviewAnswerIds.remove(orphanId),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
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
                    style: FilledButton.styleFrom(backgroundColor: AppColors.application),
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
