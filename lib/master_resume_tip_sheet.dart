import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/jaso_constants.dart';
import 'package:flutter/material.dart';

/// 작성 팁 패널에 넣을 내용.
class MasterResumeTipContent {
  const MasterResumeTipContent({
    required this.badge,
    required this.headline,
    required this.hook,
    required this.sections,
    required this.checklist,
  });

  final String badge;
  final String headline;
  final String hook;
  final List<({String heading, String body})> sections;
  final List<String> checklist;

  factory MasterResumeTipContent.forQuestion(MasterQuestionCopy q) {
    return MasterResumeTipContent(
      badge: q.id,
      headline: "${q.id} 작성 가이드",
      hook: q.tipHook,
      sections: q.tipSections,
      checklist: q.tipChecklist,
    );
  }

  factory MasterResumeTipContent.fullReview() {
    return MasterResumeTipContent(
      badge: "첨삭",
      headline: "전체 초고 첨삭",
      hook: MasterFullReviewTipCopy.hook,
      sections: MasterFullReviewTipCopy.sections,
      checklist: MasterFullReviewTipCopy.checklist,
    );
  }
}

/// 마스터 자소서 왼쪽 패널 위에 겹치는 팁( Navigator 미사용 → 입력 차단 없음).
class MasterResumeTipPanel extends StatelessWidget {
  const MasterResumeTipPanel({
    super.key,
    required this.content,
    required this.onClose,
  });

  final MasterResumeTipContent content;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black45,
      surfaceTintColor: Colors.transparent,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    content.badge,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimaryContainer,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: "닫기",
                  visualDensity: VisualDensity.compact,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              content.headline,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.4,
                color: AppColors.primary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "한 줄 요약",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.hook,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "이렇게 써 보세요",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < content.sections.length; i++) ...[
                      if (i > 0) const SizedBox(height: 18),
                      _SectionBlock(
                        index: i + 1,
                        heading: content.sections[i].heading,
                        body: content.sections[i].body,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.fact_check_outlined, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                "작성 전 체크",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (int j = 0; j < content.checklist.length; j++) ...[
                            if (j > 0) const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    content.checklist[j],
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      height: 1.5,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "오른쪽에 붙어 있어 왼쪽 작성 칸을 가리지 않습니다. 닫기는 X 또는 아래 버튼.",
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              onPressed: onClose,
              child: const Text("닫기"),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.index,
    required this.heading,
    required this.body,
  });

  final int index;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "$index.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primary.withValues(alpha: 0.85),
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                heading,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.58,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
