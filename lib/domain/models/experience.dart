import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';

class Experience {
  const Experience({
    required this.id,
    required this.title,
    required this.type,
    required this.period,
    required this.organization,
    required this.role,
    required this.situation,
    required this.task,
    required this.action,
    required this.result,
    required this.learned,
    required this.techStacks,
    required this.competencyTags,
    required this.evidenceLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final ExperienceType type;
  final DateRange period;
  final String organization;
  final String role;
  final String situation;
  final String task;
  final String action;
  final String result;
  final String learned;
  final List<String> techStacks;
  final List<String> competencyTags;
  final List<String> evidenceLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Experience.fromJson(Map<String, Object?> json) {
    return Experience(
      id: _string(json["id"]),
      title: _string(json["title"]),
      type: _experienceType(json["type"]),
      period: json["period"] is Map<String, Object?>
          ? DateRange.fromJson(json["period"] as Map<String, Object?>)
          : const DateRange(),
      organization: _string(json["organization"]),
      role: _string(json["role"]),
      situation: _string(json["situation"]),
      task: _string(json["task"]),
      action: _string(json["action"]),
      result: _string(json["result"]),
      learned: _string(json["learned"]),
      techStacks: _stringList(json["techStacks"]),
      competencyTags: _stringList(json["competencyTags"]),
      evidenceLinks: _stringList(json["evidenceLinks"]),
      createdAt: _date(json["createdAt"]),
      updatedAt: _date(json["updatedAt"]),
    );
  }

  bool get hasStarContent {
    return situation.trim().isNotEmpty ||
        task.trim().isNotEmpty ||
        action.trim().isNotEmpty ||
        result.trim().isNotEmpty ||
        learned.trim().isNotEmpty;
  }

  Experience copyWith({
    String? id,
    String? title,
    ExperienceType? type,
    DateRange? period,
    String? organization,
    String? role,
    String? situation,
    String? task,
    String? action,
    String? result,
    String? learned,
    List<String>? techStacks,
    List<String>? competencyTags,
    List<String>? evidenceLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Experience(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      period: period ?? this.period,
      organization: organization ?? this.organization,
      role: role ?? this.role,
      situation: situation ?? this.situation,
      task: task ?? this.task,
      action: action ?? this.action,
      result: result ?? this.result,
      learned: learned ?? this.learned,
      techStacks: techStacks ?? this.techStacks,
      competencyTags: competencyTags ?? this.competencyTags,
      evidenceLinks: evidenceLinks ?? this.evidenceLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "title": title,
      "type": type.name,
      "period": period.toJson(),
      "organization": organization,
      "role": role,
      "situation": situation,
      "task": task,
      "action": action,
      "result": result,
      "learned": learned,
      "techStacks": techStacks,
      "competencyTags": competencyTags,
      "evidenceLinks": evidenceLinks,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  static String _string(Object? value) => value is String ? value : "";

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList(growable: false);
  }

  static DateTime _date(Object? value) {
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static ExperienceType _experienceType(Object? value) {
    if (value is String) {
      for (final ExperienceType type in ExperienceType.values) {
        if (type.name == value) {
          return type;
        }
      }
    }
    return ExperienceType.other;
  }
}
