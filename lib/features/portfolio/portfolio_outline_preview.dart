import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:flutter/material.dart';

/// P03 포트폴리오 개요 미리보기.
class PortfolioOutlinePreviewPanel extends StatelessWidget {
  const PortfolioOutlinePreviewPanel({
    super.key,
    required this.project,
    required this.enabled,
    required this.onEdit,
    required this.onBack,
    required this.onRequestPolish,
  });

  final PortfolioProject project;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onBack;
  final VoidCallback onRequestPolish;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = project.portfolioCopy
        .split('\n')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);
    final String positioning = lines.isNotEmpty ? lines.first : '(포지셔닝 미입력)';
    final List<String> bullets = lines.length > 1 ? lines.skip(1).toList() : const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const Expanded(
              child: Text(
                '개요 미리보기',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: enabled ? onEdit : null,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('편집'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                positioning.softWrapWords(),
                style: const TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.onSurface),
              ),
              if (project.role.trim().isNotEmpty || project.result.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                if (project.role.trim().isNotEmpty)
                  Text('역할: ${project.role.trim()}', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                if (project.result.trim().isNotEmpty)
                  Text('결과: ${project.result.trim()}', style: const TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: '목차·섹션 불릿',
                icon: Icons.list_alt_outlined,
                accent: AppColors.portfolio,
                accentTint: AppColors.portfolioTint,
              ),
              const SizedBox(height: 10),
              if (bullets.isEmpty)
                const Text('(섹션 불릿 미입력)', style: TextStyle(color: AppColors.onSurfaceVariant))
              else
                for (final String bullet in bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      bullet.startsWith('-') || bullet.startsWith('•') ? bullet : '• $bullet',
                      style: const TextStyle(fontSize: 13.5, height: 1.4),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: enabled ? onRequestPolish : null,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('개요 첨삭 요청'),
          ),
        ),
      ],
    );
  }
}
