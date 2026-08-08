import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// 교내활동 입력 값을 Experience로 조립한다.
abstract final class CampusExperienceFactory {
  static List<String> _techStacks(String raw) {
    return raw
        .split(RegExp(r'[,/·|]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static String _join(List<String> parts) {
    return parts
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .join(' · ');
  }

  static Experience club({
    required String clubName,
    String affiliation = '',
    String role = '',
    String scale = '',
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
        clubName.trim().isEmpty ? '동아리 경험' : clubName.trim();
    return Experience(
      id: 'campus_club_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.club,
      period: DateRange(start: start, end: end),
      organization: affiliation.trim().isNotEmpty ? affiliation.trim() : title,
      role: _join(<String>[role, scale]),
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

  static Experience lab({
    required String labName,
    String professor = '',
    String role = '',
    String researchTopic = '',
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
        labName.trim().isEmpty ? '연구실 경험' : labName.trim();
    final String situationBody = situation.trim();
    final String composedSituation = researchTopic.trim().isEmpty
        ? situationBody
        : (situationBody.isEmpty
            ? '연구 주제: ${researchTopic.trim()}'
            : '연구 주제: ${researchTopic.trim()}\n$situationBody');
    return Experience(
      id: 'campus_lab_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.campusActivity,
      period: DateRange(start: start, end: end),
      organization:
          professor.trim().isNotEmpty ? professor.trim() : title,
      role: role.trim(),
      situation: composedSituation,
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

  static Experience classProject({
    required String projectName,
    String courseName = '',
    String role = '',
    String techStackRaw = '',
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
        projectName.trim().isEmpty ? '수업 프로젝트' : projectName.trim();
    return Experience(
      id: 'campus_class_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.campusActivity,
      period: DateRange(start: start, end: end),
      organization:
          courseName.trim().isNotEmpty ? courseName.trim() : title,
      role: role.trim(),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: _techStacks(techStackRaw),
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
