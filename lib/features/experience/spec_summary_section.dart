import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter/material.dart';

/// Figma `Experience — Spec Summary Flow`의 스펙 요약 섹션.
class SpecSummarySection extends StatelessWidget {
  const SpecSummarySection({
    super.key,
    required this.items,
    this.onAdd,
    this.onDelete,
    this.compact = false,
    this.title = "스펙",
    this.subtitle = "",
    this.wrapInCard = true,
  });

  final List<SpecItem> items;
  final VoidCallback? onAdd;
  final ValueChanged<SpecItem>? onDelete;
  final bool compact;
  final String title;
  final String subtitle;

  /// false면 카드 래퍼 없이 내용만 (저장된 경험 카드 패널용).
  final bool wrapInCard;

  List<SpecItem> get _visible {
    return items
        .where(
          (SpecItem s) =>
              s.type == SpecItemType.school ||
              s.type == SpecItemType.certificate ||
              s.type == SpecItemType.major ||
              s.type == SpecItemType.language ||
              s.type == SpecItemType.gpa ||
              s.type == SpecItemType.other,
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<SpecItem> list = _visible;
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle.softWrapWords(),
              style: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant, height: 1.35),
            ),
          ],
          const SizedBox(height: 14),
        ],
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: compact ? 12 : 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              "저장된 스펙이 없습니다.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.onSurfaceVariant),
            ),
          )
        else
          for (int i = 0; i < list.length; i++) ...[
            if (i > 0) SizedBox(height: compact ? 6 : 8),
            _SpecSummaryTile(
              item: list[i],
              compact: compact,
              onDelete: onDelete == null ? null : () => onDelete!(list[i]),
            ),
          ],
        if (onAdd != null) ...[
          SizedBox(height: compact ? 8 : 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                foregroundColor: AppColors.experience,
                backgroundColor: AppColors.experienceTint,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 14,
                  vertical: compact ? 8 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onAdd,
              child: Text(list.isEmpty ? '+ 스펙 추가하기' : '+ 스펙 더 추가하기'),
            ),
          ),
        ],
      ],
    );

    if (!wrapInCard) {
      return body;
    }

    return AppCard(
      elevated: false,
      borderColor: AppColors.outlineVariant,
      padding: EdgeInsets.fromLTRB(18, compact ? 12 : 16, 18, compact ? 12 : 16),
      child: body,
    );
  }
}

class _SpecSummaryTile extends StatelessWidget {
  const _SpecSummaryTile({
    required this.item,
    required this.compact,
    this.onDelete,
  });

  final SpecItem item;
  final bool compact;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isCert = item.type == SpecItemType.certificate;
    final String badge = isCert ? "자격증" : item.title;
    final String body = isCert
        ? (item.issuedAt.trim().isEmpty
            ? item.title
            : "${item.title}  ·  취득 ${item.issuedAt.trim()}")
        : item.value;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$badge  ·  $body".softWrapWords(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.35,
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: "삭제",
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 16, color: AppColors.onSurfaceVariant),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, onDelete == null ? 12 : 4, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.experienceTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.experience,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body.softWrapWords(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: "삭제",
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            ),
        ],
      ),
    );
  }
}
