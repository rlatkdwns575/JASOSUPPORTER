import 'package:chatgptmini/features/master_resume/master_essay_prompt_planner.dart';
import 'package:flutter/material.dart';

/// 마스터 자소서 탭·문항 입력 컨트롤러.
///
/// [TabController]는 vsync가 필요하므로 Riverpod Provider가 아니라
/// 셸 State의 initState에서 생성한다.
class MasterResumeWorkspaceController {
  MasterResumeWorkspaceController({required TickerProvider vsync})
      : tabController = TabController(length: 7, vsync: vsync),
        qControllers = List<TextEditingController>.generate(
          6,
          (_) => TextEditingController(),
        );

  final TabController tabController;
  final List<TextEditingController> qControllers;
  final TextEditingController fullDraft = TextEditingController();
  final TextEditingController targetJob = TextEditingController();

  int get currentTabIndex => tabController.index;

  String get targetJobText => targetJob.text.trim();

  void applyDraft({required int tabIndex, required String text}) {
    final String value = text.trim();
    if (tabIndex < 6) {
      qControllers[tabIndex].text = value;
    } else {
      fullDraft.text = value;
    }
  }

  MasterEssayPromptPlan questionDraftPlan({
    required MasterEssayPromptPlanner planner,
    required int index0Based,
    required List<String> selectedExperienceIds,
  }) {
    return planner.questionDraft(
      index0Based: index0Based,
      userDraft: qControllers[index0Based].text.trim(),
      targetJob: targetJobText,
      selectedExperienceIds: selectedExperienceIds,
    );
  }

  MasterEssayPromptPlan fullReviewPlan({
    required MasterEssayPromptPlanner planner,
  }) {
    return planner.fullReview(
      fullDraft: fullDraft.text,
      targetJob: targetJobText,
    );
  }

  void dispose() {
    tabController.dispose();
    for (final TextEditingController c in qControllers) {
      c.dispose();
    }
    fullDraft.dispose();
    targetJob.dispose();
  }
}
