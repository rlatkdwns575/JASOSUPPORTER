import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:flutter/material.dart';

/// 경험 카드 삭제 확인 다이얼로그.
class ExperienceDeleteDialog {
  const ExperienceDeleteDialog._();

  /// 삭제 확정이면 `true`.
  static Future<bool> confirm({
    required BuildContext context,
    required Experience experience,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Row(
            children: [
              AccentIconChip(
                icon: Icons.delete_outline,
                color: AppColors.error,
                tint: Color(0xFFFEE2E2),
                size: 36,
              ),
              SizedBox(width: 10),
              Text('경험 카드 삭제'),
            ],
          ),
          content: Text(
            "'${experience.title}' 카드를 삭제합니다.\n이미 저장된 자소서 버전의 sourceExperienceIds에는 id만 남을 수 있습니다."
                .softWrapWords(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }
}
