import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_star_validator.dart';
import 'package:flutter/material.dart';

/// 홈 대시보드. 경험·자소서·포트폴리오·지원 현황을 한눈에 보여주는 진입 화면.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.experiences,
    required this.portfolioProjects,
    required this.applicationRecords,
    required this.savedEssayVersionCount,
    required this.interviewAnswerCount,
    required this.onNavigate,
    required this.onAddExperience,
  });

  final List<Experience> experiences;
  final List<PortfolioProject> portfolioProjects;
  final List<ApplicationRecord> applicationRecords;
  final int savedEssayVersionCount;
  final int interviewAnswerCount;
  final ValueChanged<String> onNavigate;
  final VoidCallback onAddExperience;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints cons) {
        final bool narrow = cons.maxWidth < 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(narrow),
              const SizedBox(height: 24),
              _buildStatCards(narrow),
              const SizedBox(height: 20),
              _buildMidRow(narrow),
              const SizedBox(height: 20),
              _buildRecentExperiences(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool narrow) {
    const Widget titles = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "홈",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
      ],
    );
    final Widget action = FilledButton.icon(
      onPressed: onAddExperience,
      icon: const Icon(Icons.add, size: 18),
      label: const Text("새 경험 추가"),
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titles, const SizedBox(height: 14), Align(alignment: Alignment.centerLeft, child: action)],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Expanded(child: titles), action],
    );
  }

  Widget _buildStatCards(bool narrow) {
    final int incompleteStarCount =
        ExperienceStarValidator.issuesFor(experiences).length;
    final List<Widget> cards = [
      _StatCard(
        label: "경험 정리",
        value: experiences.length,
        unit: "개",
        icon: Icons.inventory_2_outlined,
        color: AppColors.experience,
        tint: AppColors.experienceTint,
        onTap: () => onNavigate(AppRoutes.experience),
      ),
      _StatCard(
        label: "STAR 보완",
        value: incompleteStarCount,
        unit: "건",
        icon: Icons.warning_amber_outlined,
        color: AppColors.warning,
        tint: AppColors.warningTint,
        onTap: () => onNavigate(AppRoutes.experience),
      ),
      _StatCard(
        label: "마스터 자소서",
        value: savedEssayVersionCount,
        unit: "버전",
        icon: Icons.article_outlined,
        color: AppColors.master,
        tint: AppColors.masterTint,
        onTap: () => onNavigate(AppRoutes.masterResume),
      ),
      _StatCard(
        label: "포트폴리오 개요",
        value: portfolioProjects.length,
        unit: "개",
        icon: Icons.layers_outlined,
        color: AppColors.portfolio,
        tint: AppColors.portfolioTint,
        onTap: () => onNavigate(AppRoutes.portfolio),
      ),
      _StatCard(
        label: "면접 대비",
        value: interviewAnswerCount,
        unit: "답변",
        icon: Icons.record_voice_over_outlined,
        color: AppColors.coaching,
        tint: AppColors.coachingTint,
        onTap: () => onNavigate(AppRoutes.interview),
      ),
      _StatCard(
        label: "지원 관리",
        value: applicationRecords.length,
        unit: "곳",
        icon: Icons.work_outline,
        color: AppColors.application,
        tint: AppColors.applicationTint,
        onTap: () => onNavigate(AppRoutes.applications),
      ),
    ];

    // 6카드: 넓은 화면은 3+3, 좁은 화면은 2열.
    if (narrow) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: i + 2 < cards.length ? 14 : 0),
              child: Row(
                children: [
                  Expanded(child: cards[i]),
                  const SizedBox(width: 14),
                  Expanded(child: i + 1 < cards.length ? cards[i + 1] : const SizedBox.shrink()),
                ],
              ),
            ),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (int i = 3; i < 6; i++) ...[
              if (i > 3) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMidRow(bool narrow) {
    final Widget left = _buildContinueCard();
    final Widget right = _buildCoachingCard();
    if (narrow) {
      return Column(children: [left, const SizedBox(height: 20), right]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 3, child: left),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: right),
        ],
      ),
    );
  }

  Widget _buildContinueCard() {
    final int incompleteStarCount =
        ExperienceStarValidator.issuesFor(experiences).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "이어서 작업하기",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
          const SizedBox(height: 14),
          _QuickAction(
            icon: Icons.add_box_outlined,
            color: AppColors.experience,
            tint: AppColors.experienceTint,
            title: "새 경험 정리",
            onTap: () => onNavigate(AppRoutes.experience),
          ),
          if (incompleteStarCount > 0) ...[
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.warning_amber_outlined,
              color: AppColors.warning,
              tint: AppColors.warningTint,
              title: "STAR 보완 ($incompleteStarCount)",
              onTap: () => onNavigate(AppRoutes.experience),
            ),
          ],
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.edit_note_outlined,
            color: AppColors.master,
            tint: AppColors.masterTint,
            title: "마스터 자소서",
            onTap: () => onNavigate(AppRoutes.masterResume),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.record_voice_over_outlined,
            color: AppColors.coaching,
            tint: AppColors.coachingTint,
            title: "면접 대비",
            onTap: () => onNavigate(AppRoutes.interview),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.dashboard_customize_outlined,
            color: AppColors.portfolio,
            tint: AppColors.portfolioTint,
            title: "포트폴리오 개요",
            onTap: () => onNavigate(AppRoutes.portfolio),
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.work_outline,
            color: AppColors.application,
            tint: AppColors.applicationTint,
            title: "지원 관리",
            onTap: () => onNavigate(AppRoutes.applications),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachingCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D28D9), Color(0xFF4F46E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 16),
                const Text(
                  "AI 커리어 코칭",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.coaching,
              ),
              onPressed: () => onNavigate(AppRoutes.interview),
              child: const Text("면접 코칭 시작"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExperiences(BuildContext context) {
    final List<Experience> recent = [...experiences]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final List<Experience> top = recent.take(4).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "최근 경험 카드",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(AppRoutes.experience),
                child: const Text("전체 보기"),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 34, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 10),
                  Text(
                    "아직 저장된 경험이 없습니다.".softWrapWords(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
                  ),
                ],
              ),
            )
          else
            for (int i = 0; i < top.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.outlineVariant),
              _RecentExperienceRow(
                experience: top[i],
                onTap: () => onNavigate(AppRoutes.experience),
              ),
            ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final int value;
  final String unit;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AccentIconChip(icon: icon, color: color, tint: tint, size: 38),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$value",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        unit,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                      ),
                    ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AccentIconChip(icon: icon, color: color, tint: tint, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentExperienceRow extends StatelessWidget {
  const _RecentExperienceRow({required this.experience, required this.onTap});

  final Experience experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String meta = [
      if (experience.organization.trim().isNotEmpty) experience.organization.trim(),
      if (experience.period.displayText.isNotEmpty) experience.period.displayText,
    ].join(" · ");
    final List<String> tags = experience.competencyTags.take(3).toList();
    final List<String> starGaps = ExperienceStarValidator.missingMessages(experience);

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              const AccentIconChip(
                icon: Icons.inventory_2_outlined,
                color: AppColors.experience,
                tint: AppColors.experienceTint,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            experience.title.softWrapWords(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (starGaps.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const StatusPill(
                            label: 'STAR 보완',
                            icon: Icons.warning_amber_outlined,
                            color: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta.softWrapWords(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [for (final String t in tags) AppTag(t)],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
