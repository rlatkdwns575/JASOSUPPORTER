import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/portfolio/career_artifact_panel.dart';
import 'package:chatgptmini/features/portfolio/portfolio_outline_preview.dart';
import 'package:flutter/material.dart';

/// 포트폴리오·지원 관리 서브라우트 본문.
class PortfolioRouteBody extends StatelessWidget {
  const PortfolioRouteBody({
    super.key,
    required this.location,
    required this.view,
    required this.experiences,
    required this.portfolioProjects,
    required this.applicationRecords,
    required this.enabled,
    required this.onCreatePortfolioProject,
    required this.onDeletePortfolioProject,
    required this.onCreateApplicationRecord,
    required this.onDeleteApplicationRecord,
    required this.onEditPortfolioProject,
    required this.onPreviewPortfolioProject,
    required this.onEditApplicationRecord,
    required this.onBackFromPreview,
    required this.onRequestPolish,
  });

  final String location;
  final CareerArtifactView view;
  final List<Experience> experiences;
  final List<PortfolioProject> portfolioProjects;
  final List<ApplicationRecord> applicationRecords;
  final bool enabled;
  final ValueChanged<Experience> onCreatePortfolioProject;
  final ValueChanged<PortfolioProject> onDeletePortfolioProject;
  final VoidCallback onCreateApplicationRecord;
  final ValueChanged<ApplicationRecord> onDeleteApplicationRecord;
  final ValueChanged<PortfolioProject> onEditPortfolioProject;
  final ValueChanged<PortfolioProject> onPreviewPortfolioProject;
  final ValueChanged<ApplicationRecord> onEditApplicationRecord;
  final VoidCallback onBackFromPreview;
  final ValueChanged<PortfolioProject> onRequestPolish;

  PortfolioProject? _projectById(String id) {
    for (final PortfolioProject project in portfolioProjects) {
      if (project.id == id) {
        return project;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (location.startsWith('/portfolio/preview/')) {
      final String id = location.split('/').last;
      final PortfolioProject? found = _projectById(id);
      if (found == null) {
        return const Center(child: Text('포트폴리오 개요를 찾을 수 없습니다.'));
      }
      final PortfolioProject project = found;
      return PortfolioOutlinePreviewPanel(
        project: project,
        enabled: enabled,
        onBack: onBackFromPreview,
        onEdit: () => onEditPortfolioProject(project),
        onRequestPolish: () => onRequestPolish(project),
      );
    }

    return CareerArtifactPanel(
      view: view,
      experiences: experiences,
      portfolioProjects: portfolioProjects,
      applicationRecords: applicationRecords,
      enabled: enabled,
      onCreatePortfolioProject: onCreatePortfolioProject,
      onDeletePortfolioProject: onDeletePortfolioProject,
      onCreateApplicationRecord: onCreateApplicationRecord,
      onDeleteApplicationRecord: onDeleteApplicationRecord,
      onEditPortfolioProject: onEditPortfolioProject,
      onPreviewPortfolioProject: onPreviewPortfolioProject,
      onEditApplicationRecord: onEditApplicationRecord,
    );
  }
}
