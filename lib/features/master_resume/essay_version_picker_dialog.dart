import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:flutter/material.dart';

/// 저장된 자소서 버전 선택 다이얼로그.
class EssayVersionPickerDialog {
  const EssayVersionPickerDialog._();

  static Future<EssayVersion?> show({
    required BuildContext context,
    required List<EssayVersion> versions,
  }) {
    final List<EssayVersion> sorted = [...versions]
      ..sort((EssayVersion a, EssayVersion b) => b.createdAt.compareTo(a.createdAt));
    return showDialog<EssayVersion>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text('저장된 버전 불러오기'),
          content: SizedBox(
            width: 520,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext itemCtx, int index) {
                final EssayVersion version = sorted[index];
                final String preview = version.body.length > 80
                    ? '${version.body.substring(0, 80)}...'
                    : version.body;
                return ListTile(
                  title: Text(
                    _formatDateTime(version.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      if (version.sourceExperienceIds.isNotEmpty)
                        '연결 경험: ${version.sourceExperienceIds.join(', ')}',
                      preview,
                    ].join('\n').softWrapWords(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(ctx).pop(version),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  static String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}.${two(value.month)}.${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
