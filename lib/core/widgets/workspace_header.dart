import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:flutter/material.dart';

/// 워크스페이스 공통 상단 헤더.
class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.savedExperienceCount,
    required this.isGenerating,
  });

  final String title;
  final String subtitle;
  final int savedExperienceCount;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle.softWrapWords(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          StatusPill(
            label: '저장 경험 $savedExperienceCount개',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: isGenerating ? 'AI 작성 중' : '작업 가능',
            icon: isGenerating ? Icons.auto_awesome : Icons.check_circle_outline,
            color: isGenerating ? AppColors.aiAccent : AppColors.success,
          ),
        ],
      ),
    );
  }
}
