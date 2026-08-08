import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_flow_panels.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/spec_add_screen.dart';
import 'package:flutter/material.dart';

/// 경험 섹션 서브라우트 본문. 헤더와 폼 본체는 셸에서 주입한다.
class ExperienceRouteBody extends StatelessWidget {
  const ExperienceRouteBody({
    super.key,
    required this.location,
    required this.header,
    required this.formBody,
    required this.experiences,
    required this.specCount,
    required this.pendingExperiences,
    required this.pendingSpecs,
    required this.lastSavedCount,
    required this.enabled,
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

  final String location;
  final Widget header;
  final Widget formBody;
  final List<Experience> experiences;
  final int specCount;
  final List<Experience> pendingExperiences;
  final List<SpecItem> pendingSpecs;
  final int lastSavedCount;
  final bool enabled;
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

  Experience? _experienceById(String id) {
    for (final Experience experience in experiences) {
      if (experience.id == id) {
        return experience;
      }
    }
    return null;
  }

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
    if (location.startsWith('/experience/specs')) {
      return const SpecAddScreen();
    }
    if (location.startsWith('/experience/confirm')) {
      return _withHeader(
        ExperienceConfirmPanel(
          experiences: pendingExperiences,
          specItems: pendingSpecs,
          enabled: enabled,
          onBack: onBackFromConfirm,
          onConfirmSave: onConfirmSave,
          onEditExperience: onEditPendingExperience,
          onEditSpec: onEditPendingSpec,
        ),
      );
    }
    if (location.startsWith('/experience/complete')) {
      return _withHeader(
        ExperienceCompletePanel(
          savedCount: lastSavedCount,
          onGoList: onGoExperienceList,
          onApplyEssay: onApplyEssay,
          onInterview: onInterview,
          onAddAnother: onAddAnother,
        ),
      );
    }
    if (location.startsWith('/experience/detail/')) {
      final String id = location.split('/').last;
      final Experience? experience = _experienceById(id);
      return _withHeader(
        experience == null
            ? const Center(child: Text('경험을 찾을 수 없습니다.'))
            : ExperienceDetailPanel(
                experience: experience,
                enabled: enabled,
                onEdit: () => onEditExperience(experience),
                onUseForEssay: () => onUseForEssay(experience),
                onInterview: () => onInterviewFromExperience(experience),
                onPortfolioOutline: () => onPortfolioOutline(experience),
                onBack: onBackFromDetail,
              ),
      );
    }
    if (location.startsWith('/experience/form')) {
      return _withHeader(formBody);
    }
    return _withHeader(
      ExperienceHubPanel(
        experiences: experiences,
        specCount: specCount,
        onOpenCategory: onOpenCategory,
        onOpenExperience: onOpenExperience,
      ),
    );
  }
}
