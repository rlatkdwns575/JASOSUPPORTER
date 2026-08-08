import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// 교외활동 입력 값을 Experience로 조립한다.
abstract final class ExternalExperienceFactory {
  static List<String> _techStacks(String raw) {
    return raw
        .split(RegExp(r'[,/·|]'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _links(String raw) {
    return raw
        .split(RegExp(r'[\s,;]+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static Experience internship({
    required String companyName,
    String department = '',
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
        companyName.trim().isEmpty ? '인턴십' : companyName.trim();
    return Experience(
      id: 'external_intern_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.internship,
      period: DateRange(start: start, end: end),
      organization: department.trim().isNotEmpty ? department.trim() : title,
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

  static Experience bootcamp({
    required String programName,
    String operator = '',
    String track = '',
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
        programName.trim().isEmpty ? '부트캠프' : programName.trim();
    return Experience(
      id: 'external_bootcamp_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.bootcamp,
      period: DateRange(start: start, end: end),
      organization: operator.trim().isNotEmpty ? operator.trim() : title,
      role: track.trim(),
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

  static Experience externalProject({
    required String projectName,
    String teamOrClient = '',
    String role = '',
    String techStackRaw = '',
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
        projectName.trim().isEmpty ? '외부 프로젝트' : projectName.trim();
    return Experience(
      id: 'external_project_${stamp.microsecondsSinceEpoch}',
      title: title,
      type: ExperienceType.project,
      period: DateRange(start: start, end: end),
      organization:
          teamOrClient.trim().isNotEmpty ? teamOrClient.trim() : title,
      role: role.trim(),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: _techStacks(techStackRaw),
      competencyTags: competencyTags,
      evidenceLinks: _links(evidenceRaw),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
