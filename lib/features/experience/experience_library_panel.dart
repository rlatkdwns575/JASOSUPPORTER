import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

class ExperienceLibraryPanel extends StatefulWidget {
  const ExperienceLibraryPanel({
    super.key,
    required this.experiences,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onUseForEssay,
  });

  final List<Experience> experiences;
  final bool enabled;
  final ValueChanged<Experience> onEdit;
  final ValueChanged<Experience> onDelete;
  final ValueChanged<Experience> onDuplicate;
  final ValueChanged<Experience> onUseForEssay;

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
            subtitle: widget.experiences.isEmpty ? "아직 저장된 카드가 없습니다." : "수정·삭제하거나 자소서 작업에 바로 사용할 수 있습니다.",
            icon: Icons.inventory_2_outlined,
            trailing: StatusPill(label: "${widget.experiences.length}개"),
          ),
          const SizedBox(height: 10),
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
              message: "필터를 바꾸거나 경험·스펙 폼에서 새 카드를 저장해 주세요.",
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
  });

  final Experience experience;
  final bool enabled;
  final ValueChanged<Experience> onEdit;
  final ValueChanged<Experience> onDelete;
  final ValueChanged<Experience> onDuplicate;
  final ValueChanged<Experience> onUseForEssay;

  @override
  Widget build(BuildContext context) {
    final String detail = [
      if (experience.period.displayText.isNotEmpty) experience.period.displayText,
      if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
      if (experience.role.trim().isNotEmpty) experience.role.trim(),
    ].join(" · ");

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(label: experience.type.label, icon: Icons.inventory_2_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  experience.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
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
              TextButton.icon(
                onPressed: enabled ? () => onDelete(experience) : null,
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
