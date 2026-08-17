import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/data/providers/backend_health_provider.dart';
import 'package:chatgptmini/domain/models/backend_health.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `/health` 기반 홈·설정 상단 경고 배너.
class BackendHealthBanner extends ConsumerWidget {
  const BackendHealthBanner({
    super.key,
    this.onOpenSettings,
  });

  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BackendHealth> health = ref.watch(backendHealthProvider);
    final String? message = health.when(
      loading: () => null,
      error: (_, __) => backendHealthBannerMessage(hasError: true),
      data: (BackendHealth data) => backendHealthBannerMessage(health: data),
    );
    if (message == null) {
      return const SizedBox.shrink();
    }

    final bool isError = health.hasError;
    final Color color = isError ? AppColors.error : AppColors.warning;
    final Color tint = isError ? const Color(0xFFFEF2F2) : AppColors.warningTint;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: tint,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError ? Icons.cloud_off_outlined : Icons.warning_amber_outlined,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message.softWrapWords(),
                  style: TextStyle(fontSize: 13, height: 1.45, color: color),
                ),
              ),
              TextButton(
                onPressed: onOpenSettings ?? () {},
                child: const Text('설정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? backendHealthBannerMessage({
  BackendHealth? health,
  bool hasError = false,
}) {
  if (hasError) {
    return '백엔드에 연결할 수 없습니다. 서버가 실행 중인지 확인해 주세요.';
  }
  if (health == null) {
    return null;
  }
  if (health.pineconeDimensionMismatch) {
    return 'Pinecone 인덱스 차원과 EMBEDDING_DIMENSION이 일치하지 않습니다. '
        'RAG가 로컬 폴백으로 동작합니다.';
  }
  if (!health.geminiEnabled) {
    return 'Gemini API 키가 설정되지 않았습니다. AI 생성 기능을 사용할 수 없습니다.';
  }
  return null;
}

/// 설정 화면으로 이동할 때 사용하는 기본 경로.
String get backendHealthSettingsRoute => AppRoutes.settings;
