import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// 기타 경험 입력 값을 Experience로 조립한다.
abstract final class OtherExperienceFactory {
  static String _join(List<String> parts) {
    return parts
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .join(' · ');
  }

  static Experience partTime({
    required String workplaceOrDuty,
    String workplace = '',
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
    final String title = workplaceOrDuty.trim().isEmpty
        ? '아르바이트'
        : workplaceOrDuty.trim();
    final String org =
        workplace.trim().isNotEmpty ? workplace.trim() : title;
    return Experience(
      id: 'other_parttime_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.partTime,
      period: DateRange(start: start, end: end),
      organization: org,
      role: role.trim(),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static Experience military({
    required String serviceType,
    String unit = '',
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
    final String title = serviceType.trim().isEmpty
        ? '군 복무'
        : serviceType.trim();
    final String org = unit.trim().isNotEmpty ? unit.trim() : title;
    return Experience(
      id: 'other_military_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.other,
      period: DateRange(start: start, end: end),
      organization: org,
      role: role.trim(),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static Experience personal({
    required String experienceTitle,
    String context = '',
    String organization = '',
    String memo = '',
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
    final String title = experienceTitle.trim().isEmpty
        ? '개인적 경험'
        : experienceTitle.trim();
    final String org =
        organization.trim().isNotEmpty ? organization.trim() : title;
    final String learnedBody = learned.trim();
    final String memoBody = memo.trim();
    final String composedLearned = memoBody.isEmpty
        ? learnedBody
        : (learnedBody.isEmpty
            ? memoBody
            : _join(<String>[learnedBody, '메모: $memoBody']));
    return Experience(
      id: 'other_personal_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.other,
      period: DateRange(start: start, end: end),
      organization: org,
      role: context.trim(),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: composedLearned,
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
