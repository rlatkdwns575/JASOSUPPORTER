import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_star_validator.dart';
import 'package:flutter/material.dart';

/// E10 경험 저장 전 확인.
class ExperienceConfirmPanel extends StatelessWidget {
  const ExperienceConfirmPanel({
    super.key,
    required this.experiences,
    required this.specItems,
    required this.enabled,
    required this.onBack,
    required this.onConfirmSave,
    this.onEditExperience,
    this.onEditSpec,
  });

  final List<Experience> experiences;
  final List<SpecItem> specItems;
  final bool enabled;
  final VoidCallback onBack;
  final VoidCallback onConfirmSave;
  final ValueChanged<Experience>? onEditExperience;
  final ValueChanged<SpecItem>? onEditSpec;

  @override
  Widget build(BuildContext context) {
    final List<ExperienceStarIssue> issues = ExperienceStarValidator.issuesFor(experiences);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        const Text(
          'STAR 확인',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
        if (issues.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            backgroundColor: AppColors.warningTint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '보완하면 더 좋은 카드',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning),
                ),
                const SizedBox(height: 8),
                for (final ExperienceStarIssue issue in issues)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${issue.title}: ${issue.messages.join(' / ')}',
                      style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.onSurface),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (experiences.isEmpty && specItems.isEmpty)
          const AppCard(
            child: Text('확인할 경험·스펙이 없습니다.', style: TextStyle(color: AppColors.onSurfaceVariant)),
          )
        else ...[
          for (final Experience experience in experiences) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.title.isEmpty ? '(제목 없음)' : experience.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      experience.type.label,
                      if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
                      if (experience.role.trim().isNotEmpty) experience.role.trim(),
                      if (experience.period.displayText.isNotEmpty) experience.period.displayText,
                    ].join(' · '),
                    style: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant),
                  ),
                  if (ExperienceStarValidator.missingMessages(experience).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      ExperienceStarValidator.missingMessages(experience).join(' · '),
                      style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _StarLine(label: '상황', value: experience.situation),
                  _StarLine(label: '과제', value: experience.task),
                  _StarLine(label: '행동', value: experience.action),
                  _StarLine(label: '성과', value: experience.result),
                  _StarLine(label: '배운 점', value: experience.learned),
                  if (onEditExperience != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: enabled
                            ? () => onEditExperience!(experience)
                            : null,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('이 카드 수정'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (specItems.isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('스펙', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final SpecItem item in specItems) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item.title.isEmpty ? item.type.name : item.title}'
                            '${item.value.trim().isEmpty ? '' : ' — ${item.value.trim()}'}'
                            '${item.issuedAt.trim().isEmpty ? '' : ' (${item.issuedAt.trim()})'}',
                            style: const TextStyle(fontSize: 13, height: 1.35),
                          ),
                        ),
                        if (onEditSpec != null)
                          TextButton(
                            onPressed: enabled ? () => onEditSpec!(item) : null,
                            child: const Text('수정'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            OutlinedButton(
              onPressed: enabled ? onBack : null,
              child: const Text('입력으로'),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: enabled && (experiences.isNotEmpty || specItems.isNotEmpty) ? onConfirmSave : null,
              icon: const Icon(Icons.check, size: 18),
              label: Text(issues.isEmpty ? '확인 후 저장' : '부족해도 저장'),
            ),
          ],
        ),
      ],
    );
  }
}

/// E11 저장 완료.
class ExperienceCompletePanel extends StatelessWidget {
  const ExperienceCompletePanel({
    super.key,
    required this.savedCount,
    required this.onGoList,
    required this.onApplyEssay,
    required this.onInterview,
    required this.onAddAnother,
  });

  final int savedCount;
  final VoidCallback onGoList;
  final VoidCallback onApplyEssay;
  final VoidCallback onInterview;
  final VoidCallback onAddAnother;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AccentIconChip(
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  tint: Color(0xFFDCFCE7),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  '경험 카드가 저장되었습니다',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '$savedCount개 항목을 저장했습니다.',
                  style: const TextStyle(fontSize: 13.5, color: AppColors.onSurfaceVariant, height: 1.45),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(onPressed: onApplyEssay, child: const Text('자소서에 적용')),
                    OutlinedButton(onPressed: onInterview, child: const Text('면접 질문 생성')),
                    OutlinedButton(onPressed: onAddAnother, child: const Text('다른 경험 추가')),
                    TextButton(onPressed: onGoList, child: const Text('목록으로')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// E12 경험 상세.
class ExperienceDetailPanel extends StatelessWidget {
  const ExperienceDetailPanel({
    super.key,
    required this.experience,
    required this.enabled,
    required this.onEdit,
    required this.onUseForEssay,
    required this.onInterview,
    required this.onPortfolioOutline,
    required this.onBack,
  });

  final Experience experience;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onUseForEssay;
  final VoidCallback onInterview;
  final VoidCallback onPortfolioOutline;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                '경험 상세',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: enabled ? onEdit : null,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('수정'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                experience.title.isEmpty ? '(제목 없음)' : experience.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  experience.type.label,
                  if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
                  if (experience.role.trim().isNotEmpty) experience.role.trim(),
                  if (experience.period.displayText.isNotEmpty) experience.period.displayText,
                ].join(' · '),
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
              ),
              if (experience.competencyTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final String tag in experience.competencyTags)
                      Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11.5)),
                        backgroundColor: AppColors.experienceTint,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STAR', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _StarLine(label: '상황', value: experience.situation),
              _StarLine(label: '과제', value: experience.task),
              _StarLine(label: '행동', value: experience.action),
              _StarLine(label: '성과', value: experience.result),
              _StarLine(label: '배운 점', value: experience.learned),
            ],
          ),
        ),
        if (experience.techStacks.isNotEmpty || experience.evidenceLinks.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (experience.techStacks.isNotEmpty) ...[
                  const Text('기술 스택', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(experience.techStacks.join(', ')),
                  const SizedBox(height: 12),
                ],
                if (experience.evidenceLinks.isNotEmpty) ...[
                  const Text('근거 링크', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  for (final String link in experience.evidenceLinks)
                    Text(link, style: const TextStyle(color: AppColors.experience)),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: enabled ? onUseForEssay : null, child: const Text('자소서에 적용')),
            OutlinedButton(onPressed: enabled ? onInterview : null, child: const Text('면접 질문 생성')),
            OutlinedButton(onPressed: enabled ? onPortfolioOutline : null, child: const Text('포트폴리오 개요로 변환')),
          ],
        ),
      ],
    );
  }
}

class _StarLine extends StatelessWidget {
  const _StarLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final String body = value.trim().isEmpty ? '(미입력)' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.experience)),
          const SizedBox(height: 2),
          Text(body.softWrapWords(), style: const TextStyle(fontSize: 13.5, height: 1.4)),
        ],
      ),
    );
  }
}
