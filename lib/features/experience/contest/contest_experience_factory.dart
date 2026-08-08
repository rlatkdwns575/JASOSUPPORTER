import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// 수상·공모전 입력 값을 Experience로 조립한다.
abstract final class ContestExperienceFactory {
  static String _join(List<String> parts) {
    return parts
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .join(' · ');
  }

  static List<String> _links(String raw) {
    return raw
        .split(RegExp(r'[\s,;]+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static Experience award({
    required String eventName,
    String organizer = '',
    String awardResult = '',
    String role = '',
    DateTime? start,
    DateTime? end,
    String situation = '',
    String task = '',
    String action = '',
    String result = '',
    String learned = '',
    List<String> competencyTags = const <String>[],
    List<String> evidenceLinks = const <String>[],
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String title =
        eventName.trim().isEmpty ? '수상' : eventName.trim();
    final String org =
        organizer.trim().isNotEmpty ? organizer.trim() : title;
    final String starResult = result.trim().isNotEmpty
        ? result.trim()
        : awardResult.trim();
    return Experience(
      id: 'contest_award_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.contest,
      period: DateRange(start: start, end: end),
      organization: org,
      role: _join(<String>[role, awardResult]),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: starResult,
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static Experience contestEntry({
    required String contestName,
    String organizer = '',
    String participation = '',
    String role = '',
    String outcome = '',
    String evidenceRaw = '',
    DateTime? start,
    DateTime? end,
    String situation = '',
    String task = '',
    String action = '',
    String result = '',
    String learned = '',
    List<String> competencyTags = const <String>[],
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String title =
        contestName.trim().isEmpty ? '공모전' : contestName.trim();
    final String org =
        organizer.trim().isNotEmpty ? organizer.trim() : title;
    final String starResult =
        result.trim().isNotEmpty ? result.trim() : outcome.trim();
    return Experience(
      id: 'contest_entry_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.contest,
      period: DateRange(start: start, end: end),
      organization: org,
      role: _join(<String>[participation, role]),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: starResult,
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: _links(evidenceRaw),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
