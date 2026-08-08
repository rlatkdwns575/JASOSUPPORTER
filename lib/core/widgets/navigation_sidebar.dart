import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/core/widgets/app_brand_mark.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 사이드바 네비게이션 항목 정의.
class NavDestinationSpec {
  const NavDestinationSpec({
    required this.path,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String path;
  final String label;
  final IconData icon;
  final Color accent;
}

/// 앱 좌측 고정 네비게이션 사이드바.
///
/// [location]으로 활성 항목을 판별하고, 선택 시 [onSelect]로 경로를 전달한다.
/// [compact]이면 아이콘만 노출하는 좁은 레일로 렌더한다.
class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({
    super.key,
    required this.location,
    required this.onSelect,
    this.compact = false,
  });

  final String location;
  final ValueChanged<String> onSelect;
  final bool compact;

  static const List<NavDestinationSpec> primaryItems = [
    NavDestinationSpec(
      path: AppRoutes.home,
      label: '홈',
      icon: Icons.dashboard_outlined,
      accent: AppColors.primary,
    ),
    NavDestinationSpec(
      path: AppRoutes.experience,
      label: '경험 정리',
      icon: Icons.inventory_2_outlined,
      accent: AppColors.experience,
    ),
    NavDestinationSpec(
      path: AppRoutes.masterResume,
      label: '마스터 자소서',
      icon: Icons.article_outlined,
      accent: AppColors.master,
    ),
    NavDestinationSpec(
      path: AppRoutes.portfolio,
      label: '포트폴리오 개요',
      icon: Icons.layers_outlined,
      accent: AppColors.portfolio,
    ),
    NavDestinationSpec(
      path: AppRoutes.interview,
      label: '면접 대비',
      icon: Icons.record_voice_over_outlined,
      accent: AppColors.coaching,
    ),
    NavDestinationSpec(
      path: AppRoutes.applications,
      label: '지원 관리',
      icon: Icons.work_outline,
      accent: AppColors.application,
    ),
  ];

  static const NavDestinationSpec settingsItem = NavDestinationSpec(
    path: AppRoutes.settings,
    label: '설정',
    icon: Icons.settings_outlined,
    accent: AppColors.onSurfaceVariant,
  );

  bool _isActive(String path) {
    if (path == AppRoutes.home) {
      return location == AppRoutes.home || location == '/';
    }
    return location.startsWith(path);
  }

  @override
  Widget build(BuildContext context) {
    final double width = compact ? 72 : 240;
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogo(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
              children: [
                if (!compact)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Text(
                      "워크스페이스",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                for (final NavDestinationSpec item in primaryItems)
                  _NavTile(
                    item: item,
                    active: _isActive(item.path),
                    compact: compact,
                    onTap: () => onSelect(item.path),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: 8),
            child: _NavTile(
              item: settingsItem,
              active: _isActive(settingsItem.path),
              compact: compact,
              onTap: () => onSelect(settingsItem.path),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 0 : 20, 20, compact ? 0 : 20, 12),
      child: Row(
        mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: AppBrandMark(size: 20)),
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "JasoSupporter",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final NavDestinationSpec item;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? item.accent : AppColors.onSurfaceVariant;
    final Widget tile = Material(
      color: active ? item.accent.withValues(alpha: 0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.surfaceContainer,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12, vertical: 11),
          child: Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(item.icon, size: 20, color: fg),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: compact ? Tooltip(message: item.label, child: tile) : tile,
    );
  }
}
