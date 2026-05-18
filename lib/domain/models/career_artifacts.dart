class MasterEssay {
  const MasterEssay({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.targetJob,
    required this.linkedExperienceIds,
    required this.currentVersionId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String questionId;
  final String questionText;
  final String targetJob;
  final List<String> linkedExperienceIds;
  final String? currentVersionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MasterEssay.fromJson(Map<String, Object?> json) {
    return MasterEssay(
      id: _string(json["id"]),
      questionId: _string(json["questionId"]),
      questionText: _string(json["questionText"]),
      targetJob: _string(json["targetJob"]),
      linkedExperienceIds: _stringList(json["linkedExperienceIds"]),
      currentVersionId: json["currentVersionId"] is String ? json["currentVersionId"] as String : null,
      createdAt: _date(json["createdAt"]),
      updatedAt: _date(json["updatedAt"]),
    );
  }

  MasterEssay copyWith({
    String? id,
    String? questionId,
    String? questionText,
    String? targetJob,
    List<String>? linkedExperienceIds,
    String? currentVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MasterEssay(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      targetJob: targetJob ?? this.targetJob,
      linkedExperienceIds: linkedExperienceIds ?? this.linkedExperienceIds,
      currentVersionId: currentVersionId ?? this.currentVersionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "questionId": questionId,
      "questionText": questionText,
      "targetJob": targetJob,
      "linkedExperienceIds": linkedExperienceIds,
      "currentVersionId": currentVersionId,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class EssayVersion {
  const EssayVersion({
    required this.id,
    required this.masterEssayId,
    required this.body,
    required this.createdAt,
    required this.sourceExperienceIds,
  });

  final String id;
  final String masterEssayId;
  final String body;
  final DateTime createdAt;
  final List<String> sourceExperienceIds;

  factory EssayVersion.fromJson(Map<String, Object?> json) {
    return EssayVersion(
      id: _string(json["id"]),
      masterEssayId: _string(json["masterEssayId"]),
      body: _string(json["body"]),
      createdAt: _date(json["createdAt"]),
      sourceExperienceIds: _stringList(json["sourceExperienceIds"]),
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "masterEssayId": masterEssayId,
      "body": body,
      "createdAt": createdAt.toIso8601String(),
      "sourceExperienceIds": sourceExperienceIds,
    };
  }
}

String _string(Object? value) => value is String ? value : "";

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList(growable: false);
}

DateTime _date(Object? value) {
  if (value is String) {
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

class PortfolioProject {
  const PortfolioProject({
    required this.id,
    required this.title,
    required this.linkedExperienceIds,
    required this.role,
    required this.problem,
    required this.solution,
    required this.techStacks,
    required this.result,
    required this.evidenceLinks,
    required this.portfolioCopy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<String> linkedExperienceIds;
  final String role;
  final String problem;
  final String solution;
  final List<String> techStacks;
  final String result;
  final List<String> evidenceLinks;
  final String portfolioCopy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PortfolioProject.fromJson(Map<String, Object?> json) {
    return PortfolioProject(
      id: _string(json["id"]),
      title: _string(json["title"]),
      linkedExperienceIds: _stringList(json["linkedExperienceIds"]),
      role: _string(json["role"]),
      problem: _string(json["problem"]),
      solution: _string(json["solution"]),
      techStacks: _stringList(json["techStacks"]),
      result: _string(json["result"]),
      evidenceLinks: _stringList(json["evidenceLinks"]),
      portfolioCopy: _string(json["portfolioCopy"]),
      createdAt: _date(json["createdAt"]),
      updatedAt: _date(json["updatedAt"]),
    );
  }

  PortfolioProject copyWith({
    String? id,
    String? title,
    List<String>? linkedExperienceIds,
    String? role,
    String? problem,
    String? solution,
    List<String>? techStacks,
    String? result,
    List<String>? evidenceLinks,
    String? portfolioCopy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioProject(
      id: id ?? this.id,
      title: title ?? this.title,
      linkedExperienceIds: linkedExperienceIds ?? this.linkedExperienceIds,
      role: role ?? this.role,
      problem: problem ?? this.problem,
      solution: solution ?? this.solution,
      techStacks: techStacks ?? this.techStacks,
      result: result ?? this.result,
      evidenceLinks: evidenceLinks ?? this.evidenceLinks,
      portfolioCopy: portfolioCopy ?? this.portfolioCopy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "title": title,
      "linkedExperienceIds": linkedExperienceIds,
      "role": role,
      "problem": problem,
      "solution": solution,
      "techStacks": techStacks,
      "result": result,
      "evidenceLinks": evidenceLinks,
      "portfolioCopy": portfolioCopy,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class ApplicationRecord {
  const ApplicationRecord({
    required this.id,
    required this.companyName,
    required this.position,
    required this.status,
    required this.deadline,
    required this.linkedExperienceIds,
    required this.submittedEssayVersionIds,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyName;
  final String position;
  final String status;
  final DateTime? deadline;
  final List<String> linkedExperienceIds;
  final List<String> submittedEssayVersionIds;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ApplicationRecord.fromJson(Map<String, Object?> json) {
    return ApplicationRecord(
      id: _string(json["id"]),
      companyName: _string(json["companyName"]),
      position: _string(json["position"]),
      status: _string(json["status"]),
      deadline: _nullableDate(json["deadline"]),
      linkedExperienceIds: _stringList(json["linkedExperienceIds"]),
      submittedEssayVersionIds: _stringList(json["submittedEssayVersionIds"]),
      notes: _string(json["notes"]),
      createdAt: _date(json["createdAt"]),
      updatedAt: _date(json["updatedAt"]),
    );
  }

  ApplicationRecord copyWith({
    String? id,
    String? companyName,
    String? position,
    String? status,
    DateTime? deadline,
    List<String>? linkedExperienceIds,
    List<String>? submittedEssayVersionIds,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicationRecord(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      position: position ?? this.position,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      linkedExperienceIds: linkedExperienceIds ?? this.linkedExperienceIds,
      submittedEssayVersionIds: submittedEssayVersionIds ?? this.submittedEssayVersionIds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "companyName": companyName,
      "position": position,
      "status": status,
      "deadline": deadline?.toIso8601String(),
      "linkedExperienceIds": linkedExperienceIds,
      "submittedEssayVersionIds": submittedEssayVersionIds,
      "notes": notes,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

DateTime? _nullableDate(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
