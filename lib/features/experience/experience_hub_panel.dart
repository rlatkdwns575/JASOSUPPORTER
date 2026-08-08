import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

/// Notion/Figma E01·E02 경험 카테고리.
enum ExperienceCategory {
  spec,
  campus,
  external,
  contest,
  global,
  other,
}

extension ExperienceCategoryCopy on ExperienceCategory {
  String get title => switch (this) {
        ExperienceCategory.spec => '스펙',
        ExperienceCategory.campus => '교내 활동',
        ExperienceCategory.external => '교외 활동',
        ExperienceCategory.contest => '수상·공모전',
        ExperienceCategory.global => '글로벌 경험',
        ExperienceCategory.other => '기타 경험',
      };

  String get subtitle => switch (this) {
        ExperienceCategory.spec => '학적·자격·어학·장학·봉사',
        ExperienceCategory.campus => '동아리·연구실·수업 프로젝트',
        ExperienceCategory.external => '인턴·부트캠프·외부 프로젝트',
        ExperienceCategory.contest => '수상·공모전',
        ExperienceCategory.global => '워홀·어학연수·교환학생',
        ExperienceCategory.other => '아르바이트·군·개인 경험',
      };

  IconData get icon => switch (this) {
        ExperienceCategory.spec => Icons.school_outlined,
        ExperienceCategory.campus => Icons.groups_outlined,
        ExperienceCategory.external => Icons.work_outline,
        ExperienceCategory.contest => Icons.emoji_events_outlined,
        ExperienceCategory.global => Icons.public_outlined,
        ExperienceCategory.other => Icons.more_horiz,
      };

  bool get opensSpecFlow => this == ExperienceCategory.spec;

  /// URL 쿼리 `?category=` 값.
  String get queryValue => name;

  static ExperienceCategory? fromQuery(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final String key = raw.trim().toLowerCase();
    for (final ExperienceCategory category in ExperienceCategory.values) {
      if (category.name.toLowerCase() == key) {
        return category;
      }
    }
    return null;
  }

  Set<ExperienceType> get experienceTypes => switch (this) {
        ExperienceCategory.spec => const {},
        ExperienceCategory.campus => {ExperienceType.club, ExperienceType.campusActivity},
        ExperienceCategory.external => {
            ExperienceType.internship,
            ExperienceType.bootcamp,
            ExperienceType.project,
          },
        ExperienceCategory.contest => {ExperienceType.contest},
        ExperienceCategory.global => {ExperienceType.trainingAbroad},
        ExperienceCategory.other => {
            ExperienceType.partTime,
            ExperienceType.other,
          },
      };

  int countIn(List<Experience> experiences) {
    final Set<ExperienceType> types = experienceTypes;
    if (types.isEmpty) {
      return 0;
    }
    return experiences.where((Experience e) => types.contains(e.type)).length;
  }
}

/// E01 경험 허브: 카테고리 카드 + 검색 + 최근 경험 + 추가 CTA.
class ExperienceHubPanel extends StatefulWidget {
  const ExperienceHubPanel({
    super.key,
    required this.experiences,
    required this.specCount,
    required this.onOpenCategory,
    required this.onOpenExperience,
  });

  final List<Experience> experiences;
  final int specCount;
  final ValueChanged<ExperienceCategory> onOpenCategory;
  final ValueChanged<Experience> onOpenExperience;

  @override
  State<ExperienceHubPanel> createState() => _ExperienceHubPanelState();
}

class _ExperienceHubPanelState extends State<ExperienceHubPanel> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Experience> _filtered() {
    final List<Experience> recent = [...widget.experiences]
      ..sort((Experience a, Experience b) => b.updatedAt.compareTo(a.updatedAt));
    final String q = _query.text.trim().toLowerCase();
    if (q.isEmpty) {
      return recent;
    }
    return recent.where((Experience e) {
      final String hay = [
        e.title,
        e.organization,
        e.role,
        e.situation,
        e.action,
        e.result,
        ...e.competencyTags,
        ...e.techStacks,
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<Experience> filtered = _filtered();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        const Text(
          '경험 정리',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final ExperienceCategory category in ExperienceCategory.values)
              SizedBox(
                width: 220,
                child: _CategoryCard(
                  category: category,
                  count: category.opensSpecFlow
                      ? widget.specCount
                      : category.countIn(widget.experiences),
                  countLabel: category.opensSpecFlow ? '스펙' : '경험',
                  onTap: () => widget.onOpenCategory(category),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        SectionHeader(
          title: '최근 경험 카드',
          icon: Icons.inventory_2_outlined,
          accent: AppColors.experience,
          accentTint: AppColors.experienceTint,
          trailing: StatusPill(
            label: '${widget.experiences.length}개',
            color: AppColors.experience,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _query,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '경험 검색',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _query.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '지우기',
                    onPressed: () {
                      _query.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear, size: 18),
                  ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.experiences.isEmpty)
          AppCard(
            child: Text(
              '아직 저장된 경험이 없습니다.',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          )
        else if (filtered.isEmpty)
          const AppCard(
            child: Text(
              '검색 결과가 없습니다.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          )
        else
          for (final Experience experience in filtered.take(12)) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                onTap: () => widget.onOpenExperience(experience),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.title.isEmpty ? '(제목 없음)' : experience.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (experience.organization.trim().isNotEmpty)
                            experience.organization.trim(),
                          if (experience.role.trim().isNotEmpty)
                            experience.role.trim(),
                          if (experience.period.displayText.isNotEmpty)
                            experience.period.displayText,
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (experience.competencyTags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final String tag
                                in experience.competencyTags.take(4))
                              Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: AppColors.experienceTint,
                              ),
                          ],
                        ),
                      ],
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.count,
    required this.countLabel,
  });

  final ExperienceCategory category;
  final VoidCallback onTap;
  final int count;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: AppCard(
          backgroundColor: AppColors.experienceTint.withValues(alpha: 0.45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccentIconChip(
                icon: category.icon,
                color: AppColors.experience,
                tint: AppColors.surface,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                category.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$countLabel $count개',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.experience,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
