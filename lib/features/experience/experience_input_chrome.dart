import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 경험·스펙 입력 화면 공통 크롬 (헤더 · 뒤로가기 · 본문 · 저장).
class ExperienceInputChrome extends StatelessWidget {
  const ExperienceInputChrome({
    super.key,
    required this.title,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.onBack,
    required this.backLabel,
    required this.form,
    required this.onSubmit,
    required this.submitLabel,
    this.enabled = true,
    this.saving = false,
  });

  final String title;
  final String categoryLabel;
  final IconData categoryIcon;
  final VoidCallback? onBack;
  final String backLabel;
  final Widget form;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final bool enabled;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final bool canEdit = enabled && !saving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: backLabel,
                    onPressed: canEdit ? onBack : null,
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
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              categoryIcon,
                              size: 14,
                              color: AppColors.experience,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              categoryLabel,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.experience,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.experience,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    onPressed: canEdit ? onSubmit : null,
                    child: Text(saving ? '저장 중…' : submitLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: IgnorePointer(
                ignoring: !canEdit,
                child: Opacity(
                  opacity: canEdit ? 1 : 0.55,
                  child: form,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
