import 'package:chatgptmini/domain/models/experience.dart';

/// AI 경험 매칭 추천 텍스트에서 Experience id를 추출한다.
abstract final class ExperienceMatchParser {
  static final RegExp _idLine = RegExp(
    r'(?:id\s*[:：]\s*|경험\s*id\s*[:：]\s*)([a-zA-Z0-9_\-]+)',
    caseSensitive: false,
  );
  static final RegExp _titleLine = RegExp(
    r'(?:title\s*[:：]\s*|제목\s*[:：]\s*)(.+)$',
    caseSensitive: false,
  );
  static final RegExp _bullet = RegExp(
    r'^\s*(?:(?:\d+)[\.\)]|[-*•·])\s*(.+)$',
  );

  static bool looksLikeMatch(String raw) {
    final String text = raw.trim();
    if (text.isEmpty) {
      return false;
    }
    if (_idLine.hasMatch(text)) {
      return true;
    }
    final String lower = text.toLowerCase();
    return lower.contains('추천') &&
        (lower.contains('경험') || lower.contains('experience'));
  }

  /// AI 답변과 저장된 경험을 매칭해 id 목록을 반환한다.
  static List<String> matchIds(
    String raw,
    List<Experience> experiences,
  ) {
    if (experiences.isEmpty || raw.trim().isEmpty) {
      return const <String>[];
    }
    final Set<String> knownIds = {
      for (final Experience e in experiences) e.id,
    };
    final Set<String> found = <String>{};

    for (final Match m in _idLine.allMatches(raw)) {
      final String id = (m.group(1) ?? '').trim();
      if (knownIds.contains(id)) {
        found.add(id);
      }
    }

    final List<String> titleCandidates = <String>[];
    for (final String line in raw.replaceAll('\r\n', '\n').split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final Match? titleMatch = _titleLine.firstMatch(trimmed);
      if (titleMatch != null) {
        titleCandidates.add((titleMatch.group(1) ?? '').trim());
        continue;
      }
      final Match? bullet = _bullet.firstMatch(trimmed);
      if (bullet != null) {
        titleCandidates.add((bullet.group(1) ?? '').trim());
      }
    }

    for (final String candidate in titleCandidates) {
      final String? id = _bestTitleMatch(candidate, experiences);
      if (id != null) {
        found.add(id);
      }
    }

    return found.toList(growable: false);
  }

  static String? _bestTitleMatch(String rawCandidate, List<Experience> experiences) {
    String candidate = rawCandidate.trim();
    if (candidate.isEmpty) {
      return null;
    }
    // "id — title" or "title (reason)" 형태 정리
    candidate = candidate
        .replaceFirst(RegExp(r'^[a-zA-Z0-9_\-]+\s*[—\-:]\s*'), '')
        .replaceFirst(RegExp(r'\s*\(.+\)\s*$'), '')
        .trim();
    if (candidate.length < 2) {
      return null;
    }
    final String lower = candidate.toLowerCase();

    for (final Experience e in experiences) {
      final String title = e.title.trim();
      if (title.isEmpty) {
        continue;
      }
      final String t = title.toLowerCase();
      if (t == lower || t.contains(lower) || lower.contains(t)) {
        return e.id;
      }
    }
    return null;
  }
}
