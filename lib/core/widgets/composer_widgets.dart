import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:flutter/material.dart';

class AttachmentComposerPanel extends StatelessWidget {
  const AttachmentComposerPanel({
    super.key,
    required this.controller,
    required this.attachments,
    required this.isExpanded,
    required this.isGenerating,
    required this.maxBinaryCount,
    required this.onPickFiles,
    required this.onClearAttachments,
    required this.onRemoveAttachment,
    required this.onToggleExpanded,
  });

  final TextEditingController controller;
  final List<PickedAttachment> attachments;
  final bool isExpanded;
  final bool isGenerating;
  final int maxBinaryCount;
  final VoidCallback onPickFiles;
  final VoidCallback onClearAttachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AppCard(
        padding: EdgeInsets.fromLTRB(12, 8, 12, isExpanded ? 10 : 8),
        backgroundColor: attachments.isNotEmpty
            ? AppColors.primaryContainer.withValues(alpha: 0.28)
            : AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionHeader(
              title: "자료·복붙",
              subtitle: attachments.isEmpty
                  ? "필요할 때만 링크·요약·파일을 붙여 주세요."
                  : "첨부 ${attachments.length}개가 이번 AI 요청에 포함됩니다.",
              icon: Icons.attach_file,
              trailing: ActionBar(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: isGenerating ? null : onPickFiles,
                    icon: const Icon(Icons.upload_file, size: 18, color: AppColors.primary),
                    label: const Text("파일", style: TextStyle(fontSize: 13, color: AppColors.primary)),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: isGenerating || attachments.isEmpty ? null : onClearAttachments,
                    child: const Text("첨부 지우기", style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
                  IconButton(
                    tooltip: isExpanded ? "자료 칸 접기" : "자료 칸 펼치기",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    onPressed: isGenerating ? null : onToggleExpanded,
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 4),
              Text(
                "PDF·이미지는 ‘파일’로 첨부하면 AI가 함께 봅니다(파일당 5MB, 최대 $maxBinaryCount개). "
                "한글·Word는 여기에 요약·발췌를 붙여 주세요.",
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.4),
              ),
            ],
            if (attachments.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (int i = 0; i < attachments.length; i++)
                    InputChip(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      deleteIconColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      labelStyle: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                      label: Text(
                        attachments[i].name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: isGenerating ? null : () => onRemoveAttachment(i),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              cursorColor: AppColors.primary,
              minLines: isExpanded ? 2 : 1,
              maxLines: isExpanded ? 6 : 2,
              style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: isExpanded ? "예: 수상 링크, README 발췌, 기획서 문단, 스크린샷 설명…" : "필요할 때만 짧게 붙여 넣기 (펼치기로 넓은 칸)",
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.outline),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.canSend,
    required this.isGenerating,
    required this.onSubmitted,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool canSend;
  final bool isGenerating;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        onSubmitted: onSubmitted,
        focusNode: focusNode,
        controller: controller,
        cursorColor: AppColors.primary,
        style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.onSurface),
        minLines: 1,
        maxLines: 6,
        decoration: InputDecoration(
          suffixIcon: SendButton(
            canSend: canSend,
            isGenerating: isGenerating,
            onSend: onSend,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.canSend,
    required this.isGenerating,
    required this.onSend,
  });

  final bool canSend;
  final bool isGenerating;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final bool enabled = canSend && !isGenerating;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, right: 4),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(1000),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_upward_rounded,
            color: enabled ? AppColors.onPrimary : AppColors.outline,
            size: 20,
          ),
          onPressed: enabled ? onSend : null,
        ),
      ),
    );
  }
}
