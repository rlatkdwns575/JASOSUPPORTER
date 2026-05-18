import 'dart:math' as math;

import 'package:chatgptmini/app_brand_mark.dart';
import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/assistant_prompts.dart';
import 'package:chatgptmini/core/theme/app_theme.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/core/widgets/chat_widgets.dart';
import 'package:chatgptmini/core/widgets/composer_widgets.dart';
import 'package:chatgptmini/data/local/json_career_repository.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/data/services/gemini_service.dart';
import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/experience_spec_form.dart';
import 'package:chatgptmini/export_service.dart';
import 'package:chatgptmini/features/chat/chat_flow_controller.dart';
import 'package:chatgptmini/features/experience/experience_card_editor.dart';
import 'package:chatgptmini/features/experience/experience_library_panel.dart';
import 'package:chatgptmini/features/portfolio/career_artifact_panel.dart';
import 'package:chatgptmini/jaso_constants.dart';
import 'package:chatgptmini/master_resume_workspace.dart';
import 'package:chatgptmini/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? apiKey;
  try {
    await dotenv.load(fileName: "assets/.env");
    apiKey = dotenv.env["GOOGLE_API_KEY"]?.trim();
  } catch (_) {
    apiKey = null;
  }
  if (apiKey == null || apiKey.isEmpty) {
    runApp(const MissingApiKeyApp());
    return;
  }
  GeminiService.initialize(apiKey);
  runApp(const ChatGptApp());
}

class MissingApiKeyApp extends StatelessWidget {
  const MissingApiKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "JasoSupporter",
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "assets/.env에 GOOGLE_API_KEY가 없습니다.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatGptApp extends StatefulWidget {
  const ChatGptApp({super.key});

  @override
  State<ChatGptApp> createState() => _ChatGptAppState();
}

class _ChatGptAppState extends State<ChatGptApp> with TickerProviderStateMixin {
  AssistantMode _mode = AssistantMode.experienceSpec;
  final PromptBuilder _promptBuilder = const PromptBuilder();
  final AiService _aiService = const GeminiService();
  late final ChatFlowController _chatFlowController;
  final AttachmentService _attachmentService = const AttachmentService();
  final JsonCareerRepository _careerRepository = const JsonCareerRepository();

  final Map<AssistantMode, ChatRoom> _rooms = {
    AssistantMode.experienceSpec: ChatRoom(chats: [], createdAt: DateTime.now()),
    AssistantMode.masterResume: ChatRoom(chats: [], createdAt: DateTime.now()),
    AssistantMode.portfolio: ChatRoom(chats: [], createdAt: DateTime.now()),
  };

  final GlobalKey<ExperienceSpecFormState> _experienceFormKey = GlobalKey<ExperienceSpecFormState>();

  late final TabController _masterTabController;
  late final List<TextEditingController> _masterQControllers;
  final TextEditingController _masterFullDraftController = TextEditingController();
  final TextEditingController _masterTargetJobController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController controller = TextEditingController();
  final TextEditingController attachmentController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final List<PickedAttachment> _pickedBinary = [];
  List<Experience> _savedExperiences = [];
  List<PortfolioProject> _portfolioProjects = [];
  List<ApplicationRecord> _applicationRecords = [];
  Map<int, int> _essayVersionCounts = {};

  bool sendButtonEnabled = false;
  bool isGenerating = false;

  static const int _maxBinaryCount = 6;

  /// 경험·스펙 좌측(입력 폼) 너비(px). null이면 가로의 50%로 시작.
  double? _experienceLeftWidthPx;

  /// 마스터 자소서 좌측(문항 작업) 너비(px). null이면 가로의 약 52%로 시작.
  double? _masterLeftWidthPx;

  /// 자료·복붙 패널: false면 한 줄 입력 위주로 최소 높이.
  bool _attachmentPanelExpanded = false;

  ChatRoom get _room => _rooms[_mode]!;

  @override
  void initState() {
    super.initState();

    _masterTabController = TabController(length: 7, vsync: this);
    _masterQControllers = List.generate(6, (_) => TextEditingController());
    _chatFlowController = ChatFlowController(
      promptBuilder: _promptBuilder,
      aiService: _aiService,
    );

    controller.addListener(_syncSendEnabled);
    attachmentController.addListener(_syncSendEnabled);
    _syncSendEnabled();
    _loadSavedCareerData();
    _loadEssayVersionCounts();
  }

  String _masterEssayIdForTab(int tabIndex) {
    final String questionId = tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : "FULL";
    return "master_essay_$questionId";
  }

  Future<void> _loadEssayVersionCounts() async {
    try {
      final Map<int, int> counts = {};
      for (int i = 0; i < 7; i++) {
        final List<EssayVersion> versions = await _careerRepository.listEssayVersions(_masterEssayIdForTab(i));
        counts[i] = versions.length;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _essayVersionCounts = counts;
      });
    } catch (e) {
      _snack("저장된 자소서 버전 정보를 불러오지 못했습니다: $e");
    }
  }

  Future<void> _loadSavedCareerData() async {
    try {
      final List<Experience> experiences = await _careerRepository.listExperiences();
      final List<PortfolioProject> projects = await _careerRepository.listPortfolioProjects();
      final List<ApplicationRecord> records = await _careerRepository.listApplicationRecords();
      if (!mounted) {
        return;
      }
      setState(() {
        _savedExperiences = experiences;
        _portfolioProjects = projects;
        _applicationRecords = records;
      });
    } catch (e) {
      _snack("저장된 경험을 불러오지 못했습니다: $e");
    }
  }

  void _syncSendEnabled() {
    final bool canSend =
        controller.text.trim().isNotEmpty || attachmentController.text.trim().isNotEmpty || _pickedBinary.isNotEmpty;
    if (sendButtonEnabled == canSend) {
      return;
    }
    setState(() {
      sendButtonEnabled = canSend;
    });
  }

  @override
  void dispose() {
    _masterTabController.dispose();
    for (final c in _masterQControllers) {
      c.dispose();
    }
    _masterFullDraftController.dispose();
    _masterTargetJobController.dispose();
    controller.removeListener(_syncSendEnabled);
    attachmentController.removeListener(_syncSendEnabled);
    _scrollController.dispose();
    controller.dispose();
    attachmentController.dispose();
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

  void _snack(String message) {
    if (!mounted) {
      return;
    }
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickBinaryFiles() async {
    try {
      final AttachmentPickResult result = await _attachmentService.pickBinaryFiles(
        existingCount: _pickedBinary.length,
      );

      for (final String message in result.messages) {
        _snack(message);
      }

      if (result.attachments.isNotEmpty) {
        setState(() {
          _pickedBinary.addAll(result.attachments);
        });
        _syncSendEnabled();
      }
    } catch (e) {
      _snack("파일 선택 중 오류: $e");
    }
  }

  void _removePickedBinary(int index) {
    setState(() {
      if (index >= 0 && index < _pickedBinary.length) {
        _pickedBinary.removeAt(index);
      }
    });
    _syncSendEnabled();
  }

  void _clearAllPickedBinary() {
    if (_pickedBinary.isEmpty) {
      return;
    }
    setState(_pickedBinary.clear);
    _syncSendEnabled();
  }

  double _bubbleMaxForParentWidth(double parentWidth) {
    return math.min(640, math.max(168, parentWidth - 24));
  }

  String _experienceContextBlock() {
    final List<ChatMessage> chats = _rooms[AssistantMode.experienceSpec]!.chats;
    if (chats.isEmpty && _savedExperiences.isEmpty) {
      return "";
    }

    final StringBuffer buffer = StringBuffer();
    if (_savedExperiences.isNotEmpty) {
      buffer.writeln(_experiencePromptBlock(_savedExperiences, "저장된 Experience 카드 — 다른 모드에서도 사실만 인용할 것"));
      buffer.writeln();
    }

    if (chats.isNotEmpty) {
      buffer.writeln("[경험·스펙에서 정리된 참고 데이터 — 다른 모드에서도 사실만 인용할 것]");
    }
    for (final chat in chats) {
      final String role = chat.isMe ? "사용자" : "AI";
      final String text = chat.text.trim();
      if (text.isEmpty) {
        continue;
      }
      buffer.writeln("$role: $text");
    }

    String result = buffer.toString().trim();
    const int maxLen = 12000;
    if (result.length > maxLen) {
      result = result.substring(result.length - maxLen);
    }
    return result;
  }

  void _sendProgrammatic(String chatBubbleText) {
    if (isGenerating) {
      return;
    }
    final ChatTurn turn = _chatFlowController.createProgrammaticTurn(
      mode: _mode,
      currentChats: _room.chats,
      chatBubbleText: chatBubbleText,
      attachmentText: attachmentController.text,
      attachments: _pickedBinary,
      targetJob: _masterTargetJobController.text,
      experienceContext: _experienceContextBlock(),
    );
    setState(() {
      _room.chats.add(turn.userMessage);
      isGenerating = true;
    });
    _scrollChatToBottom();
    _startAssistantStream(turn);
  }

  String _experiencePromptBlock(Iterable<Experience> experiences, String heading) {
    final List<Experience> items = experiences.toList(growable: false);
    if (items.isEmpty) {
      return "";
    }
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("[$heading]");
    for (final Experience experience in items) {
      buffer.writeln("- id: ${experience.id}");
      buffer.writeln("  제목: ${experience.title}");
      buffer.writeln("  유형: ${experience.type.label}");
      if (experience.period.displayText.isNotEmpty) {
        buffer.writeln("  기간: ${experience.period.displayText}");
      }
      if (experience.organization.trim().isNotEmpty) {
        buffer.writeln("  기관/소속: ${experience.organization.trim()}");
      }
      if (experience.role.trim().isNotEmpty) {
        buffer.writeln("  역할/결과: ${experience.role.trim()}");
      }
      if (experience.action.trim().isNotEmpty) {
        buffer.writeln("  내용: ${experience.action.trim()}");
      }
    }
    return buffer.toString().trim();
  }

  String _selectedExperienceContextBlock(List<String> ids) {
    final Set<String> selected = ids.toSet();
    return _experiencePromptBlock(
      _savedExperiences.where((Experience experience) => selected.contains(experience.id)),
      "이 문항에 선택한 Experience 카드",
    );
  }

  void _requestMasterQuestionDraft(int index0Based, List<String> selectedExperienceIds) {
    final MasterQuestionCopy q = MasterQuestionCopy.all[index0Based];
    final String draft = _masterQControllers[index0Based].text.trim();
    final String job = _masterTargetJobController.text.trim();
    _sendProgrammatic(
      _promptBuilder.masterQuestionDraftRequest(
        question: q,
        index0Based: index0Based,
        userDraft: draft,
        targetJob: job,
        selectedExperienceIds: selectedExperienceIds,
        selectedExperienceContext: _selectedExperienceContextBlock(selectedExperienceIds),
      ),
    );
  }

  void _requestMasterFullReview() {
    final String t = _masterFullDraftController.text.trim();
    if (t.isEmpty) {
      _snack("전체 초고를 입력 칸에 붙여 넣어 주세요.");
      return;
    }
    final String job = _masterTargetJobController.text.trim();
    _sendProgrammatic(
      _promptBuilder.masterFullReviewRequest(
        fullDraft: t,
        targetJob: job,
      ),
    );
  }

  Future<void> _exportExperienceFormMerged() async {
    final String? s = _experienceFormKey.currentState?.compilePayload();
    if (s == null || s.trim().isEmpty) {
      _snack("입력 폼이 비어 있습니다.");
      return;
    }
    if (!mounted) {
      return;
    }
    await ExportService.pickFormatAndSaveRequest(
      context,
      request: ExportRequest(
        defaultBaseName: "experience_spec",
        content: s,
        artifactType: ExportArtifactType.experienceSummary,
        title: "경험·스펙 합본",
      ),
    );
  }

  Future<void> _saveStructuredCareerData(
    List<Experience> experiences,
    List<SpecItem> specItems,
  ) async {
    if (experiences.isEmpty && specItems.isEmpty) {
      _snack("저장할 경험·스펙이 없습니다.");
      return;
    }

    try {
      for (final Experience experience in experiences) {
        await _careerRepository.saveExperience(experience);
      }
      for (final SpecItem item in specItems) {
        await _careerRepository.saveSpecItem(item);
      }
      final List<Experience> saved = await _careerRepository.listExperiences();
      if (mounted) {
        setState(() {
          _savedExperiences = saved;
        });
      }
      _snack("경험 ${experiences.length}개, 스펙 ${specItems.length}개를 저장했습니다.");
    } catch (e) {
      _snack("경험 카드 저장 실패: $e");
    }
  }

  Future<void> _saveExperienceCard(Experience experience) async {
    try {
      await _careerRepository.saveExperience(experience);
      await _loadSavedCareerData();
      _snack("경험 카드를 저장했습니다.");
    } catch (e) {
      _snack("경험 카드 저장 실패: $e");
    }
  }

  Future<void> _editExperienceCard(Experience experience) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return ExperienceCardEditor(
          initial: experience,
          onSave: _saveExperienceCard,
        );
      },
    );
  }

  Future<void> _deleteExperienceCard(Experience experience) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text("경험 카드 삭제"),
          content: Text(
            "'${experience.title}' 카드를 삭제합니다.\n이미 저장된 자소서 버전의 sourceExperienceIds에는 id만 남을 수 있습니다.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("취소"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("삭제"),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    try {
      await _careerRepository.deleteExperience(experience.id);
      await _loadSavedCareerData();
      _snack("경험 카드를 삭제했습니다.");
    } catch (e) {
      _snack("경험 카드 삭제 실패: $e");
    }
  }

  Future<void> _duplicateExperienceCard(Experience experience) async {
    final DateTime now = DateTime.now();
    final Experience copy = experience.copyWith(
      id: "${experience.id}_copy_${now.microsecondsSinceEpoch}",
      title: "${experience.title} 복사본",
      createdAt: now,
      updatedAt: now,
    );
    await _saveExperienceCard(copy);
  }

  void _useExperienceForEssay(Experience experience) {
    setState(() {
      _mode = AssistantMode.masterResume;
    });
    _snack("'${experience.title}' 카드를 마스터 자소서 화면에서 선택해 사용할 수 있습니다.");
  }

  Future<void> _createPortfolioProjectFromExperience(Experience experience) async {
    final DateTime now = DateTime.now();
    final PortfolioProject project = PortfolioProject(
      id: "portfolio_${experience.id}_${now.microsecondsSinceEpoch}",
      title: experience.title,
      linkedExperienceIds: [experience.id],
      role: experience.role,
      problem: experience.situation,
      solution: experience.action,
      techStacks: experience.techStacks,
      result: experience.result,
      evidenceLinks: experience.evidenceLinks,
      portfolioCopy: [
        if (experience.organization.trim().isNotEmpty) "소속/기관: ${experience.organization.trim()}",
        if (experience.role.trim().isNotEmpty) "역할: ${experience.role.trim()}",
        if (experience.action.trim().isNotEmpty) "핵심 수행: ${experience.action.trim()}",
        if (experience.result.trim().isNotEmpty) "성과: ${experience.result.trim()}",
      ].join("\n"),
      createdAt: now,
      updatedAt: now,
    );
    await _careerRepository.savePortfolioProject(project);
    await _loadSavedCareerData();
    _snack("포트폴리오 프로젝트 초안을 저장했습니다.");
  }

  Future<void> _deletePortfolioProject(PortfolioProject project) async {
    await _careerRepository.deletePortfolioProject(project.id);
    await _loadSavedCareerData();
    _snack("포트폴리오 프로젝트를 삭제했습니다.");
  }

  Future<void> _createApplicationRecord() async {
    final TextEditingController company = TextEditingController();
    final TextEditingController position = TextEditingController();
    final TextEditingController link = TextEditingController();
    final TextEditingController notes = TextEditingController();
    final ApplicationRecord? record = await showDialog<ApplicationRecord>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text("지원 기록 추가"),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: company,
                  decoration: const InputDecoration(labelText: "회사명"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: position,
                  decoration: const InputDecoration(labelText: "직무"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: link,
                  decoration: const InputDecoration(labelText: "공고 링크/상태"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notes,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: "메모"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("취소")),
            FilledButton(
              onPressed: () {
                final DateTime now = DateTime.now();
                Navigator.of(ctx).pop(
                  ApplicationRecord(
                    id: "application_${now.microsecondsSinceEpoch}",
                    companyName: company.text.trim(),
                    position: position.text.trim(),
                    status: link.text.trim().isEmpty ? "준비 중" : link.text.trim(),
                    deadline: null,
                    linkedExperienceIds: _savedExperiences.map((Experience e) => e.id).take(3).toList(),
                    submittedEssayVersionIds: const [],
                    notes: notes.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
    company.dispose();
    position.dispose();
    link.dispose();
    notes.dispose();
    if (record == null || record.companyName.isEmpty || record.position.isEmpty) {
      return;
    }
    await _careerRepository.saveApplicationRecord(record);
    await _loadSavedCareerData();
    _snack("지원 기록을 저장했습니다.");
  }

  Future<void> _deleteApplicationRecord(ApplicationRecord record) async {
    await _careerRepository.deleteApplicationRecord(record.id);
    await _loadSavedCareerData();
    _snack("지원 기록을 삭제했습니다.");
  }

  Future<void> _saveMasterEssayVersion(
    int tabIndex,
    String body,
    List<String> selectedExperienceIds,
  ) async {
    if (body.trim().isEmpty) {
      _snack("저장할 자소서 내용이 없습니다.");
      return;
    }

    final DateTime now = DateTime.now();
    final String questionId = tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].id : "FULL";
    final String questionText = tabIndex < 6 ? MasterQuestionCopy.all[tabIndex].body : "전체 초고";
    final String essayId = _masterEssayIdForTab(tabIndex);
    final String versionId = "${essayId}_${now.microsecondsSinceEpoch}";

    try {
      final MasterEssay? existing = await _careerRepository.getMasterEssay(essayId);
      final MasterEssay essay = MasterEssay(
        id: essayId,
        questionId: questionId,
        questionText: questionText,
        targetJob: _masterTargetJobController.text.trim(),
        linkedExperienceIds: selectedExperienceIds,
        currentVersionId: versionId,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      final EssayVersion version = EssayVersion(
        id: versionId,
        masterEssayId: essayId,
        body: body.trim(),
        createdAt: now,
        sourceExperienceIds: selectedExperienceIds,
      );

      await _careerRepository.saveMasterEssay(essay);
      await _careerRepository.saveEssayVersion(version);
      await _loadEssayVersionCounts();
      _snack("$questionId 자소서 버전을 저장했습니다.");
    } catch (e) {
      _snack("자소서 버전 저장 실패: $e");
    }
  }

  Future<List<String>?> _loadMasterEssayVersionIntoEditor(int tabIndex) async {
    final String essayId = _masterEssayIdForTab(tabIndex);
    try {
      final List<EssayVersion> versions = await _careerRepository.listEssayVersions(essayId);
      if (!mounted) {
        return null;
      }
      if (versions.isEmpty) {
        _snack("불러올 저장 버전이 없습니다.");
        return null;
      }

      final List<EssayVersion> sorted = [...versions]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final EssayVersion? selected = await showDialog<EssayVersion>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            surfaceTintColor: Colors.transparent,
            title: const Text("저장된 버전 불러오기"),
            content: SizedBox(
              width: 520,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext itemCtx, int index) {
                  final EssayVersion version = sorted[index];
                  final String preview = version.body.length > 80
                      ? "${version.body.substring(0, 80)}..."
                      : version.body;
                  return ListTile(
                    title: Text(
                      _formatDateTime(version.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [
                        if (version.sourceExperienceIds.isNotEmpty) "연결 경험: ${version.sourceExperienceIds.join(", ")}",
                        preview,
                      ].join("\n"),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(ctx).pop(version),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("취소"),
              ),
            ],
          );
        },
      );

      if (selected == null || !mounted) {
        return null;
      }
      setState(() {
        if (tabIndex < 6) {
          _masterQControllers[tabIndex].text = selected.body;
        } else {
          _masterFullDraftController.text = selected.body;
        }
      });
      _snack("저장된 버전을 불러왔습니다.");
      return selected.sourceExperienceIds;
    } catch (e) {
      _snack("자소서 버전 불러오기 실패: $e");
      return null;
    }
  }

  String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${value.year}.${two(value.month)}.${two(value.day)} ${two(value.hour)}:${two(value.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "JasoSupporter",
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: AppTheme.light(),
      home: Scaffold(
        appBar: buildAppBar(),
        backgroundColor: AppColors.scaffold,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildModeBar(context),
              Expanded(child: _buildMainWorkspace(context)),
              buildAttachmentPanel(context),
              buildTextField(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _splitPanelHeader(BuildContext context, String title, IconData icon) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: SectionHeader(
            title: title,
            icon: icon,
            trailing: StatusPill(
              label: isGenerating ? "AI 작성 중" : "작업 가능",
              icon: isGenerating ? Icons.auto_awesome : Icons.check_circle_outline,
              color: isGenerating ? AppColors.aiAccent : AppColors.success,
            ),
          ),
        ),
      ),
    );
  }

  Widget _horizontalSplitHandle(BuildContext context, void Function(double deltaDx) onDrag) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: SizedBox(
            width: 10,
            child: Center(
              child: Container(
                width: 3,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.outline.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainWorkspace(BuildContext context) {
    switch (_mode) {
      case AssistantMode.experienceSpec:
        return LayoutBuilder(
          builder: (ctx, cons) {
            final double totalW = cons.maxWidth;
            const double dividerW = 10;
            final double minLeft = totalW < 520 ? 220 : 300;
            final double minRight = totalW < 520 ? 180 : 280;
            final double maxLeft = math.max(minLeft, totalW - dividerW - minRight);
            final double minLeftClamped = math.min(minLeft, maxLeft);
            final double base = (totalW - dividerW) * 0.5;
            final double leftW = (_experienceLeftWidthPx ?? base).clamp(minLeftClamped, maxLeft);
            final double rightBubbleMax = _bubbleMaxForParentWidth(totalW - dividerW - leftW);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: leftW,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Theme.of(ctx).colorScheme.outlineVariant),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _splitPanelHeader(ctx, "입력 폼", Icons.edit_note_outlined),
                        Expanded(
                          child: ExperienceSpecForm(
                            key: _experienceFormKey,
                            enabled: !isGenerating,
                            onAiTable: (p) {
                              _sendProgrammatic(
                                _promptBuilder.experienceTableRequest(p),
                              );
                            },
                            onAiRecommend: (p) {
                              _sendProgrammatic(
                                _promptBuilder.experienceRecommendationRequest(p),
                              );
                            },
                            onAiNarrativeMerge: (p) {
                              _sendProgrammatic(
                                _promptBuilder.experienceNarrativeMergeRequest(p),
                              );
                            },
                            onMergeToAttachment: (m) {
                              setState(() {
                                attachmentController.text = m;
                              });
                              _snack("자료·복붙 칸에 합본을 넣었습니다.");
                            },
                            onExportMerged: () => _exportExperienceFormMerged(),
                            onSaveStructured: _saveStructuredCareerData,
                          ),
                        ),
                        if (cons.maxHeight >= 520)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: ExperienceLibraryPanel(
                              experiences: _savedExperiences,
                              enabled: !isGenerating,
                              onEdit: _editExperienceCard,
                              onDelete: _deleteExperienceCard,
                              onDuplicate: _duplicateExperienceCard,
                              onUseForEssay: _useExperienceForEssay,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _horizontalSplitHandle(ctx, (dx) {
                  setState(() {
                    final double next = (_experienceLeftWidthPx ?? base) + dx;
                    _experienceLeftWidthPx = next.clamp(minLeftClamped, maxLeft);
                  });
                }),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _splitPanelHeader(ctx, "자유 채팅·자료", Icons.chat_bubble_outline),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            buildListView(context, rightBubbleMax),
                            buildEmptyScreen(context, compact: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      case AssistantMode.masterResume:
        return LayoutBuilder(
          builder: (ctx, cons) {
            final double totalW = cons.maxWidth;
            const double dividerW = 10;
            final double minLeft = totalW < 520 ? 240 : 300;
            final double minRight = totalW < 520 ? 180 : 260;
            final double maxLeft = math.max(minLeft, totalW - dividerW - minRight);
            final double minLeftClamped = math.min(minLeft, maxLeft);
            final double base = (totalW - dividerW) * 0.52;
            final double leftW = (_masterLeftWidthPx ?? base).clamp(minLeftClamped, maxLeft);
            final double rightBubbleMax = _bubbleMaxForParentWidth(totalW - dividerW - leftW);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: leftW,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Theme.of(ctx).colorScheme.outlineVariant),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _splitPanelHeader(ctx, "마스터 자소서", Icons.article_outlined),
                        Expanded(
                          child: MasterResumeWorkspace(
                            tabController: _masterTabController,
                            qControllers: _masterQControllers,
                            fullDraftController: _masterFullDraftController,
                            targetJobController: _masterTargetJobController,
                            availableExperiences: _savedExperiences,
                            savedVersionCounts: _essayVersionCounts,
                            enabled: !isGenerating,
                            onAiForQuestion: _requestMasterQuestionDraft,
                            onAiFullReview: _requestMasterFullReview,
                            onSaveEssayVersion: _saveMasterEssayVersion,
                            onLoadEssayVersion: _loadMasterEssayVersionIntoEditor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _horizontalSplitHandle(ctx, (dx) {
                  setState(() {
                    final double next = (_masterLeftWidthPx ?? base) + dx;
                    _masterLeftWidthPx = next.clamp(minLeftClamped, maxLeft);
                  });
                }),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _splitPanelHeader(ctx, "자유 채팅", Icons.chat_bubble_outline),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            buildListView(context, rightBubbleMax),
                            buildEmptyScreen(context, compact: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      case AssistantMode.portfolio:
        return LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints cons) {
            final double leftW = math.min(420.0, math.max(300.0, cons.maxWidth * 0.42));
            final double rightBubbleMax = _bubbleMaxForParentWidth(cons.maxWidth - leftW);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: leftW,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Theme.of(ctx).colorScheme.outlineVariant),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _splitPanelHeader(ctx, "포트폴리오·지원 기록", Icons.layers_outlined),
                        Expanded(
                          child: CareerArtifactPanel(
                            experiences: _savedExperiences,
                            portfolioProjects: _portfolioProjects,
                            applicationRecords: _applicationRecords,
                            enabled: !isGenerating,
                            onCreatePortfolioProject: _createPortfolioProjectFromExperience,
                            onDeletePortfolioProject: _deletePortfolioProject,
                            onCreateApplicationRecord: _createApplicationRecord,
                            onDeleteApplicationRecord: _deleteApplicationRecord,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      buildListView(context, rightBubbleMax),
                      buildEmptyScreen(context, compact: true),
                    ],
                  ),
                ),
              ],
            );
          },
        );
    }
  }

  Widget buildModeBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AppCard(
        padding: const EdgeInsets.all(6),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: Row(
          children: [
            _buildModeChip(
              context,
              AssistantMode.experienceSpec,
              "경험·스펙",
              Icons.inventory_2_outlined,
            ),
            _buildModeChip(
              context,
              AssistantMode.masterResume,
              "마스터 자소서",
              Icons.article_outlined,
            ),
            _buildModeChip(
              context,
              AssistantMode.portfolio,
              "포트폴리오",
              Icons.layers_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(
    BuildContext context,
    AssistantMode mode,
    String label,
    IconData icon,
  ) {
    final bool selected = _mode == mode;

    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: AppColors.primary.withValues(alpha: 0.14),
          highlightColor: AppColors.primary.withValues(alpha: 0.08),
          hoverColor: AppColors.primary.withValues(alpha: 0.06),
          onTap: isGenerating
              ? null
              : () {
                  setState(() {
                    _mode = mode;
                  });
                  _syncSendEnabled();
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? AppColors.onPrimary : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 4,
                      style: TextStyle(
                        color: selected ? AppColors.onPrimary : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyScreen(BuildContext context, {bool compact = false}) {
    return EmptyChatPlaceholder(
      mode: _mode,
      hasMessages: _room.chats.isNotEmpty,
      compact: compact,
    );
  }

  Widget buildListView(BuildContext context, double bubbleMaxWidth) {
    return ChatMessageList(
      messages: _room.chats,
      controller: _scrollController,
      bubbleMaxWidth: bubbleMaxWidth,
      onApplyAssistantText: _applyAssistantText,
      onCopyAssistantText: _copyAssistantTextToAttachment,
      onSaveAssistantText: _saveAssistantTextAsVersion,
    );
  }

  void _applyAssistantText(String text) {
    final String value = text.trim();
    if (value.isEmpty) {
      return;
    }
    if (_mode == AssistantMode.masterResume) {
      final int tabIndex = _masterTabController.index;
      if (tabIndex < 6) {
        _masterQControllers[tabIndex].text = value;
      } else {
        _masterFullDraftController.text = value;
      }
      _snack("AI 답변을 현재 자소서 초안에 적용했습니다.");
      return;
    }
    setState(() {
      attachmentController.text = value;
    });
    _snack("AI 답변을 자료·복붙 칸에 반영했습니다.");
  }

  void _copyAssistantTextToAttachment(String text) {
    setState(() {
      attachmentController.text = text.trim();
    });
    _syncSendEnabled();
    _snack("AI 답변을 자료·복붙 칸에 복사했습니다.");
  }

  Future<void> _saveAssistantTextAsVersion(String text) async {
    if (_mode != AssistantMode.masterResume) {
      _copyAssistantTextToAttachment(text);
      return;
    }
    final int tabIndex = _masterTabController.index;
    await _saveMasterEssayVersion(tabIndex, text, const []);
  }

  Widget buildAttachmentPanel(BuildContext context) {
    return AttachmentComposerPanel(
      controller: attachmentController,
      attachments: _pickedBinary,
      isExpanded: _attachmentPanelExpanded,
      isGenerating: isGenerating,
      maxBinaryCount: _maxBinaryCount,
      onPickFiles: _pickBinaryFiles,
      onClearAttachments: _clearAllPickedBinary,
      onRemoveAttachment: _removePickedBinary,
      onToggleExpanded: () {
        setState(() {
          _attachmentPanelExpanded = !_attachmentPanelExpanded;
        });
      },
    );
  }

  Widget buildTextField(BuildContext context) {
    return ChatInputBar(
      controller: controller,
      focusNode: focusNode,
      hintText: _hintForMode(),
      canSend: sendButtonEnabled,
      isGenerating: isGenerating,
      onSubmitted: (_) => sendMessage(),
      onSend: sendMessage,
    );
  }

  String _hintForMode() {
    switch (_mode) {
      case AssistantMode.masterResume:
        return "추가로 AI에게 말할 내용이 있으면 입력하세요.";
      case AssistantMode.experienceSpec:
        return "오른쪽 채팅에 질문·경험을 입력하세요.";
      case AssistantMode.portfolio:
        return "예: 데이터 PM 지원. Figma 목차랑 카피 초안 짜줘.";
    }
  }

  void sendMessage() {
    if (isGenerating) {
      return;
    }
    final ChatTurn? turn = _chatFlowController.createUserTurn(
      mode: _mode,
      currentChats: _room.chats,
      mainText: controller.text,
      attachmentText: attachmentController.text,
      attachments: _pickedBinary,
      targetJob: _masterTargetJobController.text,
      experienceContext: _experienceContextBlock(),
    );
    if (turn == null) {
      return;
    }

    setState(() {
      _room.chats.add(turn.userMessage);
      isGenerating = true;
    });

    controller.clear();
    focusNode.unfocus();
    _syncSendEnabled();

    _scrollChatToBottom();
    _startAssistantStream(turn);
  }

  void _startAssistantStream(ChatTurn turn) {
    final ChatMessage gptMessage = ChatMessage(
      isMe: false,
      text: "",
      sentAt: DateTime.now(),
    );

    setState(() {
      _room.chats.add(gptMessage);
    });

    final int gptMessageIndex = _room.chats.length - 1;

    _chatFlowController
        .streamAssistantText(turn)
        .listen(
          (String answer) {
            setState(() {
              _room.chats[gptMessageIndex].text += answer;
            });
            _scrollChatToBottom();
          },
          onDone: () {
            setState(() {
              isGenerating = false;
              _pickedBinary.clear();
            });
            _syncSendEnabled();
            _scrollChatToBottom();
          },
          onError: (error) {
            setState(() {
              _room.chats[gptMessageIndex].text = "응답 생성 중 오류가 발생했습니다.\n$error";
              isGenerating = false;
            });
          },
        );
  }

  AppBar buildAppBar() {
    return AppBar(
      titleSpacing: 18,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBrandMark(size: 28),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("JasoSupporter"),
              SizedBox(height: 1),
              Text(
                "경험 카드 기반 취업 준비 워크스페이스",
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.2,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: StatusPill(
              label: "저장 경험 ${_savedExperiences.length}개",
              icon: Icons.inventory_2_outlined,
            ),
          ),
        ),
      ],
    );
  }
}
