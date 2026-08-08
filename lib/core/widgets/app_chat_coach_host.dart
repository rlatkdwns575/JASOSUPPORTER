import 'package:chatgptmini/data/providers/coach_prefs_provider.dart';
import 'package:chatgptmini/data/providers/gemini_models_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/core/widgets/chat_first_shell.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// main 셸에서 ChatCoachPanel 조립을 담당한다.
class AppChatCoachHost extends ConsumerStatefulWidget {
  const AppChatCoachHost({
    super.key,
    required this.mode,
    required this.muted,
    required this.messages,
    required this.scrollController,
    required this.inputController,
    required this.inputFocusNode,
    required this.attachments,
    required this.isGenerating,
    required this.canSend,
    required this.onChipPrompt,
    required this.onPickFiles,
    required this.onClearAttachments,
    required this.onRemoveAttachment,
    required this.onSend,
    required this.onApplyAssistantText,
    required this.onCopyAssistantText,
    required this.onSaveAssistantText,
    this.selectionStatusLabel,
  });

  final AssistantMode mode;
  final bool muted;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final List<PickedAttachment> attachments;
  final bool isGenerating;
  final bool canSend;
  final String? selectionStatusLabel;
  final ValueChanged<String> onChipPrompt;
  final VoidCallback onPickFiles;
  final VoidCallback onClearAttachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onSend;
  final ValueChanged<String> onApplyAssistantText;
  final ValueChanged<String> onCopyAssistantText;
  final ValueChanged<String> onSaveAssistantText;

  @override
  ConsumerState<AppChatCoachHost> createState() => _AppChatCoachHostState();
}

class _AppChatCoachHostState extends ConsumerState<AppChatCoachHost> {
  bool _syncedDefaultModel = false;
  bool _userPickedModel = false;

  String? _latestAssistantText(List<ChatMessage> messages) {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (!messages[i].isMe && messages[i].text.trim().isNotEmpty) {
        return messages[i].text;
      }
    }
    return null;
  }

  void _syncDefaultModel(GeminiModelsCatalog catalog) {
    if (_syncedDefaultModel || _userPickedModel) {
      return;
    }
    _syncedDefaultModel = true;
    if (catalog.defaultModel.isEmpty) {
      return;
    }
    final String current = ref.read(selectedGeminiModelProvider);
    if (current != catalog.defaultModel) {
      ref.read(selectedGeminiModelProvider.notifier).select(catalog.defaultModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<GeminiModelsCatalog> catalogAsync =
        ref.watch(geminiModelsCatalogProvider);
    final GeminiModelsCatalog catalog =
        catalogAsync.asData?.value ?? GeminiModelsCatalog.fallback;
    if (catalogAsync.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncDefaultModel(catalog);
        }
      });
    }

    final ChatCoachMeta meta = widget.muted
        ? settingsMutedCoachMeta()
        : coachMetaForMode(
            widget.mode,
            onChipPrompt: (String prompt) {
              final List<CoachQuestionKind> kinds =
                  CoachQuestionKind.forMode(widget.mode);
              for (final CoachQuestionKind kind in kinds) {
                if (kind.promptTemplate == prompt) {
                  ref
                      .read(coachQuestionKindSelectionProvider.notifier)
                      .select(widget.mode, kind.id);
                  break;
                }
              }
              widget.onChipPrompt(prompt);
            },
          );
    final ({String apply, String copy, String save}) labels =
        coachActionLabelsFor(
      widget.mode,
      latestAssistantText: _latestAssistantText(widget.messages),
    );
    final String modelId = ref.watch(selectedGeminiModelProvider);
    final CoachQuestionKind kind = ref
        .watch(coachQuestionKindSelectionProvider.notifier)
        .kindFor(widget.mode);
    final String hint = kind.hint?.trim().isNotEmpty == true
        ? kind.hint!
        : coachHintForMode(widget.mode);

    return ChatCoachPanel(
      meta: meta,
      messages: widget.messages,
      scrollController: widget.scrollController,
      inputController: widget.inputController,
      inputFocusNode: widget.inputFocusNode,
      attachments: widget.attachments,
      isGenerating: widget.isGenerating,
      canSend: widget.canSend,
      hintText: hint,
      selectionStatusLabel: widget.selectionStatusLabel,
      selectedModelId: modelId,
      modelOptions: catalog.models,
      questionKinds: CoachQuestionKind.forMode(widget.mode),
      selectedQuestionKindId: kind.id,
      onModelChanged: (String id) {
        _userPickedModel = true;
        ref.read(selectedGeminiModelProvider.notifier).select(id);
      },
      onQuestionKindChanged: (String id) {
        ref
            .read(coachQuestionKindSelectionProvider.notifier)
            .select(widget.mode, id);
      },
      applyLabel: labels.apply,
      copyLabel: labels.copy,
      saveLabel: labels.save,
      onPickFiles: widget.onPickFiles,
      onClearAttachments: widget.onClearAttachments,
      onRemoveAttachment: widget.onRemoveAttachment,
      onSend: widget.onSend,
      onApplyAssistantText: widget.onApplyAssistantText,
      onCopyAssistantText: widget.onCopyAssistantText,
      onSaveAssistantText: widget.onSaveAssistantText,
    );
  }
}
