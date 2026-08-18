import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/spec_summary_section.dart';
import 'package:flutter/material.dart';

class ExperienceLibraryPanel extends StatefulWidget {
  const ExperienceLibraryPanel({
    super.key,
    required this.experiences,
    required this.specs,
    required this.enabled,
    required this.onDeleteSpec,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onUseForEssay,
    this.onInterviewFromExperience,
    this.onPortfolioOutline,
  });

  final List<Experience> experiences;
  final List<SpecItem> specs;
  final bool enabled;
  final ValueChanged<SpecItem> onDeleteSpec;
  final ValueChanged<Experience> onEdit;
  final ValueChanged<Experience> onDelete;
  final ValueChanged<Experience> onDuplicate;
  final ValueChanged<Experience> onUseForEssay;
  final ValueChanged<Experience>? onInterviewFromExperience;
  final ValueChanged<Experience>? onPortfolioOutline;

  @override
  State<ExperienceLibraryPanel> createState() => _ExperienceLibraryPanelState();
}

class _ExperienceLibraryPanelState extends State<ExperienceLibraryPanel> {
  ExperienceType? _typeFilter;
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final List<Experience> filtered = widget.experiences
        .where((Experience experience) {
          final bool typeOk = _typeFilter == null || experience.type == _typeFilter;
          final String haystack = [
            experience.title,
            experience.organization,
            experience.role,
            experience.action,
            experience.result,
            ...experience.competencyTags,
          ].join(" ").toLowerCase();
          final bool queryOk = _query.trim().isEmpty || haystack.contains(_query.trim().toLowerCase());
          return typeOk && queryOk;
        })
        .toList(growable: false);

    return AppCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: "저장된 경험 카드",
            icon: Icons.inventory_2_outlined,
            accent: AppColors.experience,
            accentTint: AppColors.experienceTint,
            trailing: StatusPill(
              label: "${widget.experiences.length}개",
              color: AppColors.experience,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 168),
            child: SingleChildScrollView(
              child: SpecSummarySection(
                items: widget.specs,
                compact: true,
                wrapInCard: false,
                onDelete: widget.enabled ? widget.onDeleteSpec : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (String value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: "검색",
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<ExperienceType?>(
                  initialValue: _typeFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(isDense: true, labelText: "유형"),
                  items: [
                    const DropdownMenuItem<ExperienceType?>(
                      value: null,
                      child: Text("전체"),
                    ),
                    for (final ExperienceType type in ExperienceType.values)
                      DropdownMenuItem<ExperienceType?>(
                        value: type,
                        child: Text(type.label),
                      ),
                  ],
                  onChanged: (ExperienceType? value) => setState(() => _typeFilter = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: "표시할 경험 카드가 없습니다",
              message: "필터를 바꾸거나 새 경험을 저장해 주세요.",
              compact: true,
            )
          else
            SizedBox(
              height: 220,
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (BuildContext context, int index) {
                  return _ExperienceLibraryCard(
                    experience: filtered[index],
                    enabled: widget.enabled,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                    onDuplicate: widget.onDuplicate,
                    onUseForEssay: widget.onUseForEssay,
                    onInterviewFromExperience: widget.onInterviewFromExperience,
                    onPortfolioOutline: widget.onPortfolioOutline,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ExperienceLibraryCard extends StatelessWidget {
  const _ExperienceLibraryCard({
    required this.experience,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onUseForEssay,
    this.onInterviewFromExperience,
    this.onPortfolioOutline,
  });

  final Experience experience;
  final bool enabled;
  final ValueChanged<Experience> onEdit;
  final ValueChanged<Experience> onDelete;
  final ValueChanged<Experience> onDuplicate;
  final ValueChanged<Experience> onUseForEssay;
  final ValueChanged<Experience>? onInterviewFromExperience;
  final ValueChanged<Experience>? onPortfolioOutline;

  @override
  Widget build(BuildContext context) {
    final String detail = [
      if (experience.period.displayText.isNotEmpty) experience.period.displayText,
      if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
      if (experience.role.trim().isNotEmpty) experience.role.trim(),
    ].join(" · ");
    final String starPreview = _starPreview(experience);
    final List<String> tags = experience.competencyTags.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AccentIconChip(
                icon: Icons.inventory_2_outlined,
                color: AppColors.experience,
                tint: AppColors.experienceTint,
                size: 38,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            experience.title.softWrapWords(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TypeBadge(label: experience.type.label),
                      ],
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        detail.softWrapWords(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                    if (starPreview.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        starPreview.softWrapWords(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final String tag in tags) AppTag(tag)],
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 4),
          ActionBar(
            children: [
              TextButton.icon(
                onPressed: enabled ? () => onEdit(experience) : null,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text("수정"),
              ),
              TextButton.icon(
                onPressed: enabled ? () => onDuplicate(experience) : null,
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text("복제"),
              ),
              TextButton.icon(
                onPressed: enabled ? () => onUseForEssay(experience) : null,
                icon: const Icon(Icons.article_outlined, size: 16),
                label: const Text("자소서에 사용"),
              ),
              if (onInterviewFromExperience != null)
                TextButton.icon(
                  onPressed: enabled
                      ? () => onInterviewFromExperience!(experience)
                      : null,
                  icon: const Icon(Icons.record_voice_over_outlined, size: 16),
                  label: const Text("면접"),
                ),
              if (onPortfolioOutline != null)
                TextButton.icon(
                  onPressed:
                      enabled ? () => onPortfolioOutline!(experience) : null,
                  icon: const Icon(Icons.layers_outlined, size: 16),
                  label: const Text("포트폴리오"),
                ),
              TextButton.icon(
                onPressed: enabled ? () => onDelete(experience) : null,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text("삭제"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _starPreview(Experience experience) {
  final List<String> parts = [
    if (experience.action.trim().isNotEmpty) experience.action.trim(),
    if (experience.result.trim().isNotEmpty) experience.result.trim(),
    if (experience.situation.trim().isNotEmpty) experience.situation.trim(),
  ];
  if (parts.isEmpty) {
    return "";
  }
  final String raw = parts.first;
  if (raw.length <= 90) {
    return raw;
  }
  return "${raw.substring(0, 90).trimRight()}…";
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.experienceTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.experience),
      ),
    );
  }
}
