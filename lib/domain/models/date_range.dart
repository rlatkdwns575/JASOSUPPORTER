class DateRange {
  const DateRange({
    this.start,
    this.end,
  });

  final DateTime? start;
  final DateTime? end;

  factory DateRange.fromJson(Map<String, Object?> json) {
    return DateRange(
      start: _parseDate(json["start"]),
      end: _parseDate(json["end"]),
    );
  }

  bool get isEmpty => start == null && end == null;

  String get displayText {
    final String startText = _formatYearMonth(start);
    final String endText = _formatYearMonth(end);
    if (startText.isEmpty && endText.isEmpty) {
      return "";
    }
    if (startText.isNotEmpty && endText.isNotEmpty) {
      return "$startText ~ $endText";
    }
    if (startText.isNotEmpty) {
      return "$startText ~";
    }
    return "~ $endText";
  }

  static String _formatYearMonth(DateTime? date) {
    if (date == null) {
      return "";
    }
    final String year = date.year.toString().padLeft(4, "0");
    final String month = date.month.toString().padLeft(2, "0");
    return "$year.$month";
  }

  Map<String, Object?> toJson() {
    return {
      "start": start?.toIso8601String(),
      "end": end?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
