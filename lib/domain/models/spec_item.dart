enum SpecItemType {
  school,
  major,
  gpa,
  certificate,
  language,
  other,
}

class SpecItem {
  const SpecItem({
    required this.id,
    required this.type,
    required this.title,
    required this.value,
    required this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final SpecItemType type;
  final String title;
  final String value;
  final String issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SpecItem.fromJson(Map<String, Object?> json) {
    return SpecItem(
      id: _string(json["id"]),
      type: _specItemType(json["type"]),
      title: _string(json["title"]),
      value: _string(json["value"]),
      issuedAt: _string(json["issuedAt"]),
      createdAt: _date(json["createdAt"]),
      updatedAt: _date(json["updatedAt"]),
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": id,
      "type": type.name,
      "title": title,
      "value": value,
      "issuedAt": issuedAt,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  static String _string(Object? value) => value is String ? value : "";

  static DateTime _date(Object? value) {
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static SpecItemType _specItemType(Object? value) {
    if (value is String) {
      for (final SpecItemType type in SpecItemType.values) {
        if (type.name == value) {
          return type;
        }
      }
    }
    return SpecItemType.other;
  }
}
