import 'package:chatgptmini/domain/models/experience.dart';

/// 경험 카드 STAR 필수 항목(상황·행동) 보완 안내.
class ExperienceStarIssue {
  const ExperienceStarIssue({
    required this.experienceId,
    required this.title,
    required this.messages,
  });

  final String experienceId;
  final String title;
  final List<String> messages;
}

class ExperienceStarValidator {
  const ExperienceStarValidator._();

  /// 단일 경험의 보완 메시지. 비어 있으면 통과.
  static List<String> missingMessages(Experience experience) {
    final List<String> messages = [];
    if (experience.title.trim().isEmpty) {
      messages.add('제목이 비어 있습니다.');
    }
    if (experience.situation.trim().isEmpty) {
      messages.add('상황(S)이 비어 있습니다.');
    }
    if (experience.action.trim().isEmpty) {
      messages.add('행동(A)이 비어 있습니다.');
    }
    return messages;
  }

  static List<ExperienceStarIssue> issuesFor(List<Experience> experiences) {
    final List<ExperienceStarIssue> issues = [];
    for (final Experience experience in experiences) {
      final List<String> messages = missingMessages(experience);
      if (messages.isEmpty) {
        continue;
      }
      issues.add(
        ExperienceStarIssue(
          experienceId: experience.id,
          title: experience.title.trim().isEmpty ? '(제목 없음)' : experience.title.trim(),
          messages: messages,
        ),
      );
    }
    return issues;
  }

  static bool hasBlockingGaps(List<Experience> experiences) {
    return issuesFor(experiences).isNotEmpty;
  }
}
