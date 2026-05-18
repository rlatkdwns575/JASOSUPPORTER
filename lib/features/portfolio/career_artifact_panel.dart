import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

class CareerArtifactPanel extends StatelessWidget {
  const CareerArtifactPanel({
    super.key,
    required this.experiences,
    required this.portfolioProjects,
    required this.applicationRecords,
    required this.enabled,
    required this.onCreatePortfolioProject,
    required this.onDeletePortfolioProject,
    required this.onCreateApplicationRecord,
    required this.onDeleteApplicationRecord,
  });

  final List<Experience> experiences;
  final List<PortfolioProject> portfolioProjects;
  final List<ApplicationRecord> applicationRecords;
  final bool enabled;
  final ValueChanged<Experience> onCreatePortfolioProject;
  final ValueChanged<PortfolioProject> onDeletePortfolioProject;
  final VoidCallback onCreateApplicationRecord;
  final ValueChanged<ApplicationRecord> onDeleteApplicationRecord;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            backgroundColor: AppColors.surfaceContainerLowest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: "포트폴리오 프로젝트",
                  subtitle: "저장된 경험을 포트폴리오 프로젝트 초안으로 변환합니다.",
                  icon: Icons.layers_outlined,
                  trailing: StatusPill(label: "${portfolioProjects.length}개"),
                ),
                const SizedBox(height: 10),
                if (experiences.isEmpty)
                  const Text(
                    "먼저 경험·스펙 모드에서 경험 카드를 저장해 주세요.",
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  )
                else
                  ActionBar(
                    children: [
                      for (final Experience experience in experiences.take(4))
                        OutlinedButton.icon(
                          onPressed: enabled ? () => onCreatePortfolioProject(experience) : null,
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: Text("${experience.title} 변환"),
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                _ProjectList(
                  projects: portfolioProjects,
                  enabled: enabled,
                  onDelete: onDeletePortfolioProject,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            backgroundColor: AppColors.surfaceContainerLowest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: "지원 기록",
                  subtitle: "회사·직무별 지원 상태와 연결 경험을 기록합니다.",
                  icon: Icons.business_center_outlined,
                  trailing: StatusPill(label: "${applicationRecords.length}개"),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: enabled ? onCreateApplicationRecord : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("지원 기록 추가"),
                  ),
                ),
                const SizedBox(height: 10),
                _ApplicationList(
                  records: applicationRecords,
                  enabled: enabled,
                  onDelete: onDeleteApplicationRecord,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({
    required this.projects,
    required this.enabled,
    required this.onDelete,
  });

  final List<PortfolioProject> projects;
  final bool enabled;
  final ValueChanged<PortfolioProject> onDelete;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Text("저장된 포트폴리오 프로젝트가 없습니다.", style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant));
    }
    return Column(
      children: [
        for (final PortfolioProject project in projects)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(project.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
              project.portfolioCopy.isEmpty
                  ? "연결 경험: ${project.linkedExperienceIds.join(", ")}"
                  : project.portfolioCopy,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: enabled ? () => onDelete(project) : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
      ],
    );
  }
}

class _ApplicationList extends StatelessWidget {
  const _ApplicationList({
    required this.records,
    required this.enabled,
    required this.onDelete,
  });

  final List<ApplicationRecord> records;
  final bool enabled;
  final ValueChanged<ApplicationRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Text("저장된 지원 기록이 없습니다.", style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant));
    }
    return Column(
      children: [
        for (final ApplicationRecord record in records)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              "${record.companyName} · ${record.position}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              [
                record.status,
                if (record.deadline != null)
                  "마감: ${record.deadline!.year}.${record.deadline!.month}.${record.deadline!.day}",
                if (record.notes.trim().isNotEmpty) record.notes.trim(),
              ].join("\n"),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: enabled ? () => onDelete(record) : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
      ],
    );
  }
}
