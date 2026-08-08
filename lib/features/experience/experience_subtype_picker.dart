import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 카테고리 안 세부 유형 선택.
class ExperienceSubtypePicker extends StatelessWidget {
  const ExperienceSubtypePicker({
    super.key,
    required this.category,
    this.enabled = true,
  });

  final ExperienceCategory category;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final List<ExperienceSubtype> subtypes =
        ExperienceSubtypeCopy.forCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: '경험 정리로 돌아가기',
                onPressed:
                    enabled ? () => context.go(AppRoutes.experience) : null,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.experienceTint,
                  foregroundColor: AppColors.experience,
                ),
                icon: const Icon(Icons.arrow_back, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${category.title} 유형 선택',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final ExperienceSubtype subtype in subtypes) ...[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.md),
              onTap: !enabled
                  ? null
                  : () => context.go(
                        AppRoutes.experienceFormSubtype(
                          category.queryValue,
                          subtype.queryValue,
                        ),
                      ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    AccentIconChip(
                      icon: subtype.icon,
                      color: AppColors.experience,
                      tint: AppColors.experienceTint,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtype.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtype.subtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.outline),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
