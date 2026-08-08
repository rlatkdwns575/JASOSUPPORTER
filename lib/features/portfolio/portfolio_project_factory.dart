import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// Experience → 포트폴리오 개요 초안 변환.
class PortfolioProjectFactory {
  const PortfolioProjectFactory._();

  static String previewTitle(Experience experience) {
    final String title = experience.title.trim();
    return title.isEmpty ? '(제목 없음)' : title;
  }

  static PortfolioProject fromExperience(
    Experience experience, {
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    return PortfolioProject(
      id: 'portfolio_${experience.id}_${stamp.microsecondsSinceEpoch}',
      title: experience.title,
      linkedExperienceIds: [experience.id],
      role: experience.role,
      problem: experience.situation,
      solution: experience.action,
      techStacks: experience.techStacks,
      result: experience.result,
      evidenceLinks: experience.evidenceLinks,
      portfolioCopy: [
        if (experience.organization.trim().isNotEmpty)
          '소속/기관: ${experience.organization.trim()}',
        if (experience.role.trim().isNotEmpty) '역할: ${experience.role.trim()}',
        if (experience.task.trim().isNotEmpty) '과제: ${experience.task.trim()}',
        if (experience.action.trim().isNotEmpty)
          '핵심 수행: ${experience.action.trim()}',
        if (experience.result.trim().isNotEmpty) '성과: ${experience.result.trim()}',
        if (experience.learned.trim().isNotEmpty)
          '배운 점: ${experience.learned.trim()}',
      ].join('\n'),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
