import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_brand_mark.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/core/widgets/markdown_text.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:flutter/material.dart';

class EmptyChatPlaceholder extends StatelessWidget {
  const EmptyChatPlaceholder({
    super.key,
    required this.hasMessages,
    this.mode,
    this.modeLabel,
    this.accent,
    this.compact = false,
  });

  final AssistantMode? mode;
  final String? modeLabel;
  final Color? accent;
  final bool hasMessages;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (hasMessages) {
      return const SizedBox.shrink();
    }

    final ({IconData icon, String title, String message}) copy;
    if (modeLabel != null) {
      copy = (
        icon: Icons.auto_awesome,
        title: "AI 코칭 · $modeLabel",
        message: "본문에서 작업을 이어가며, 여기서 보완 질문·초안·첨삭을 받을 수 있습니다.",
      );
    } else {
      copy = switch (mode ?? AssistantMode.experienceSpec) {
        AssistantMode.masterResume => (
          icon: Icons.article_outlined,
          title: "자소서 작업 보조 채팅",
          message: "왼쪽에서 직무·문항과 선택 경험을 정리하면, 이 영역에 AI 답변이 표시됩니다.",
        ),
        AssistantMode.experienceSpec => (
          icon: Icons.inventory_2_outlined,
          title: "경험을 카드로 정리해 보세요",
          message: "왼쪽 폼에 경험을 나누어 적고, 필요한 자료는 채팅창에 붙여 넣거나 파일로 첨부할 수 있습니다.",
        ),
        AssistantMode.portfolio => (
          icon: Icons.layers_outlined,
          title: "포트폴리오 개요를 함께 잡습니다",
          message: "한 줄 포지셔닝과 목차·섹션 불릿만 정리합니다. 시각 레이아웃은 다루지 않습니다.",
        ),
        AssistantMode.interview => (
          icon: Icons.record_voice_over_outlined,
          title: "면접 답변을 함께 다듬습니다",
          message: "Experience STAR만 근거로 예상 질문과 방어 가능한 답변을 준비합니다.",
        ),
      };
    }

    return EmptyState(
      icon: copy.icon,
      title: copy.title,
      message: copy.message,
      compact: compact,
    );
  }
}

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.controller,
    required this.bubbleMaxWidth,
    this.onApplyAssistantText,
    this.onCopyAssistantText,
    this.onSaveAssistantText,
    this.applyLabel = '초안에 적용',
    this.copyLabel = '클립보드에 복사',
    this.saveLabel = '버전으로 저장',
  });

  final List<ChatMessage> messages;
  final ScrollController controller;
  final double bubbleMaxWidth;
  final ValueChanged<String>? onApplyAssistantText;
  final ValueChanged<String>? onCopyAssistantText;
  final ValueChanged<String>? onSaveAssistantText;
  final String applyLabel;
  final String copyLabel;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: AppChatStyle.listPadding,
      children: [
        for (int i = 0; i < messages.length; i++)
          messages[i].isMe
              ? UserChatBubble(text: messages[i].text, bubbleMaxWidth: bubbleMaxWidth)
              : AssistantChatBubble(
                  text: messages[i].text,
                  bubbleMaxWidth: bubbleMaxWidth,
                  showActions: messages[i].text.trim().isNotEmpty,
                  applyLabel: applyLabel,
                  copyLabel: copyLabel,
                  saveLabel: saveLabel,
                  onApply: onApplyAssistantText == null
                      ? null
                      : () => onApplyAssistantText!(messages[i].text),
                  onCopy: onCopyAssistantText == null
                      ? null
                      : () => onCopyAssistantText!(messages[i].text),
                  onSave: onSaveAssistantText == null
                      ? null
                      : () => onSaveAssistantText!(messages[i].text),
                ),
      ],
    );
  }
}

class UserChatBubble extends StatelessWidget {
  const UserChatBubble({
    super.key,
    required this.text,
    required this.bubbleMaxWidth,
  });

  final String text;
  final double bubbleMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
        padding: AppChatStyle.bubblePadding,
        margin: AppChatStyle.bubbleMargin,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppChatStyle.bubbleRadius),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: SelectableText(
          text.softWrapWords(),
          style: AppChatStyle.body.copyWith(color: AppColors.onPrimaryContainer),
        ),
      ),
    );
  }
}

class AssistantChatBubble extends StatelessWidget {
  const AssistantChatBubble({
    super.key,
    required this.text,
    required this.bubbleMaxWidth,
    this.showActions = false,
    this.onApply,
    this.onCopy,
    this.onSave,
    this.applyLabel = '초안에 적용',
    this.copyLabel = '클립보드에 복사',
    this.saveLabel = '버전으로 저장',
  });

  final String text;
  final double bubbleMaxWidth;
  final bool showActions;
  final VoidCallback? onApply;
  final VoidCallback? onCopy;
  final VoidCallback? onSave;
  final String applyLabel;
  final String copyLabel;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: AppChatStyle.bubbleMargin,
        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBrandMark(size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text.isEmpty
                      ? Text(
                          '답변을 생성하는 중입니다...',
                          style: AppChatStyle.hint,
                        )
                      : MarkdownText(
                          text,
                          baseStyle: AppChatStyle.body.copyWith(height: 1.5),
                        ),
                  if (showActions) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (onApply != null)
                          _ChatActionButton(
                            icon: Icons.assignment_returned_outlined,
                            label: applyLabel,
                            onPressed: onApply!,
                          ),
                        if (onCopy != null)
                          _ChatActionButton(
                            icon: Icons.copy_outlined,
                            label: copyLabel,
                            onPressed: onCopy!,
                          ),
                        if (onSave != null)
                          _ChatActionButton(
                            icon: Icons.history_edu_outlined,
                            label: saveLabel,
                            onPressed: onSave!,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatActionButton extends StatelessWidget {
  const _ChatActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
        side: AppChatStyle.hairline,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: AppChatStyle.caption.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
  }
}
