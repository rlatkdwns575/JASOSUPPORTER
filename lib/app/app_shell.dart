import 'dart:collection';

import 'package:chatgptmini/app/app_main_workspace.dart';
import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/app/app_section.dart';
import 'package:chatgptmini/app/app_work_body.dart';
import 'package:chatgptmini/app/career_shell_actions.dart';
import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/core/widgets/app_chat_coach_host.dart';
import 'package:chatgptmini/core/widgets/chat_first_shell.dart';
import 'package:chatgptmini/core/widgets/navigation_sidebar.dart';
import 'package:chatgptmini/core/widgets/workspace_header.dart';
import 'package:chatgptmini/data/providers/attachment_session_provider.dart';
import 'package:chatgptmini/data/providers/career_draft_provider.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:chatgptmini/data/providers/chat_providers.dart';
import 'package:chatgptmini/data/providers/chat_session_provider.dart';
import 'package:chatgptmini/data/providers/coach_prefs_provider.dart';
import 'package:chatgptmini/data/providers/interview_questions_provider.dart';
import 'package:chatgptmini/data/providers/interview_selection_provider.dart';
import 'package:chatgptmini/data/providers/master_essay_selection_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/data/services/export_service.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/chat/chat_action_controller.dart';
import 'package:chatgptmini/features/chat/chat_flow_controller.dart';
import 'package:chatgptmini/features/chat/chat_save_executor.dart';
import 'package:chatgptmini/features/chat/chat_send_coordinator.dart';
import 'package:chatgptmini/features/chat/chat_stream_runner.dart';
import 'package:chatgptmini/features/experience/experience_card_dialogs.dart';
import 'package:chatgptmini/features/experience/experience_export_requests.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_shell_host.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:chatgptmini/features/experience/spec_item_dialogs.dart';
import 'package:chatgptmini/features/home/career_data_error_banner.dart';
import 'package:chatgptmini/features/interview/interview_shell_host.dart';
import 'package:chatgptmini/features/interview/interview_workspace_controller.dart';
import 'package:chatgptmini/features/master_resume/master_essay_prompt_planner.dart';
import 'package:chatgptmini/features/master_resume/master_resume_shell_host.dart';
import 'package:chatgptmini/features/master_resume/master_resume_workspace_controller.dart';
import 'package:chatgptmini/features/portfolio/portfolio_from_experience_dialog.dart';
import 'package:chatgptmini/features/portfolio/portfolio_outline_dialogs.dart';
import 'package:chatgptmini/features/portfolio/portfolio_shell_host.dart';
import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatGptApp extends ConsumerStatefulWidget {
  const ChatGptApp({
    super.key,
    required this.location,
    this.queryParameters = const <String, String>{},
  });

  /// 현재 활성 라우트 경로. go_router의 ShellRoute가 주입한다.
  final String location;

  /// 현재 URI 쿼리. 예: experience/form?category=campus
  final Map<String, String> queryParameters;

  @override
  ConsumerState<ChatGptApp> createState() => _ChatGptAppState();
}

class _ChatGptAppState extends ConsumerState<ChatGptApp> with TickerProviderStateMixin {
  ChatActionController get _chatActionController => ref.read(chatActionControllerProvider);
  ChatSaveExecutor get _chatSaveExecutor => ref.read(chatSaveExecutorProvider);
  ChatSendCoordinator get _chatSend => ref.read(chatSendCoordinatorProvider);
  ChatStreamRunner get _chatStream => ref.read(chatStreamRunnerProvider);
  CareerShellActions get _careerActions => ref.read(careerShellActionsProvider);
  List<PickedAttachment> get _pickedBinary => ref.watch(attachmentSessionProvider);

  late final MasterResumeWorkspaceController _masterWorkspace;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool sendButtonEnabled = false;

  InterviewWorkspaceController get _interviewWorkspace =>
      ref.read(interviewWorkspaceControllerProvider);

  List<Experience> get _savedExperiences =>
      ref.watch(experiencesProvider).value ?? const <Experience>[];

  List<SpecItem> get _savedSpecs =>
      ref.watch(specItemsProvider).value ?? const <SpecItem>[];

  List<PortfolioProject> get _portfolioProjects =>
      ref.watch(portfolioProjectsProvider).value ?? const <PortfolioProject>[];

  List<ApplicationRecord> get _applicationRecords =>
      ref.watch(applicationRecordsProvider).value ?? const <ApplicationRecord>[];

  List<InterviewAnswer> get _interviewAnswers =>
      ref.watch(interviewAnswersProvider).value ?? const <InterviewAnswer>[];

  Map<int, int> get _essayVersionCounts =>
      ref.watch(essayVersionCountsProvider).value ?? const <int, int>{};

  AssistantMode get _mode => assistantModeForLocation(widget.location);

  AppSection get _section => appSectionForLocation(widget.location);

  ExperienceCategory? get _formFocusCategory {
    if (!widget.location.startsWith(AppRoutes.experienceForm)) {
      return null;
    }
    return ExperienceCategoryCopy.fromQuery(widget.queryParameters['category']);
  }

  ExperienceSubtype? get _formFocusSubtype {
    if (!widget.location.startsWith(AppRoutes.experienceForm)) {
      return null;
    }
    final ExperienceSubtype? subtype =
        ExperienceSubtypeCopy.fromQuery(widget.queryParameters['subtype']);
    final ExperienceCategory? category = _formFocusCategory;
    if (subtype == null || category == null) {
      return null;
    }
    return subtype.category == category ? subtype : null;
  }

  ChatSessionState get _chatSession => ref.watch(chatSessionProvider);

  bool get isGenerating => _chatSession.isGenerating;

  ChatRoom get _room => _chatSession.roomFor(_mode);

  InterviewSelectionNotifier get _interviewSelection =>
      ref.read(interviewSelectionProvider.notifier);

  List<String> get _interviewSelectedExperienceIdList =>
      ref.read(interviewSelectionProvider).toList(growable: false);

  List<String> get _masterSelectedExperienceIdList {
    final int tab = _masterWorkspace.currentTabIndex;
    final MasterEssaySelectionNotifier selection =
        ref.read(masterEssaySelectionProvider.notifier);
    if (tab >= 0 && tab <= 5) {
      return selection.idsFor(tab);
    }
    // 전체 첨삭 탭: 문항별 선택 합집합
    return selection.allSelectedIds;
  }

  /// 코치 헤더에 보여줄 선택 경험 상태.
  String? get _coachSelectionStatus {
    return switch (_mode) {
      AssistantMode.masterResume => () {
          final int count = _masterSelectedExperienceIdList.length;
          final int tab = _masterWorkspace.currentTabIndex;
          if (tab >= 0 && tab <= 5) {
            return count == 0 ? '문항 경험 미선택' : '문항 경험 $count개';
          }
          return count == 0 ? '문항 경험 미선택' : '전체 선택 경험 $count개';
        }(),
      AssistantMode.interview => () {
          final int count = _interviewSelectedExperienceIdList.length;
          return count == 0 ? '경험 미선택' : '선택 경험 $count개';
        }(),
      AssistantMode.experienceSpec => null,
      AssistantMode.portfolio => () {
          final int count = _portfolioLinkedExperienceIds.length;
          return count == 0 ? '연결 경험 없음' : '연결 경험 $count개';
        }(),
    };
  }

  /// 모드별 AI 컨텍스트에 넣을 Experience id.
  List<String> get _contextSelectedExperienceIds {
    return switch (_mode) {
      AssistantMode.interview => _interviewSelectedExperienceIdList,
      AssistantMode.masterResume => _masterSelectedExperienceIdList,
      AssistantMode.experienceSpec => const <String>[],
      AssistantMode.portfolio => _portfolioLinkedExperienceIds,
    };
  }

  List<String> get _portfolioLinkedExperienceIds {
    final String location = widget.location;
    if (location.startsWith('${AppRoutes.portfolio}/preview/')) {
      final String id = location.split('/').last;
      for (final PortfolioProject project in _portfolioProjects) {
        if (project.id == id) {
          return project.linkedExperienceIds.toList(growable: false);
        }
      }
    }
    final LinkedHashSet<String> ids = LinkedHashSet<String>();
    for (final PortfolioProject project in _portfolioProjects) {
      ids.addAll(project.linkedExperienceIds);
    }
    return ids.toList(growable: false);
  }

  CareerDraftState get _careerDraft => ref.watch(careerDraftProvider);

  List<Experience> get _pendingExperiences => _careerDraft.pendingExperiences;

  List<SpecItem> get _pendingSpecs => _careerDraft.pendingSpecs;

  int get _lastSavedCount => _careerDraft.lastSavedCount;

  @override
  void initState() {
    super.initState();
    _masterWorkspace = MasterResumeWorkspaceController(vsync: this);
    _masterWorkspace.tabController.addListener(_onMasterTabChanged);
    controller.addListener(_syncSendEnabled);
    _syncSendEnabled();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rememberCurrentExperienceFormFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatGptApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location &&
        widget.location.startsWith(AppRoutes.experienceForm)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _rememberCurrentExperienceFormFocus();
        }
      });
    }
  }

  void _onMasterTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncSendEnabled() {
    final CoachQuestionKind kind =
        ref.read(coachQuestionKindSelectionProvider.notifier).kindFor(_mode);
    final bool canSend = controller.text.trim().isNotEmpty ||
        ref.read(attachmentSessionProvider).isNotEmpty ||
        !kind.isFreeform;
    if (sendButtonEnabled == canSend) {
      return;
    }
    setState(() => sendButtonEnabled = canSend);
  }

  @override
  void dispose() {
    _masterWorkspace.tabController.removeListener(_onMasterTabChanged);
    _masterWorkspace.dispose();
    controller.removeListener(_syncSendEnabled);
    _scrollController.dispose();
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _applyResult(ShellActionResult result) async {
    if (result.cancelled || !mounted) {
      return;
    }
    final String? navigateTo = result.navigateTo;
    if (navigateTo != null) {
      context.go(navigateTo);
    }
    if (result.hasSnack) {
      _snack(result.snack!);
    }
    final PortfolioProject? edit = result.editPortfolio;
    if (edit != null && mounted) {
      await PortfolioOutlineDialogs.showEdit(
        context: context,
        project: edit,
        availableExperiences: _savedExperiences,
        onSave: (PortfolioProject next) async {
          await ref.read(portfolioProjectsProvider.notifier).save(next);
        },
      );
    }
  }

  void _snack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBinaryFiles() async {
    try {
      final AttachmentPickResult result = await _chatSend.pickBinaryFiles();
      for (final String message in result.messages) {
        _snack(message);
      }
      if (result.attachments.isNotEmpty) {
        _chatSend.addAttachments(result.attachments);
        _syncSendEnabled();
      }
    } catch (e) {
      _snack(actionErrorMessage('파일 선택 중 오류', e));
    }
  }

  void _removePickedBinary(int index) {
    _chatSend.removeAttachmentAt(index);
    _syncSendEnabled();
  }

  void _clearAllPickedBinary() {
    if (!_chatSend.clearAttachments()) {
      return;
    }
    _syncSendEnabled();
  }

  void _sendProgrammatic(
    String chatBubbleText, {
    List<String> selectedExperienceIds = const [],
  }) {
    final ChatTurn? turn = _chatSend.beginProgrammaticSend(
      mode: _mode,
      chatBubbleText: chatBubbleText,
      attachmentText: '',
      targetJob: _masterWorkspace.targetJob.text,
      selectedExperienceIds: selectedExperienceIds.isEmpty
          ? _contextSelectedExperienceIds
          : selectedExperienceIds,
    );
    if (turn == null) {
      return;
    }
    _scrollChatToBottom();
    _startAssistantStream(turn);
  }

  /// 코칭 칩: 경험 매칭은 저장 경험 목록을 포함한 프롬프트로 보낸다.
  void _onCoachChipPrompt(String prompt) {
    if (_mode == AssistantMode.masterResume &&
        prompt.contains('id·title·reason')) {
      _sendMasterExperienceMatch();
      return;
    }
    _sendProgrammatic(prompt);
  }

  void _sendMasterExperienceMatch({String extraUserRequest = ''}) {
    final int tab = _masterWorkspace.currentTabIndex;
    final int questionIndex = tab < 6 ? tab : 0;
    final MasterEssayPromptPlanner planner =
        ref.read(masterEssayPromptPlannerProvider);
    final MasterEssayPromptPlan plan = planner.experienceMatch(
      index0Based: questionIndex,
      targetJob: _masterWorkspace.targetJobText,
      experiences: [
        for (final Experience e in _savedExperiences)
          ExperienceSummaryLine(
            id: e.id,
            title: e.title,
            organization: e.organization,
            role: e.role,
          ),
      ],
    );
    if (!plan.canSend) {
      _snack(plan.errorMessage ?? '경험 매칭 요청을 만들 수 없습니다.');
      return;
    }
    final String extra = extraUserRequest.trim();
    final String prompt = extra.isEmpty
        ? plan.prompt!
        : '${plan.prompt!}\n\n[추가 요청]\n$extra';
    _sendProgrammatic(
      prompt,
      selectedExperienceIds: [
        for (final Experience e in _savedExperiences) e.id,
      ],
    );
  }

  Future<void> _exportSavedExperiences() async {
    final ExperienceExportOutcome outcome = ExperienceExportRequests.saved(
      experiences: _savedExperiences,
      specs: _savedSpecs,
    );
    if (!outcome.isOk) {
      _applyResult(outcome.error!);
      return;
    }
    if (!mounted) {
      return;
    }
    await ExportService.pickFormatAndSaveRequest(context, request: outcome.request!);
  }

  Future<void> _confirmPendingCareerData() async {
    _applyResult(await _careerActions.confirmPendingDraft());
  }

  Future<void> _saveExperienceCard(Experience experience) async {
    _applyResult(await _careerActions.saveExperienceCard(experience));
  }

  Future<void> _editExperienceCard(Experience experience) async {
    await ExperienceCardDialogs.showEdit(
      context: context,
      experience: experience,
      onSave: _saveExperienceCard,
    );
  }

  Future<void> _editPendingExperienceCard(Experience experience) async {
    await ExperienceCardDialogs.showEdit(
      context: context,
      experience: experience,
      onSave: (Experience next) async {
        ref.read(careerDraftProvider.notifier).updatePendingExperience(next);
        _snack('확인 대기 중인 경험 카드를 수정했습니다.');
      },
    );
  }

  Future<void> _editPendingSpecItem(SpecItem item) async {
    await SpecItemDialogs.showEdit(
      context: context,
      item: item,
      onSave: (SpecItem next) async {
        ref.read(careerDraftProvider.notifier).updatePendingSpec(next);
        _snack('확인 대기 중인 스펙을 수정했습니다.');
      },
    );
  }

  void _useExperienceForEssay(Experience experience) {
    ref.read(masterEssayPendingSelectionProvider.notifier).queue(experience.id);
    context.go(AppRoutes.masterResume);
    _snack("'${experience.title}'을(를) Q1 경험 선택에 넣었습니다.");
  }

  void _applyLastSavedToEssay() {
    final List<String> ids = _careerDraft.lastSavedExperienceIds;
    if (ids.isNotEmpty) {
      ref.read(masterEssayPendingSelectionProvider.notifier).queueAll(ids);
    }
    context.go(AppRoutes.masterResume);
    if (ids.isNotEmpty) {
      _snack('방금 저장한 경험을 자소서 문항에 넣었습니다.');
    }
  }

  void _applyLastSavedToInterview() {
    final List<String> ids = _careerDraft.lastSavedExperienceIds;
    if (ids.isNotEmpty) {
      _interviewSelection.replaceWith(ids);
    }
    context.go(AppRoutes.interview);
    if (ids.isNotEmpty) {
      _snack('방금 저장한 경험을 면접 대비에 선택했습니다.');
    }
  }

  Future<void> _createPortfolioProjectFromExperience(Experience experience) async {
    final bool confirmed = await PortfolioFromExperienceDialog.confirm(
      context: context,
      experience: experience,
    );
    if (!confirmed || !mounted) {
      return;
    }
    _applyResult(await _careerActions.createPortfolioFromExperience(experience));
  }

  Future<void> _startAssistantStream(ChatTurn turn) {
    return _chatStream.run(
      mode: _mode,
      turn: turn,
      isMounted: () => mounted,
      onProgress: _scrollChatToBottom,
    );
  }

  void sendMessage() {
    if (_mode == AssistantMode.masterResume) {
      final CoachQuestionKind kind =
          ref.read(coachQuestionKindSelectionProvider.notifier).kindFor(_mode);
      if (kind.id == 'match') {
        final String extra = controller.text.trim();
        controller.clear();
        _syncSendEnabled();
        _sendMasterExperienceMatch(extraUserRequest: extra);
        return;
      }
    }
    final ChatTurn? turn = _chatSend.beginUserSend(
      mode: _mode,
      mainText: controller.text,
      attachmentText: '',
      targetJob: _masterWorkspace.targetJob.text,
      selectedExperienceIds: _contextSelectedExperienceIds,
    );
    if (turn == null) {
      return;
    }
    controller.clear();
    _syncSendEnabled();
    _scrollChatToBottom();
    _startAssistantStream(turn);
  }

  String _experienceFormReturnPath() => _careerDraft.formReturnPath;

  void _rememberCurrentExperienceFormFocus() {
    final ExperienceCategory? category = _formFocusCategory;
    if (category == null) {
      return;
    }
    ref.read(careerDraftProvider.notifier).rememberFormFocus(
          category: category.queryValue,
          subtype: _formFocusSubtype?.queryValue,
        );
  }

  @override
  Widget build(BuildContext context) {
    // 선택 상태가 바뀌면 코치 헤더·전송 컨텍스트가 갱신되도록 watch
    ref.watch(masterEssaySelectionProvider);
    ref.watch(interviewSelectionProvider);
    ref.watch(selectedGeminiModelProvider);
    ref.watch(coachQuestionKindSelectionProvider);
    ref.listen<Map<AssistantMode, String>>(
      coachQuestionKindSelectionProvider,
      (Map<AssistantMode, String>? previous, Map<AssistantMode, String> next) {
        _syncSendEnabled();
      },
    );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            final bool compactRail = cons.maxWidth < 860;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NavigationSidebar(
                  location: widget.location,
                  compact: compactRail,
                  onSelect: (String path) => context.go(path),
                ),
                Expanded(child: _buildSectionContent(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context) {
    final bool settingsMuted = _section == AppSection.settings;
    return ChatFirstShell(
      workBody: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CareerDataErrorBanner(),
          Expanded(child: _buildWorkBody(context)),
        ],
      ),
      coachPanel: AppChatCoachHost(
        mode: _mode,
        muted: settingsMuted,
        messages: _room.chats,
        scrollController: _scrollController,
        inputController: controller,
        inputFocusNode: focusNode,
        attachments: _pickedBinary,
        isGenerating: isGenerating,
        canSend: sendButtonEnabled,
        selectionStatusLabel: _coachSelectionStatus,
        onChipPrompt: _onCoachChipPrompt,
        onPickFiles: _pickBinaryFiles,
        onClearAttachments: _clearAllPickedBinary,
        onRemoveAttachment: _removePickedBinary,
        onSend: sendMessage,
        onApplyAssistantText: _applyAssistantText,
        onCopyAssistantText: _copyAssistantTextToClipboard,
        onSaveAssistantText: _saveAssistantTextAsVersion,
      ),
    );
  }

  Widget _buildWorkBody(BuildContext context) {
    return AppWorkBody(
      section: _section,
      location: widget.location,
      header: _buildWorkspaceHeader(context),
      mainWorkspace: _buildMainWorkspace(context),
      experiences: _savedExperiences,
      specCount: _savedSpecs.length,
      portfolioProjects: _portfolioProjects,
      applicationRecords: _applicationRecords,
      savedEssayVersionCount:
          _essayVersionCounts.values.fold<int>(0, (int sum, int c) => sum + c),
      interviewAnswerCount: _interviewAnswers.length,
      pendingExperiences: _pendingExperiences,
      pendingSpecs: _pendingSpecs,
      lastSavedCount: _lastSavedCount,
      enabled: !isGenerating,
      onNavigate: (String path) => context.go(path),
      onAddExperience: () => context.go(AppRoutes.experience),
      onExportExperiences: _exportSavedExperiences,
      onOpenCategory: (ExperienceCategory category) {
        context.go(AppRoutes.experienceFormCategory(category.queryValue));
        _snack('${category.title} 유형을 고르세요.');
      },
      onOpenExperience: (Experience experience) =>
          context.go(AppRoutes.experienceDetail(experience.id)),
      onConfirmSave: _confirmPendingCareerData,
      onGoExperienceList: () => context.go(AppRoutes.experience),
      onApplyEssay: _applyLastSavedToEssay,
      onInterview: _applyLastSavedToInterview,
      onAddAnother: () => context.go(_experienceFormReturnPath()),
      onEditExperience: _editExperienceCard,
      onUseForEssay: _useExperienceForEssay,
      onInterviewFromExperience: (Experience experience) {
        _interviewSelection.replaceWith([experience.id]);
        context.go(AppRoutes.interview);
      },
      onPortfolioOutline: _createPortfolioProjectFromExperience,
      onBackFromDetail: () => context.go(AppRoutes.experience),
      onBackFromConfirm: () => context.go(_experienceFormReturnPath()),
      onEditPendingExperience: _editPendingExperienceCard,
      onEditPendingSpec: _editPendingSpecItem,
    );
  }

  Widget _buildWorkspaceHeader(BuildContext context) {
    final ({String title, String subtitle}) copy = workspaceHeaderCopy(
      section: _section,
      location: widget.location,
    );
    return WorkspaceHeader(
      title: copy.title,
      subtitle: copy.subtitle,
      savedExperienceCount: _savedExperiences.length,
      isGenerating: isGenerating,
    );
  }

  Widget _buildMainWorkspace(BuildContext context) {
    return AppMainWorkspace(
      mode: _mode,
      experience: ExperienceShellHost(
        enabled: !isGenerating,
        focusCategory: _formFocusCategory,
        focusSubtype: _formFocusSubtype,
        onApplyResult: _applyResult,
        onSnack: _snack,
        onInterviewFromExperience: (Experience experience) {
          _interviewSelection.replaceWith([experience.id]);
          context.go(AppRoutes.interview);
        },
        onPortfolioOutline: _createPortfolioProjectFromExperience,
      ),
      masterResume: MasterResumeShellHost(
        workspace: _masterWorkspace,
        enabled: !isGenerating,
        onSendPrompt: _sendProgrammatic,
        onApplyResult: _applyResult,
        onSnack: _snack,
      ),
      interview: InterviewShellHost(
        location: widget.location,
        enabled: !isGenerating,
        onSendPrompt: _sendProgrammatic,
        onApplyResult: _applyResult,
        onSnack: _snack,
      ),
      portfolio: PortfolioShellHost(
        location: widget.location,
        section: _section,
        enabled: !isGenerating,
        onSendPrompt: _sendProgrammatic,
        onApplyResult: _applyResult,
        onSnack: _snack,
      ),
    );
  }

  Future<void> _applyAssistantText(String text) async {
    final ChatApplyPlan plan = _chatActionController.planApply(
      mode: _mode,
      text: text,
      currentLocation: widget.location,
      masterTabIndex: _masterWorkspace.currentTabIndex,
      portfolioLinkedExperienceIds: _portfolioLinkedExperienceIds,
      availableExperiences: _savedExperiences,
    );
    if (plan.isEmpty) {
      return;
    }
    switch (plan.target) {
      case ChatApplyTarget.interviewAnswer:
        setState(() {
          _interviewWorkspace.applyAnswer(plan.text);
        });
      case ChatApplyTarget.interviewQuestions:
        ref
            .read(interviewQuestionsProvider.notifier)
            .replaceWith(plan.interviewQuestions);
      case ChatApplyTarget.masterDraft:
        setState(() {
          _masterWorkspace.applyDraft(
            tabIndex: plan.masterTabIndex,
            text: plan.text,
          );
        });
      case ChatApplyTarget.masterExperienceMatch:
        if (plan.experienceIds.isNotEmpty) {
          final int tab = plan.masterTabIndex < 6 ? plan.masterTabIndex : 0;
          ref
              .read(masterEssaySelectionProvider.notifier)
              .addAll(tab, plan.experienceIds);
        }
      case ChatApplyTarget.experienceDraft:
        if (plan.experienceDraft != null) {
          ref.read(careerDraftProvider.notifier).setExperienceDraft(
                plan.experienceDraft!,
              );
        }
      case ChatApplyTarget.portfolioOutline:
        if (plan.portfolioProject != null) {
          final PortfolioProject project = plan.portfolioProject!;
          await ref.read(portfolioProjectsProvider.notifier).save(project);
          if (!mounted) {
            return;
          }
          await PortfolioOutlineDialogs.showEdit(
            context: context,
            project: project,
            availableExperiences: _savedExperiences,
            onSave: (PortfolioProject next) async {
              await ref.read(portfolioProjectsProvider.notifier).save(next);
            },
          );
        }
      case ChatApplyTarget.chatInput:
        setState(() {
          controller.text = plan.text;
          controller.selection = TextSelection.collapsed(
            offset: controller.text.length,
          );
        });
        _syncSendEnabled();
      case ChatApplyTarget.clipboard:
        if (plan.text.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: plan.text));
        }
    }
    _applyResult(
      ShellActionResult(
        snack: plan.message.isEmpty ? null : plan.message,
        navigateTo: plan.navigateTo,
      ),
    );
  }

  Future<void> _copyAssistantTextToClipboard(String text) async {
    final ChatApplyPlan plan = _chatActionController.planCopyToClipboard(text);
    if (plan.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: plan.text));
    _applyResult(
      ShellActionResult(snack: plan.message.isEmpty ? null : plan.message),
    );
  }

  Future<void> _saveAssistantTextAsVersion(String text) async {
    final ChatSavePlan plan = _chatActionController.planSave(
      mode: _mode,
      text: text,
      interviewSourceExperienceIds: _interviewSelectedExperienceIdList,
      masterTabIndex: _masterWorkspace.currentTabIndex,
      portfolioLinkedExperienceIds: _portfolioLinkedExperienceIds,
    );
    _applyResult(
      await _chatSaveExecutor.execute(
        plan,
        saveMasterEssayVersion: (int tabIndex, String body) {
          return _careerActions.saveMasterEssayVersion(
            tabIndex: tabIndex,
            body: body,
            selectedExperienceIds: tabIndex >= 0 && tabIndex <= 5
                ? ref.read(masterEssaySelectionProvider.notifier).idsFor(tabIndex)
                : const <String>[],
            targetJob: _masterWorkspace.targetJobText,
          );
        },
      ),
    );
  }
}
