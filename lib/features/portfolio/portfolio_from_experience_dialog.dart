import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/core/widgets/experience_star_preview.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/portfolio/portfolio_project_factory.dart';
import 'package:flutter/material.dart';

/// Experience → 포트폴리오 개요 변환 전 STAR·매핑 확인.
class PortfolioFromExperienceDialog {
  const PortfolioFromExperienceDialog._();

  static Future<bool> confirm({
    required BuildContext context,
    required Experience experience,
  }) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('포트폴리오 개요로 변환'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 14),
                  const Text(
                    '원본 STAR',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    backgroundColor: AppColors.surfaceContainerLow,
                    child: ExperienceStarPreview(
                      experience: experience,
                      compact: true,
                      accent: AppColors.portfolio,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '변환 매핑',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                      '상황 → 문제 정의',
                      '행동 → 해결/구현',
                      '성과 → 결과',
                      '과제·배운 점 → 개요 메모에 포함',
                      '역할·기술·증빙 → 그대로 복사',
                    ].join('\n').softWrapWords(),
                    style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '미리보기 제목: ${PortfolioProjectFactory.previewTitle(experience)}'
                        .softWrapWords(),
                    style: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.portfolio),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('변환 후 저장'),
            ),
          ],
        );
      },
    );
    return ok == true;
  }
}
