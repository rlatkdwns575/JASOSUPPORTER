import 'package:chatgptmini/core/config/app_config.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:flutter/material.dart';

/// S01 설정. 서버 API·데이터 내보내기·개인정보(RAG) 안내.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.experienceCount = 0,
    this.specCount = 0,
    this.interviewAnswerCount = 0,
    this.onExportExperiences,
  });

  final int experienceCount;
  final int specCount;
  final int interviewAnswerCount;
  final VoidCallback? onExportExperiences;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "설정",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onSurface),
              ),
              const SizedBox(height: 22),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: "백엔드 연결",
                      icon: Icons.cloud_outlined,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: "API Base URL", value: AppConfig.apiBaseUrl),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    const _InfoRow(
                      label: "API 키",
                      value: "클라이언트에 노출하지 않습니다.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: "데이터",
                      icon: Icons.storage_outlined,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: "경험 카드", value: "$experienceCount개"),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(label: "스펙", value: "$specCount개"),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(label: "면접 답변", value: "$interviewAnswerCount개"),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: onExportExperiences,
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text("경험·스펙 합본 내보내기"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                backgroundColor: AppColors.coachingTint.withValues(alpha: 0.55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: "개인정보·RAG",
                      icon: Icons.privacy_tip_outlined,
                      accent: AppColors.coaching,
                      accentTint: AppColors.surface,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "벡터DB에는 Experience 요약만 올립니다. AI는 선택한 경험만 근거로 답합니다."
                          .softWrapWords(),
                      style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(title: "앱 정보", icon: Icons.info_outline),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: "JasoSupporter",
                      value: "취업 준비 워크스페이스",
                    ),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    const _InfoRow(label: "테마", value: "블루 계열 Material 3 / ProductSans"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13.5, color: AppColors.onSurfaceVariant, height: 1.4),
          ),
        ),
      ],
    );
  }
}
