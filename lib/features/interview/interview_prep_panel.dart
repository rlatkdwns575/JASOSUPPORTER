import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

/// I01 면접 대비 작업 본문.
class InterviewPrepPanel extends StatelessWidget {
  const InterviewPrepPanel({
    super.key,
    required this.experiences,
    required this.savedAnswers,
    required this.selectedExperienceIds,
    required this.enabled,
    required this.onToggleExperience,
    required this.onGenerateQuestions,
    required this.onOpenQuestion,
    required this.onOpenSavedAnswer,
    required this.onDeleteAnswer,
    this.generatedQuestions = const <String>[],
  });

  final List<Experience> experiences;
  final List<InterviewAnswer> savedAnswers;
  final Set<String> selectedExperienceIds;
  final List<String> generatedQuestions;
  final bool enabled;
  final ValueChanged<String> onToggleExperience;
  final VoidCallback onGenerateQuestions;
  final ValueChanged<String> onOpenQuestion;
  final ValueChanged<InterviewAnswer> onOpenSavedAnswer;
  final ValueChanged<InterviewAnswer> onDeleteAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        const Text(
          '면접 대비',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: '질문 생성',
                icon: Icons.quiz_outlined,
              ),
              const SizedBox(height: 12),
              if (experiences.isEmpty)
                const Text(
                  '저장된 경험이 없습니다.',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                )
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
                        labelStyle: TextStyle(
                          color: selectedExperienceIds.contains(e.id)
                              ? AppColors.coaching
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.coaching),
                  onPressed: enabled && selectedExperienceIds.isNotEmpty ? onGenerateQuestions : null,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('예상 질문 생성'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '생성된 예상 질문',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
        const SizedBox(height: 10),
        if (generatedQuestions.isEmpty)
          const AppCard(
            child: Text(
              '경험을 선택한 뒤 「예상 질문 생성」을 누르면 여기에 질문이 표시됩니다. '
              '연습용 샘플 질문은 제공하지 않으며, 저장된 Experience만 근거로 생성합니다.',
              style: TextStyle(fontSize: 13.5, height: 1.45, color: AppColors.onSurfaceVariant),
            ),
          )
        else
          for (final String q in generatedQuestions) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                onTap: enabled ? () => onOpenQuestion(q) : null,
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AccentIconChip(
                        icon: Icons.record_voice_over_outlined,
                        color: AppColors.coaching,
                        tint: AppColors.coachingTint,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        SectionHeader(
          title: '저장된 면접 답변',
          icon: Icons.bookmark_outline,
          accent: AppColors.coaching,
          accentTint: AppColors.coachingTint,
          trailing: StatusPill(label: '${savedAnswers.length}개', color: AppColors.coaching),
        ),
        const SizedBox(height: 10),
        for (final InterviewAnswer answer in savedAnswers) ...[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              onTap: enabled ? () => onOpenSavedAnswer(answer) : null,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(answer.question, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      answer.answer,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: enabled ? () => onDeleteAnswer(answer) : null,
                        child: const Text('삭제'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
