import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/portfolio/career_artifact_view.dart';
import 'package:flutter/material.dart';

export 'package:chatgptmini/features/portfolio/career_artifact_view.dart';

class CareerArtifactPanel extends StatelessWidget {
  const CareerArtifactPanel({
    super.key,
    required this.view,
    required this.experiences,
    required this.portfolioProjects,
    required this.applicationRecords,
    required this.enabled,
    required this.onCreatePortfolioProject,
    required this.onDeletePortfolioProject,
    required this.onCreateApplicationRecord,
    required this.onDeleteApplicationRecord,
    this.onEditPortfolioProject,
    this.onPreviewPortfolioProject,
    this.onEditApplicationRecord,
  });

  final CareerArtifactView view;
  final List<Experience> experiences;
  final List<PortfolioProject> portfolioProjects;
  final List<ApplicationRecord> applicationRecords;
  final bool enabled;
  final ValueChanged<Experience> onCreatePortfolioProject;
  final ValueChanged<PortfolioProject> onDeletePortfolioProject;
  final VoidCallback onCreateApplicationRecord;
  final ValueChanged<ApplicationRecord> onDeleteApplicationRecord;
  final ValueChanged<PortfolioProject>? onEditPortfolioProject;
  final ValueChanged<PortfolioProject>? onPreviewPortfolioProject;
  final ValueChanged<ApplicationRecord>? onEditApplicationRecord;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: view == CareerArtifactView.portfolio ? _buildPortfolio() : _buildApplications(),
    );
  }

  Widget _buildPortfolio() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: "포트폴리오 개요",
            icon: Icons.layers_outlined,
            accent: AppColors.portfolio,
            accentTint: AppColors.portfolioTint,
            trailing: StatusPill(label: "${portfolioProjects.length}개", color: AppColors.portfolio),
          ),
          const SizedBox(height: 14),
          if (experiences.isEmpty)
            _hintBox("저장된 경험이 없습니다.")
          else ...[
            ActionBar(
              children: [
                for (final Experience experience in experiences.take(12))
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.portfolio),
                    onPressed: enabled ? () => onCreatePortfolioProject(experience) : null,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: Text("${experience.title} 변환"),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          if (portfolioProjects.isEmpty)
            _emptyBox(Icons.layers_outlined, "저장된 포트폴리오 프로젝트가 없습니다.")
          else
            for (int i = 0; i < portfolioProjects.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ProjectCard(
                project: portfolioProjects[i],
                enabled: enabled,
                onDelete: onDeletePortfolioProject,
                onEdit: onEditPortfolioProject,
                onPreview: onPreviewPortfolioProject,
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildApplications() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: "지원 기록",
            icon: Icons.work_outline,
            accent: AppColors.application,
            accentTint: AppColors.applicationTint,
            trailing: StatusPill(label: "${applicationRecords.length}곳", color: AppColors.application),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.application),
              onPressed: enabled ? onCreateApplicationRecord : null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("지원 기록 추가"),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          if (applicationRecords.isEmpty)
            _emptyBox(Icons.work_outline, "저장된 지원 기록이 없습니다.")
          else
            for (int i = 0; i < applicationRecords.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ApplicationCard(
                record: applicationRecords[i],
                experiences: experiences,
                enabled: enabled,
                onDelete: onDeleteApplicationRecord,
                onEdit: onEditApplicationRecord,
              ),
            ],
        ],
      ),
    );
  }

  Widget _hintBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text.softWrapWords(),
        style: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant, height: 1.4),
      ),
    );
  }

  Widget _emptyBox(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            text.softWrapWords(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.enabled,
    required this.onDelete,
    this.onEdit,
    this.onPreview,
  });

  final PortfolioProject project;
  final bool enabled;
  final ValueChanged<PortfolioProject> onDelete;
  final ValueChanged<PortfolioProject>? onEdit;
  final ValueChanged<PortfolioProject>? onPreview;

  @override
  Widget build(BuildContext context) {
    final String body = project.portfolioCopy.isEmpty
        ? "연결 경험: ${project.linkedExperienceIds.join(", ")}"
        : project.portfolioCopy;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccentIconChip(
            icon: Icons.layers_outlined,
            color: AppColors.portfolio,
            tint: AppColors.portfolioTint,
            size: 38,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title.softWrapWords(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  body.softWrapWords(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
                if (project.linkedExperienceIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppTag("연결 경험 ${project.linkedExperienceIds.length}개"),
                ],
              ],
            ),
          ),
          if (onPreview != null)
            IconButton(
              onPressed: enabled ? () => onPreview!(project) : null,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              color: AppColors.portfolio,
              tooltip: "미리보기",
            ),
          if (onEdit != null)
            IconButton(
              onPressed: enabled ? () => onEdit!(project) : null,
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.portfolio,
              tooltip: "개요 편집",
            ),
          IconButton(
            onPressed: enabled ? () => onDelete(project) : null,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            tooltip: "삭제",
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.record,
    required this.experiences,
    required this.enabled,
    required this.onDelete,
    this.onEdit,
  });

  final ApplicationRecord record;
  final List<Experience> experiences;
  final bool enabled;
  final ValueChanged<ApplicationRecord> onDelete;
  final ValueChanged<ApplicationRecord>? onEdit;

  List<String> get _linkedExperienceTitles {
    final Map<String, String> byId = {
      for (final Experience e in experiences)
        e.id: e.title.trim().isEmpty ? '(제목 없음)' : e.title.trim(),
    };
    return [
      for (final String id in record.linkedExperienceIds)
        byId[id] ?? '삭제된 경험',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<String> experienceTitles = _linkedExperienceTitles;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccentIconChip(
            icon: Icons.work_outline,
            color: AppColors.application,
            tint: AppColors.applicationTint,
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
                        "${record.companyName} · ${record.position}".softWrapWords(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (record.status.trim().isNotEmpty) _StatusBadge(label: record.status.trim()),
                  ],
                ),
                if (record.deadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "마감 ${record.deadline!.year}.${record.deadline!.month.toString().padLeft(2, "0")}",
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
                if (record.jobPostingUrl.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.jobPostingUrl.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.application),
                  ),
                ],
                if (record.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.notes.trim().softWrapWords(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                ],
                if (experienceTitles.isNotEmpty ||
                    record.submittedEssayVersionIds.isNotEmpty ||
                    record.linkedInterviewAnswerIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final String title in experienceTitles.take(3))
                        AppTag(title),
                      if (experienceTitles.length > 3)
                        AppTag('경험 +${experienceTitles.length - 3}'),
                      if (record.submittedEssayVersionIds.isNotEmpty)
                        AppTag("자소서 ${record.submittedEssayVersionIds.length}"),
                      if (record.linkedInterviewAnswerIds.isNotEmpty)
                        AppTag("면접 ${record.linkedInterviewAnswerIds.length}"),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              onPressed: enabled ? () => onEdit!(record) : null,
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: AppColors.application,
              tooltip: "수정",
            ),
          IconButton(
            onPressed: enabled ? () => onDelete(record) : null,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            tooltip: "삭제",
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.applicationTint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.application),
      ),
    );
  }
}
