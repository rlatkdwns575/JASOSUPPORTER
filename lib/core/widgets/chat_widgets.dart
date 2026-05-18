import 'package:chatgptmini/app_brand_mark.dart';
import 'package:chatgptmini/assistant_prompts.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/model.dart';
import 'package:flutter/material.dart';

class EmptyChatPlaceholder extends StatelessWidget {
  const EmptyChatPlaceholder({
    super.key,
    required this.mode,
    required this.hasMessages,
    this.compact = false,
  });

  final AssistantMode mode;
  final bool hasMessages;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (hasMessages) {
      return const SizedBox.shrink();
    }

    final ({IconData icon, String title, String message}) copy = switch (mode) {
      AssistantMode.masterResume => (
        icon: Icons.article_outlined,
        title: "자소서 작업 보조 채팅",
        message: "왼쪽에서 직무·문항과 선택 경험을 정리하면, 이 영역에 AI 답변이 표시됩니다.",
      ),
      AssistantMode.experienceSpec => (
        icon: Icons.inventory_2_outlined,
        title: "경험을 카드로 정리해 보세요",
        message: "왼쪽 폼에 경험을 나누어 적고, 필요한 자료는 아래 자료 칸이나 파일 첨부로 전달할 수 있습니다.",
      ),
      AssistantMode.portfolio => (
        icon: Icons.layers_outlined,
        title: "포트폴리오 구조를 함께 잡습니다",
        message: "희망 직무와 대표 프로젝트를 알려주면 Figma용 목차와 카피 방향을 정리합니다.",
      ),
    };

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
  });

  final List<ChatMessage> messages;
  final ScrollController controller;
  final double bubbleMaxWidth;
  final ValueChanged<String>? onApplyAssistantText;
  final ValueChanged<String>? onCopyAssistantText;
  final ValueChanged<String>? onSaveAssistantText;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      children: [
        for (int i = 0; i < messages.length; i++)
          messages[i].isMe
              ? UserChatBubble(text: messages[i].text, bubbleMaxWidth: bubbleMaxWidth)
              : AssistantChatBubble(
                  text: messages[i].text,
                  bubbleMaxWidth: bubbleMaxWidth,
                  showActions: messages[i].text.trim().isNotEmpty,
                  onApply: onApplyAssistantText == null ? null : () => onApplyAssistantText!(messages[i].text),
                  onCopy: onCopyAssistantText == null ? null : () => onCopyAssistantText!(messages[i].text),
                  onSave: onSaveAssistantText == null ? null : () => onSaveAssistantText!(messages[i].text),
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
        ),
        child: SelectableText(
          text,
          style: TextStyle(fontSize: 14, height: 1.45, color: scheme.onPrimaryContainer),
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
  });

  final String text;
  final double bubbleMaxWidth;
  final bool showActions;
  final VoidCallback? onApply;
  final VoidCallback? onCopy;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBrandMark(size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    text.isEmpty ? "답변을 생성하는 중입니다..." : text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (showActions) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onApply,
                          icon: const Icon(Icons.assignment_returned_outlined, size: 16),
                          label: const Text("초안에 적용"),
                        ),
                        OutlinedButton.icon(
                          onPressed: onCopy,
                          icon: const Icon(Icons.copy_outlined, size: 16),
                          label: const Text("자료칸에 복사"),
                        ),
                        OutlinedButton.icon(
                          onPressed: onSave,
                          icon: const Icon(Icons.history_edu_outlined, size: 16),
                          label: const Text("버전으로 저장"),
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
