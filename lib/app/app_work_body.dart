import 'package:chatgptmini/app/app_section.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_route_body.dart';
import 'package:chatgptmini/features/home/home_dashboard.dart';
import 'package:chatgptmini/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';

/// 섹션별 작업 본문. 복잡한 모드 본문([mainWorkspace])은 셸에서 주입한다.
class AppWorkBody extends StatelessWidget {
  const AppWorkBody({
    super.key,
    required this.section,
    required this.location,
    required this.header,
    required this.mainWorkspace,
    required this.experiences,
    required this.specCount,
    required this.portfolioProjects,
    required this.applicationRecords,
    required this.savedEssayVersionCount,
    required this.interviewAnswerCount,
    required this.pendingExperiences,
    required this.pendingSpecs,
    required this.lastSavedCount,
    required this.enabled,
    required this.onNavigate,
    required this.onAddExperience,
    required this.onExportExperiences,
    required this.onOpenCategory,
    required this.onOpenExperience,
    required this.onConfirmSave,
    required this.onGoExperienceList,
    required this.onApplyEssay,
    required this.onInterview,
    required this.onAddAnother,
    required this.onEditExperience,
    required this.onUseForEssay,
    required this.onInterviewFromExperience,
    required this.onPortfolioOutline,
    required this.onBackFromDetail,
    required this.onBackFromConfirm,
    this.onEditPendingExperience,
    this.onEditPendingSpec,
  });

  final AppSection section;
  final String location;
  final Widget header;
  final Widget mainWorkspace;
  final List<Experience> experiences;
  final int specCount;
  final List<PortfolioProject> portfolioProjects;
  final List<ApplicationRecord> applicationRecords;
  final int savedEssayVersionCount;
  final int interviewAnswerCount;
  final List<Experience> pendingExperiences;
  final List<SpecItem> pendingSpecs;
  final int lastSavedCount;
  final bool enabled;
  final ValueChanged<String> onNavigate;
  final VoidCallback onAddExperience;
  final VoidCallback onExportExperiences;
  final ValueChanged<ExperienceCategory> onOpenCategory;
  final ValueChanged<Experience> onOpenExperience;
  final VoidCallback onConfirmSave;
  final VoidCallback onGoExperienceList;
  final VoidCallback onApplyEssay;
  final VoidCallback onInterview;
  final VoidCallback onAddAnother;
  final ValueChanged<Experience> onEditExperience;
  final ValueChanged<Experience> onUseForEssay;
  final ValueChanged<Experience> onInterviewFromExperience;
  final ValueChanged<Experience> onPortfolioOutline;
  final VoidCallback onBackFromDetail;
  final VoidCallback onBackFromConfirm;
  final ValueChanged<Experience>? onEditPendingExperience;
  final ValueChanged<SpecItem>? onEditPendingSpec;

  Widget _withHeader(Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case AppSection.home:
        return HomeDashboard(
          experiences: experiences,
          portfolioProjects: portfolioProjects,
          applicationRecords: applicationRecords,
          savedEssayVersionCount: savedEssayVersionCount,
          interviewAnswerCount: interviewAnswerCount,
          onNavigate: onNavigate,
          onAddExperience: onAddExperience,
        );
      case AppSection.settings:
        return SettingsScreen(
          experienceCount: experiences.length,
          specCount: specCount,
          interviewAnswerCount: interviewAnswerCount,
          onExportExperiences: onExportExperiences,
        );
      case AppSection.experience:
        return ExperienceRouteBody(
          location: location,
          header: header,
          formBody: mainWorkspace,
          experiences: experiences,
          specCount: specCount,
          pendingExperiences: pendingExperiences,
          pendingSpecs: pendingSpecs,
          lastSavedCount: lastSavedCount,
          enabled: enabled,
          onOpenCategory: onOpenCategory,
          onOpenExperience: onOpenExperience,
          onConfirmSave: onConfirmSave,
          onGoExperienceList: onGoExperienceList,
          onApplyEssay: onApplyEssay,
          onInterview: onInterview,
          onAddAnother: onAddAnother,
          onEditExperience: onEditExperience,
          onUseForEssay: onUseForEssay,
          onInterviewFromExperience: onInterviewFromExperience,
          onPortfolioOutline: onPortfolioOutline,
          onBackFromDetail: onBackFromDetail,
          onBackFromConfirm: onBackFromConfirm,
          onEditPendingExperience: onEditPendingExperience,
          onEditPendingSpec: onEditPendingSpec,
        );
      case AppSection.masterResume:
      case AppSection.portfolio:
      case AppSection.interview:
      case AppSection.applications:
        return _withHeader(mainWorkspace);
    }
  }
}
