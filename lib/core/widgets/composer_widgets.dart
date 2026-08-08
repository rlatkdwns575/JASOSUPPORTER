import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter/material.dart';

/// Cursor 스타일 채팅 입력 카드.
///
/// 상단: 첨부 칩 + 멀티라인 입력
/// 하단: 질문 종류 / 모델 선택 + 첨부·전송
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.canSend,
    required this.isGenerating,
    required this.onSend,
    required this.attachments,
    required this.onClearAttachments,
    required this.onRemoveAttachment,
    this.onPickFiles,
    this.selectedModelId = GeminiModelOption.defaultId,
    this.modelOptions = GeminiModelOption.defaults,
    this.questionKinds = const [CoachQuestionKind.freeform],
    this.selectedQuestionKindId = 'freeform',
    this.onModelChanged,
    this.onQuestionKindChanged,
    this.compact = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool canSend;
  final bool isGenerating;
  final VoidCallback onSend;
  final List<PickedAttachment> attachments;
  final VoidCallback onClearAttachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback? onPickFiles;
  final String selectedModelId;
  final List<GeminiModelOption> modelOptions;
  final List<CoachQuestionKind> questionKinds;
  final String selectedQuestionKindId;
  final ValueChanged<String>? onModelChanged;
  final ValueChanged<String>? onQuestionKindChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<GeminiModelOption> models = modelOptions.isEmpty
        ? GeminiModelOption.defaults
        : modelOptions;
    final String modelId = models.any((GeminiModelOption m) => m.id == selectedModelId)
        ? selectedModelId
        : models.first.id;
    final GeminiModelOption selectedModel = models.firstWhere(
      (GeminiModelOption m) => m.id == modelId,
    );
    final String kindId =
        questionKinds.any((CoachQuestionKind k) => k.id == selectedQuestionKindId)
            ? selectedQuestionKindId
            : questionKinds.first.id;
    final CoachQuestionKind selectedKind = questionKinds.firstWhere(
      (CoachQuestionKind k) => k.id == kindId,
    );
    final bool showToolbar =
        onModelChanged != null || onQuestionKindChanged != null || onPickFiles != null;
    final int minLines = compact ? 2 : 3;
    final int maxLines = compact ? 5 : 8;

    return Padding(
      padding: AppChatStyle.composerOuter,
      child: DecoratedBox(
        decoration: AppChatStyle.composerDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (attachments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: _AttachmentChipRow(
                  attachments: attachments,
                  isGenerating: isGenerating,
                  onClearAttachments: onClearAttachments,
                  onRemoveAttachment: onRemoveAttachment,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: minLines,
                maxLines: maxLines,
                enabled: !isGenerating,
                cursorColor: AppColors.primary,
                cursorWidth: 1.2,
                textInputAction: TextInputAction.newline,
                style: AppChatStyle.body,
                onSubmitted: canSend && !isGenerating ? (_) => onSend() : null,
                decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: AppChatStyle.hint,
                ),
              ),
            ),
            if (showToolbar)
              Padding(
                padding: AppChatStyle.toolbarPadding,
                child: Row(
                  children: [
                    if (onQuestionKindChanged != null) ...[
                      _ComposerMenuChip(
                        label: selectedKind.label,
                        enabled: !isGenerating,
                        filled: true,
                        items: [
                          for (final CoachQuestionKind k in questionKinds)
                            PopupMenuItem<String>(
                              value: k.id,
                              height: 40,
                              child: Text(k.label, style: AppChatStyle.meta),
                            ),
                        ],
                        onSelected: onQuestionKindChanged!,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (onModelChanged != null)
                      Flexible(
                        child: _ComposerMenuChip(
                          label: selectedModel.label,
                          enabled: !isGenerating,
                          filled: false,
                          items: [
                            for (final GeminiModelOption m in models)
                              PopupMenuItem<String>(
                                value: m.id,
                                height: 40,
                                child: Text(
                                  m.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppChatStyle.meta,
                                ),
                              ),
                          ],
                          onSelected: onModelChanged!,
                        ),
                      ),
                    const Spacer(),
                    if (onPickFiles != null)
                      _ComposerIconButton(
                        tooltip: attachments.isNotEmpty
                            ? '파일 첨부 (${attachments.length})'
                            : '파일 첨부',
                        icon: Icons.attach_file_rounded,
                        active: attachments.isNotEmpty,
                        onPressed: isGenerating ? null : onPickFiles,
                      ),
                    const SizedBox(width: 4),
                    _ComposerSendButton(
                      canSend: canSend,
                      isGenerating: isGenerating,
                      onSend: onSend,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentChipRow extends StatelessWidget {
  const _AttachmentChipRow({
    required this.attachments,
    required this.isGenerating,
    required this.onClearAttachments,
    required this.onRemoveAttachment,
  });

  final List<PickedAttachment> attachments;
  final bool isGenerating;
  final VoidCallback onClearAttachments;
  final ValueChanged<int> onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < attachments.length; i++)
          InputChip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: AppColors.surfaceContainer,
            deleteIconColor: AppColors.onSurfaceVariant,
            side: BorderSide.none,
            labelStyle: AppChatStyle.chip,
            label: Text(
              attachments[i].name,
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: isGenerating ? null : () => onRemoveAttachment(i),
          ),
        if (attachments.length > 1)
          TextButton(
            onPressed: isGenerating ? null : onClearAttachments,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: AppChatStyle.caption,
            ),
            child: const Text('모두 지우기'),
          ),
      ],
    );
  }
}

class _ComposerMenuChip extends StatelessWidget {
  const _ComposerMenuChip({
    required this.label,
    required this.enabled,
    required this.filled,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final bool enabled;
  final bool filled;
  final List<PopupMenuEntry<String>> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: label,
      onSelected: onSelected,
      offset: const Offset(0, -6),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: AppChatStyle.hairline,
      ),
      color: AppColors.surface,
      elevation: 2,
      shadowColor: const Color(0x140F172A),
      itemBuilder: (_) => items,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 148),
        padding: EdgeInsets.symmetric(
          horizontal: filled ? 9 : 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: filled ? AppColors.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: filled ? null : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: filled ? AppChatStyle.metaStrong : AppChatStyle.meta,
              ),
            ),
            const SizedBox(width: 1),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppChatStyle.sendSize,
      height: AppChatStyle.sendSize,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(
          width: AppChatStyle.sendSize,
          height: AppChatStyle.sendSize,
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: AppChatStyle.iconSize,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ComposerSendButton extends StatelessWidget {
  const _ComposerSendButton({
    required this.canSend,
    required this.isGenerating,
    required this.onSend,
  });

  final bool canSend;
  final bool isGenerating;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final bool active = canSend && !isGenerating;
    return Material(
      color: active ? AppChatStyle.sendActive : AppChatStyle.sendIdle,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: active ? onSend : null,
        child: SizedBox(
          width: AppChatStyle.sendSize,
          height: AppChatStyle.sendSize,
          child: Center(
            child: isGenerating
                ? const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    size: 16,
                    color: active ? Colors.white : AppColors.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}
