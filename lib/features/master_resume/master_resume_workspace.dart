import 'dart:math' as math;

import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/data/providers/master_essay_selection_provider.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/data/services/export_service.dart';
import 'package:chatgptmini/core/constants/jaso_constants.dart';
import 'package:chatgptmini/features/master_resume/master_resume_tip_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Q1~Q6 문항 표시 + 문항별 초안 입력, 전체 초고 첨삭 탭.
class MasterResumeWorkspace extends ConsumerStatefulWidget {
  const MasterResumeWorkspace({
    super.key,
    required this.tabController,
    required this.qControllers,
    required this.fullDraftController,
    required this.targetJobController,
    required this.availableExperiences,
    required this.savedVersionCounts,
    required this.enabled,
    required this.onAiForQuestion,
    required this.onAiExperienceMatch,
    required this.onAiFullReview,
    required this.onSaveEssayVersion,
    required this.onLoadEssayVersion,
  });

  final TabController tabController;
  final List<TextEditingController> qControllers;
  final TextEditingController fullDraftController;
  final TextEditingController targetJobController;
  final List<Experience> availableExperiences;
  final Map<int, int> savedVersionCounts;
  final bool enabled;
  final void Function(int qIndex0Based, List<String> selectedExperienceIds) onAiForQuestion;
  final void Function(int qIndex0Based) onAiExperienceMatch;
  final VoidCallback onAiFullReview;
  final Future<void> Function(int tabIndex, String body, List<String> selectedExperienceIds) onSaveEssayVersion;
  final Future<List<String>?> Function(int tabIndex) onLoadEssayVersion;

  @override
  ConsumerState<MasterResumeWorkspace> createState() => _MasterResumeWorkspaceState();
}

class _MasterResumeWorkspaceState extends ConsumerState<MasterResumeWorkspace> {
  MasterResumeTipContent? _openTip;

  MasterEssaySelectionNotifier get _selection =>
      ref.read(masterEssaySelectionProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingSelection());
  }

  @override
  void didUpdateWidget(covariant MasterResumeWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableExperiences.length != widget.availableExperiences.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingSelection());
    }
  }

  void _consumePendingSelection() {
    if (!mounted) {
      return;
    }
    final List<String> pending =
        ref.read(masterEssayPendingSelectionProvider.notifier).takeAll();
    if (pending.isEmpty) {
      return;
    }
    final Set<String> availableIds =
        widget.availableExperiences.map((Experience e) => e.id).toSet();
    _selection.addAll(
      0,
      pending.where((String id) => availableIds.contains(id)),
    );
  }

  void _showTip(MasterResumeTipContent content) {
    setState(() => _openTip = content);
  }

  void _closeTip() {
    setState(() => _openTip = null);
  }

  Future<void> _export(BuildContext context, int tabIndex) async {
    final String body;
    final String name;
    if (tabIndex < 6) {
      body = widget.qControllers[tabIndex].text.trim();
      name = MasterQuestionCopy.all[tabIndex].id;
    } else {
      body = widget.fullDraftController.text.trim();
      name = "전체초고";
    }
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("저장할 내용이 없습니다.")),
      );
      return;
    }
    await ExportService.pickFormatAndSaveRequest(
      context,
      request: ExportRequest(
        defaultBaseName: name,
        content: body,
        artifactType: ExportArtifactType.masterEssay,
        title: tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : "전체 초고",
        sourceIds: tabIndex < 6 ? _selectedIdsForQuestion(tabIndex) : const [],
      ),
    );
  }

  List<String> _selectedIdsForQuestion(int index) {
    return _selection.idsFor(index);
  }

  int _versionCountForTab(int tabIndex) {
    return widget.savedVersionCounts[tabIndex] ?? 0;
  }

  void _toggleExperienceForQuestion(int questionIndex, String experienceId) {
    _selection.toggle(questionIndex, experienceId);
  }

  void _selectAllExperiencesForQuestion(int questionIndex) {
    _selection.selectAll(
      questionIndex,
      widget.availableExperiences.map((Experience e) => e.id),
    );
  }

  void _clearExperiencesForQuestion(int questionIndex) {
    _selection.clearQuestion(questionIndex);
  }

  Future<void> _loadVersion(int tabIndex) async {
    final List<String>? sourceIds = await widget.onLoadEssayVersion(tabIndex);
    if (sourceIds == null || tabIndex >= 6) {
      return;
    }
    _selection.replaceQuestion(tabIndex, sourceIds);
  }

  double _tipPanelWidth(BuildContext context) {
    return math.min(300.0, MediaQuery.sizeOf(context).width * 0.38).clamp(220.0, 320.0);
  }

  Widget _buildExperienceReferenceStrip() {
    if (widget.availableExperiences.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(14),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: SectionHeader(
          title: "저장된 경험 카드가 없습니다",
          icon: Icons.inventory_2_outlined,
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: "참조 가능한 경험 카드 ${widget.availableExperiences.length}개",
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < widget.availableExperiences.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    _ExperienceRefChip(experience: widget.availableExperiences[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionExperienceSelector(int questionIndex) {
    if (widget.availableExperiences.isEmpty) {
      return const SizedBox.shrink();
    }
    final Map<int, Set<String>> selectionByQuestion =
        ref.watch(masterEssaySelectionProvider);
    final Set<String> selected =
        selectionByQuestion[questionIndex] ?? const <String>{};
    final List<Experience> selectedExperiences = widget.availableExperiences
        .where((Experience experience) => selected.contains(experience.id))
        .toList(growable: false);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: "이 문항에 사용할 경험 선택",
              icon: Icons.fact_check_outlined,
              trailing: StatusPill(
                label: "${selected.length}개 선택",
                icon: Icons.check_circle_outline,
                color: selected.isEmpty ? AppColors.outline : AppColors.success,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton(
                  onPressed: widget.enabled
                      ? () => _selectAllExperiencesForQuestion(questionIndex)
                      : null,
                  child: const Text('전체 선택'),
                ),
                TextButton(
                  onPressed: widget.enabled && selected.isNotEmpty
                      ? () => _clearExperiencesForQuestion(questionIndex)
                      : null,
                  child: const Text('선택 해제'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final Experience experience in widget.availableExperiences)
                  FilterChip(
                    selected: selected.contains(experience.id),
                    showCheckmark: false,
                    label: Text(
                      "${experience.type.label} · ${experience.title}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected.contains(experience.id) ? AppColors.onPrimary : AppColors.onSurface,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    side: BorderSide(
                      color: selected.contains(experience.id) ? AppColors.primary : AppColors.outlineVariant,
                    ),
                    onSelected: widget.enabled
                        ? (_) => _toggleExperienceForQuestion(questionIndex, experience.id)
                        : null,
                  ),
              ],
            ),
            if (selectedExperiences.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final Experience experience in selectedExperiences)
                    _SelectedExperienceSummary(experience: experience),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<String>>(masterEssayPendingSelectionProvider, (
      List<String>? previous,
      List<String> next,
    ) {
      if (next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingSelection());
      }
    });

    final double tipW = _openTip != null ? _tipPanelWidth(context) : 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "지원 희망 직무",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: widget.targetJobController,
                enabled: widget.enabled,
                cursorColor: AppColors.primary,
                minLines: 1,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: kNoneHint,
                  hintStyle: const TextStyle(color: AppColors.outline),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              _buildExperienceReferenceStrip(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              onPressed: widget.enabled
                  ? () async {
                      final StringBuffer buf = StringBuffer();
                      final String job = widget.targetJobController.text.trim();
                      if (job.isNotEmpty) {
                        buf.writeln("=== 지원 희망 직무 ===");
                        buf.writeln(job);
                        buf.writeln();
                      }
                      for (int i = 0; i < 6; i++) {
                        buf.writeln("=== ${MasterQuestionCopy.all[i].id} ===");
                        buf.writeln(widget.qControllers[i].text.trim());
                        buf.writeln();
                      }
                      final String s = buf.toString().trim();
                      if (s.isEmpty) {
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("저장할 문항 내용이 없습니다.")),
                        );
                        return;
                      }
                      await ExportService.pickFormatAndSaveRequest(
                        context,
                        request: ExportRequest(
                          defaultBaseName: "master_Q1_Q6",
                          content: s,
                          artifactType: ExportArtifactType.masterEssay,
                          title: "Q1~Q6 합본",
                          sourceIds: ref
                              .read(masterEssaySelectionProvider)
                              .values
                              .expand((Set<String> ids) => ids)
                              .toSet()
                              .toList(growable: false),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.folder_zip_outlined, size: 18, color: AppColors.primary),
              label: const Text("Q1~Q6 합쳐서 저장", style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ),
        Material(
          surfaceTintColor: Colors.transparent,
          color: AppColors.surface,
          child: TabBar(
            controller: widget.tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.outlineVariant,
            tabs: [
              for (final q in MasterQuestionCopy.all) Tab(text: q.id),
              const Tab(text: "전체 첨삭"),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TabBarView(
                  controller: widget.tabController,
                  children: [
                    for (int i = 0; i < 6; i++) _buildQuestionPage(context, i),
                    _buildFullReviewPage(context),
                  ],
                ),
              ),
              if (_openTip != null) ...[
                const VerticalDivider(width: 1, color: AppColors.outlineVariant),
                SizedBox(
                  width: tipW,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                    child: MasterResumeTipPanel(
                      content: _openTip!,
                      onClose: _closeTip,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionPage(BuildContext context, int i) {
    final MasterQuestionCopy q = MasterQuestionCopy.all[i];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            backgroundColor: AppColors.surfaceContainerLowest,
            child: SectionHeader(
              title: q.title,
              subtitle: "${q.body} (${q.charHint}, 공백 포함)".softWrapWords(),
              icon: Icons.article_outlined,
              trailing: StatusPill(
                label: _versionCountForTab(i) == 0 ? "버전 없음" : "버전 ${_versionCountForTab(i)}개",
                icon: Icons.history_edu_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildQuestionExperienceSelector(i),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: AppColors.surfaceContainerLowest,
            child: TextField(
              controller: widget.qControllers[i],
              enabled: widget.enabled,
              cursorColor: AppColors.primary,
              minLines: 10,
              maxLines: 22,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: kNoneHint,
                hintStyle: const TextStyle(color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ActionBar(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                onPressed: widget.enabled ? () => _showTip(MasterResumeTipContent.forQuestion(q)) : null,
                icon: const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primary),
                label: const Text("작성 팁", style: TextStyle(color: AppColors.primary)),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                onPressed: widget.enabled ? () => widget.onAiForQuestion(i, _selectedIdsForQuestion(i)) : null,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text("${q.id} AI 초안"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: widget.enabled ? () => widget.onAiExperienceMatch(i) : null,
                icon: const Icon(Icons.link_outlined, size: 18),
                label: const Text("경험 매칭"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: widget.enabled ? () => _export(context, i) : null,
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text("저장 (txt/pdf/docx)"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: widget.enabled
                    ? () => widget.onSaveEssayVersion(
                        i,
                        widget.qControllers[i].text.trim(),
                        _selectedIdsForQuestion(i),
                      )
                    : null,
                icon: const Icon(Icons.history_edu_outlined, size: 18),
                label: const Text("버전 저장"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: _versionCountForTab(i) > 0 ? () => _loadVersion(i) : null,
                icon: const Icon(Icons.restore_page_outlined, size: 18),
                label: const Text("버전 불러오기"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullReviewPage(BuildContext context) {
    final Map<int, Set<String>> selectionByQuestion =
        ref.watch(masterEssaySelectionProvider);
    final Set<String> allSelectedIds = selectionByQuestion.values
        .expand((Set<String> ids) => ids)
        .toSet();
    final List<Experience> selectedExperiences = widget.availableExperiences
        .where((Experience e) => allSelectedIds.contains(e.id))
        .toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            backgroundColor: AppColors.surfaceContainerLowest,
            child: SectionHeader(
              title: "전체 초고 첨삭",
              icon: Icons.rate_review_outlined,
              trailing: StatusPill(
                label: _versionCountForTab(6) == 0 ? "버전 없음" : "버전 ${_versionCountForTab(6)}개",
                icon: Icons.history_edu_outlined,
              ),
            ),
          ),
          if (widget.availableExperiences.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              backgroundColor: AppColors.surfaceContainerLowest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: "문항에서 선택한 경험 요약",
                    icon: Icons.fact_check_outlined,
                    trailing: StatusPill(
                      label: "${selectedExperiences.length}개",
                      icon: Icons.check_circle_outline,
                      color: selectedExperiences.isEmpty
                          ? AppColors.outline
                          : AppColors.success,
                    ),
                  ),
                  if (selectedExperiences.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final Experience experience in selectedExperiences)
                          _SelectedExperienceSummary(experience: experience),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: AppColors.surfaceContainerLowest,
            child: TextField(
              controller: widget.fullDraftController,
              enabled: widget.enabled,
              cursorColor: AppColors.primary,
              minLines: 8,
              maxLines: 22,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: "전체 초고를 붙여 넣으세요",
                hintStyle: const TextStyle(color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ActionBar(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                onPressed: () => _showTip(MasterResumeTipContent.fullReview()),
                icon: const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.primary),
                label: const Text("작성 팁", style: TextStyle(color: AppColors.primary)),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                onPressed: widget.enabled ? widget.onAiFullReview : null,
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text("정리·개선점 분석 (AI)"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: widget.enabled ? () => _export(context, 6) : null,
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text("저장 (txt/pdf/docx)"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: widget.enabled
                    ? () => widget.onSaveEssayVersion(
                        6,
                        widget.fullDraftController.text.trim(),
                        allSelectedIds.toList(growable: false),
                      )
                    : null,
                icon: const Icon(Icons.history_edu_outlined, size: 18),
                label: const Text("버전 저장"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: _versionCountForTab(6) > 0 ? () => _loadVersion(6) : null,
                icon: const Icon(Icons.restore_page_outlined, size: 18),
                label: const Text("버전 불러오기"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExperienceRefChip extends StatelessWidget {
  const _ExperienceRefChip({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final String period = experience.period.displayText;
    return Tooltip(
      message: [
        experience.title,
        if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
        if (period.isNotEmpty) period,
      ].join("\n"),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "${experience.type.label} · ${experience.title}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedExperienceSummary extends StatelessWidget {
  const _SelectedExperienceSummary({required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final String period = experience.period.displayText;
    final String detail = [
      if (period.isNotEmpty) period,
      if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
      if (experience.role.trim().isNotEmpty) experience.role.trim(),
    ].join(" · ");
    final String starHint = [
      if (experience.action.trim().isNotEmpty) experience.action.trim(),
      if (experience.result.trim().isNotEmpty) experience.result.trim(),
      if (experience.situation.trim().isNotEmpty) experience.situation.trim(),
    ].join(' / ');

    return SizedBox(
      width: 240,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: AppColors.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill(
              label: experience.type.label,
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 8),
            Text(
              experience.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
            if (starHint.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                starHint.softWrapWords(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
