import 'dart:math' as math;

import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/core/widgets/chat_widgets.dart';
import 'package:chatgptmini/core/widgets/composer_widgets.dart';
import 'package:chatgptmini/data/providers/interview_questions_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter/material.dart';

/// Chat-first 작업 화면의 우측 AI 코칭 패널 메타.
class ChatCoachMeta {
  const ChatCoachMeta({
    required this.modeLabel,
    required this.accent,
    required this.tint,
    required this.chips,
    this.muted = false,
    this.mutedHint,
  });

  final String modeLabel;
  final Color accent;
  final Color tint;
  final List<ChatCoachChip> chips;
  final bool muted;
  final String? mutedHint;
}

class ChatCoachChip {
  const ChatCoachChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;
}

ChatCoachMeta coachMetaForMode(
  AssistantMode mode, {
  required ValueChanged<String> onChipPrompt,
  bool muted = false,
}) {
  switch (mode) {
    case AssistantMode.experienceSpec:
      return ChatCoachMeta(
        modeLabel: '경험 정리',
        accent: AppColors.experience,
        tint: AppColors.experienceTint,
        chips: [
          ChatCoachChip(
            label: 'STAR로 정리',
            onTap: () => onChipPrompt(
              '이 내용을 경험 카드로 저장할 수 있게 아래 라벨 형식으로만 구조화해 주세요. '
              '없는 사실은 만들지 마세요.\n'
              '제목:\n기관:\n역할:\n기간: (yy.mm-yy.mm)\n상황:\n과제:\n행동:\n성과:\n배운 점:',
            ),
          ),
          ChatCoachChip(
            label: '보완 질문',
            onTap: () => onChipPrompt('지금 입력만으로 부족한 정보를 보완 질문으로 짧게 물어봐 주세요.'),
          ),
        ],
      );
    case AssistantMode.masterResume:
      return ChatCoachMeta(
        modeLabel: '마스터 자소서',
        accent: AppColors.master,
        tint: AppColors.masterTint,
        chips: [
          ChatCoachChip(
            label: '경험 매칭',
            onTap: () => onChipPrompt(
              '현재 문항에 적합한 저장된 경험만 골라 id·title·reason 형식으로 추천해 주세요. '
              '없는 경험은 만들지 마세요. 추천이 없으면 "추천 없음"만 쓰세요.',
            ),
          ),
          ChatCoachChip(
            label: '초안 생성',
            onTap: () => onChipPrompt('선택한 경험만 근거로 현재 문항 초안을 작성해 주세요. 없는 사실은 만들지 마세요.'),
          ),
          ChatCoachChip(
            label: '첨삭',
            onTap: () => onChipPrompt('현재 초안을 과장·키워드 나열 없이 첨삭해 주세요.'),
          ),
        ],
      );
    case AssistantMode.portfolio:
      return ChatCoachMeta(
        modeLabel: '포트폴리오 개요',
        accent: AppColors.portfolio,
        tint: AppColors.portfolioTint,
        chips: [
          ChatCoachChip(
            label: '개요 보완',
            onTap: () => onChipPrompt('한 줄 포지셔닝과 목차·섹션 불릿만으로 포트폴리오 개요를 보완해 주세요. 시각 레이아웃은 다루지 마세요.'),
          ),
          ChatCoachChip(
            label: '섹션 불릿 제안',
            onTap: () => onChipPrompt('선택한 경험 기준으로 섹션별 불릿만 제안해 주세요.'),
          ),
        ],
      );
    case AssistantMode.interview:
      return ChatCoachMeta(
        modeLabel: '면접 대비',
        accent: AppColors.coaching,
        tint: AppColors.coachingTint,
        chips: [
          ChatCoachChip(
            label: '예상 질문',
            onTap: () => onChipPrompt(
              '선택한 경험 STAR만 근거로 면접 예상 질문을 번호 목록으로 작성해 주세요. '
              '없는 사실은 만들지 마세요.',
            ),
          ),
          ChatCoachChip(
            label: '답변 초안',
            onTap: () => onChipPrompt('선택한 경험 STAR만 근거로 방어 가능한 면접 답변 초안을 작성해 주세요.'),
          ),
          ChatCoachChip(
            label: '방어 가능성 점검',
            onTap: () => onChipPrompt('이 답변에서 과장·허위 위험이 있는 문장을 짚고 방어 가능한 표현으로 고쳐 주세요.'),
          ),
        ],
      );
  }
}

/// 설정 화면용 음소거 코칭 메타.
ChatCoachMeta settingsMutedCoachMeta() {
  return const ChatCoachMeta(
    modeLabel: '설정',
    accent: AppColors.onSurfaceVariant,
    tint: AppColors.surfaceContainer,
    chips: [],
    muted: true,
    mutedHint: '설정에서는 코칭이 제한됩니다. 작업 화면으로 이동해 AI를 사용하세요.',
  );
}

/// 모드별 적용/복사/저장 버튼 라벨.
({String apply, String copy, String save}) coachActionLabelsFor(
  AssistantMode mode, {
  String? latestAssistantText,
}) {
  final String text = latestAssistantText?.trim() ?? '';
  return switch (mode) {
    AssistantMode.experienceSpec => (
        apply: '경험 확인에 적용',
        copy: '클립보드에 복사',
        save: '경험 카드로 저장',
      ),
    AssistantMode.masterResume => (
        apply: text.isNotEmpty &&
                (text.contains('id:') ||
                    (text.contains('추천') && text.contains('경험')))
            ? '문항 경험에 적용'
            : '초안에 적용',
        copy: '클립보드에 복사',
        save: '새 버전으로 저장',
      ),
    AssistantMode.portfolio => (
        apply: '개요 편집에 적용',
        copy: '클립보드에 복사',
        save: '개요로 저장',
      ),
    AssistantMode.interview => (
        apply: InterviewQuestionParser.looksLikeQuestionList(text)
            ? '질문 목록에 적용'
            : '답변에 반영',
        copy: '클립보드에 복사',
        save: InterviewQuestionParser.looksLikeQuestionList(text)
            ? '질문 목록 저장'
            : '면접 답변 저장',
      ),
  };
}

/// 모드별 입력창 힌트.
String coachHintForMode(AssistantMode mode) {
  return switch (mode) {
    AssistantMode.masterResume => '추가로 AI에게 말할 내용이 있으면 입력하세요.',
    AssistantMode.experienceSpec => '경험을 말하거나 STAR 정리를 요청하세요.',
    AssistantMode.portfolio => '한 줄 포지셔닝·목차·섹션 불릿을 요청하세요.',
    AssistantMode.interview => '예상 질문이나 답변 초안을 요청하세요.',
  };
}

/// Sidebar 바깥에서 쓰는 작업 영역: 본문 | AI 챗봇(고정 폭).
class ChatFirstShell extends StatelessWidget {
  const ChatFirstShell({
    super.key,
    required this.workBody,
    required this.coachPanel,
    this.chatWidth = 360,
  });

  final Widget workBody;
  final Widget coachPanel;
  final double chatWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints cons) {
        final bool stackChat = cons.maxWidth < 980;
        if (stackChat) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: workBody),
              Expanded(flex: 4, child: coachPanel),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: workBody),
            SizedBox(width: chatWidth, child: coachPanel),
          ],
        );
      },
    );
  }
}

/// Figma 시안과 동일한 우측 AI 코칭 패널.
class ChatCoachPanel extends StatelessWidget {
  const ChatCoachPanel({
    super.key,
    required this.meta,
    required this.messages,
    required this.scrollController,
    required this.inputController,
    required this.inputFocusNode,
    required this.attachments,
    required this.isGenerating,
    required this.canSend,
    required this.hintText,
    required this.onPickFiles,
    required this.onClearAttachments,
    required this.onRemoveAttachment,
    required this.onSend,
    this.selectedModelId = GeminiModelOption.defaultId,
    this.modelOptions = GeminiModelOption.defaults,
    this.questionKinds = const [CoachQuestionKind.freeform],
    this.selectedQuestionKindId = 'freeform',
    this.onModelChanged,
    this.onQuestionKindChanged,
    this.onApplyAssistantText,
    this.onCopyAssistantText,
    this.onSaveAssistantText,
    this.applyLabel = '초안에 적용',
    this.copyLabel = '클립보드에 복사',
    this.saveLabel = '버전으로 저장',
    this.selectionStatusLabel,
  });

  final ChatCoachMeta meta;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final List<PickedAttachment> attachments;
  final bool isGenerating;
  final bool canSend;
  final String hintText;
  final String? selectionStatusLabel;
  final String selectedModelId;
  final List<GeminiModelOption> modelOptions;
  final List<CoachQuestionKind> questionKinds;
  final String selectedQuestionKindId;
  final ValueChanged<String>? onModelChanged;
  final ValueChanged<String>? onQuestionKindChanged;
  final VoidCallback onPickFiles;
  final VoidCallback onClearAttachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onSend;
  final ValueChanged<String>? onApplyAssistantText;
  final ValueChanged<String>? onCopyAssistantText;
  final ValueChanged<String>? onSaveAssistantText;
  final String applyLabel;
  final String copyLabel;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: meta.tint,
        border: const Border(left: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints cons) {
          final bool tight = cons.maxHeight < 420;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              if (meta.mutedHint != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppChatStyle.panelInset,
                    0,
                    AppChatStyle.panelInset,
                    8,
                  ),
                  child: Text(meta.mutedHint!, style: AppChatStyle.meta),
                ),
              if (!meta.muted && meta.chips.isNotEmpty && !tight) _buildChips(),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ChatMessageList(
                      messages: messages,
                      controller: scrollController,
                      bubbleMaxWidth: math.min(
                        300,
                        cons.maxWidth - (AppChatStyle.panelInset * 2),
                      ),
                      applyLabel: applyLabel,
                      copyLabel: copyLabel,
                      saveLabel: saveLabel,
                      onApplyAssistantText: meta.muted ? null : onApplyAssistantText,
                      onCopyAssistantText: meta.muted ? null : onCopyAssistantText,
                      onSaveAssistantText: meta.muted ? null : onSaveAssistantText,
                    ),
                    EmptyChatPlaceholder(
                      modeLabel: meta.modeLabel,
                      accent: meta.accent,
                      hasMessages: messages.isNotEmpty,
                      compact: true,
                    ),
                  ],
                ),
              ),
              if (!meta.muted)
                ChatComposer(
                  controller: inputController,
                  focusNode: inputFocusNode,
                  hintText: hintText,
                  canSend: canSend,
                  isGenerating: isGenerating,
                  onSend: onSend,
                  attachments: attachments,
                  onClearAttachments: onClearAttachments,
                  onRemoveAttachment: onRemoveAttachment,
                  onPickFiles: onPickFiles,
                  selectedModelId: selectedModelId,
                  modelOptions: modelOptions,
                  questionKinds: questionKinds,
                  selectedQuestionKindId: selectedQuestionKindId,
                  onModelChanged: onModelChanged,
                  onQuestionKindChanged: onQuestionKindChanged,
                  compact: true,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppChatStyle.panelInset,
        12,
        AppChatStyle.panelInset,
        10,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppChatStyle.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: meta.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(Icons.auto_awesome, size: 16, color: meta.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI 코칭', style: AppChatStyle.title),
                const SizedBox(height: 2),
                Text(
                  meta.modeLabel,
                  style: AppChatStyle.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: meta.accent,
                  ),
                ),
                if (!meta.muted) ...[
                  const SizedBox(height: 1),
                  Text(
                    GeminiModelOption.displayLabel(selectedModelId),
                    style: AppChatStyle.caption,
                  ),
                ],
              ],
            ),
          ),
          if (selectionStatusLabel != null && selectionStatusLabel!.trim().isNotEmpty)
            StatusPill(
              label: selectionStatusLabel!.trim(),
              icon: Icons.fact_check_outlined,
              color: meta.accent,
            ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppChatStyle.panelInset,
        8,
        AppChatStyle.panelInset,
        4,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final ChatCoachChip chip in meta.chips)
            ActionChip(
              label: Text(
                chip.label,
                style: AppChatStyle.chip.copyWith(color: meta.accent),
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(color: meta.accent.withValues(alpha: 0.28)),
              onPressed: isGenerating ? null : chip.onTap,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
        ],
      ),
    );
  }
}
