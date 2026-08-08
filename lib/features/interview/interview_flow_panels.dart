import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

/// I02 예상 질문 상세.
class InterviewQuestionDetailPanel extends StatelessWidget {
  const InterviewQuestionDetailPanel({
    super.key,
    required this.questionController,
    required this.experiences,
    required this.selectedExperienceIds,
    required this.enabled,
    required this.onToggleExperience,
    required this.onDraftAnswer,
    required this.onOpenDefend,
    required this.onBack,
  });

  final TextEditingController questionController;
  final List<Experience> experiences;
  final Set<String> selectedExperienceIds;
  final bool enabled;
  final ValueChanged<String> onToggleExperience;
  final VoidCallback onDraftAnswer;
  final VoidCallback onOpenDefend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const Expanded(
              child: Text(
                '예상 질문 상세',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: '질문',
                icon: Icons.quiz_outlined,
                accent: AppColors.coaching,
                accentTint: AppColors.coachingTint,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: questionController,
                enabled: enabled,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '면접 질문',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('연결 Experience', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (experiences.isEmpty)
                const Text('저장된 경험이 없습니다.', style: TextStyle(color: AppColors.onSurfaceVariant))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final Experience e in experiences)
                      FilterChip(
                        selected: selectedExperienceIds.contains(e.id),
                        label: Text(e.title.isEmpty ? '(제목 없음)' : e.title),
                        onSelected: enabled ? (_) => onToggleExperience(e.id) : null,
                        selectedColor: AppColors.coachingTint,
                        checkmarkColor: AppColors.coaching,
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.coaching),
              onPressed: enabled
                  ? () {
                      if (questionController.text.trim().isEmpty) {
                        return;
                      }
                      onDraftAnswer();
                    }
                  : null,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('답변 초안'),
            ),
            OutlinedButton(
              onPressed: enabled
                  ? () {
                      if (questionController.text.trim().isEmpty) {
                        return;
                      }
                      onOpenDefend();
                    }
                  : null,
              child: const Text('방어 답변 편집'),
            ),
          ],
        ),
      ],
    );
  }
}

/// I03 방어 가능 답변 에디터.
class InterviewAnswerDefendPanel extends StatelessWidget {
  const InterviewAnswerDefendPanel({
    super.key,
    required this.question,
    required this.answerController,
    required this.enabled,
    required this.onSave,
    required this.onRequestPolish,
    required this.onBack,
  });

  final String question;
  final TextEditingController answerController;
  final bool enabled;
  final VoidCallback onSave;
  final VoidCallback onRequestPolish;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const Expanded(
              child: Text(
                '방어 가능 답변',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                question.isEmpty ? '(질문 없음)' : question,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.35),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: answerController,
                enabled: enabled,
                minLines: 8,
                maxLines: 16,
                decoration: const InputDecoration(
                  labelText: '답변 초안',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.coaching),
              onPressed: enabled && answerController.text.trim().isNotEmpty ? onSave : null,
              icon: const Icon(Icons.bookmark_outline, size: 18),
              label: const Text('면접 답변 저장'),
            ),
            OutlinedButton(
              onPressed: enabled ? onRequestPolish : null,
              child: const Text('방어 가능성 점검'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 저장된 면접 답변 상세(읽기).
class InterviewSavedAnswerPanel extends StatelessWidget {
  const InterviewSavedAnswerPanel({
    super.key,
    required this.answer,
    required this.onBack,
    required this.onDelete,
    required this.enabled,
    this.onEdit,
  });

  final InterviewAnswer answer;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final bool enabled;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const Expanded(
              child: Text('저장된 면접 답변', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            if (onEdit != null)
              TextButton(
                onPressed: enabled ? onEdit : null,
                child: const Text('수정'),
              ),
            TextButton(onPressed: enabled ? onDelete : null, child: const Text('삭제')),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(answer.question, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              Text(answer.answer.softWrapWords(), style: const TextStyle(fontSize: 14, height: 1.45)),
              if (answer.sourceExperienceIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '연결 경험: ${answer.sourceExperienceIds.join(', ')}',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
