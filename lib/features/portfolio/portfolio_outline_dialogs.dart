import 'package:chatgptmini/domain/models/career_artifacts.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/portfolio/portfolio_outline_editor.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 개요 편집 다이얼로그.
class PortfolioOutlineDialogs {
  const PortfolioOutlineDialogs._();

  static Future<void> showEdit({
    required BuildContext context,
    required PortfolioProject project,
    required Future<void> Function(PortfolioProject next) onSave,
    List<Experience> availableExperiences = const <Experience>[],
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return PortfolioOutlineEditor(
          initial: project,
          onSave: onSave,
          availableExperiences: availableExperiences,
        );
      },
    );
  }
}
