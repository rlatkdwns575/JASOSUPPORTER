import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// AI 답변 텍스트에서 제목·역할·STAR 라벨을 추출해 Experience 초안으로 변환한다.
///
/// 라벨이 없으면 기존처럼 전체 본문을 행동(A)에 넣는다. 없는 사실은 만들지 않는다.
class ExperienceStarParser {
  const ExperienceStarParser._();

  static final RegExp _headerPattern = RegExp(
    r'^(?:[\d]+[\.\)\-]\s*|[-*•]\s*)?'
    r'(?:\*{1,2}|#{1,3}\s*)?'
    r'(제목|title|기관|소속|organization|회사|기업|역할|role|직무|'
    r'기간|period|상황|situation|과제|task|행동|action|'
    r'결과|성과|result|배운\s*점|learned|learning)'
    r'(?:\*{1,2})?'
    r'(?:\s*[\(（]?\s*[STAR]\s*[\)）]?)?'
    r'\s*[:：\-]?\s*(.*)$',
    caseSensitive: false,
  );

  static final RegExp _periodPattern = RegExp(
    r'(\d{2,4})[./-](\d{1,2})\s*[~\-–—]\s*(\d{2,4})[./-](\d{1,2})',
  );

  static Experience toDraft(
    String raw, {
    required DateTime now,
    String? id,
  }) {
    final String text = raw.trim();
    final Map<String, String> sections = parseSections(text);
    final bool hasLabeledStar = sections.containsKey('situation') ||
        sections.containsKey('task') ||
        sections.containsKey('action') ||
        sections.containsKey('result') ||
        sections.containsKey('learned');

    final String action = hasLabeledStar
        ? (sections['action'] ?? '')
        : text;
    final String title = (sections['title'] ?? '').trim().isNotEmpty
        ? sections['title']!.trim()
        : 'AI 정리 경험 초안';

    return Experience(
      id: id ?? 'exp_ai_${now.microsecondsSinceEpoch}',
      title: title,
      type: _guessType(sections, title, text),
      period: _parsePeriod(sections['period'] ?? ''),
      organization: (sections['organization'] ?? '').trim(),
      role: (sections['role'] ?? '').trim(),
      situation: (sections['situation'] ?? '').trim(),
      task: (sections['task'] ?? '').trim(),
      action: action.trim(),
      result: (sections['result'] ?? '').trim(),
      learned: (sections['learned'] ?? '').trim(),
      techStacks: const [],
      competencyTags: const [],
      evidenceLinks: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 라벨 키: title, organization, role, period, situation, task, action, result, learned
  static Map<String, String> parseSections(String raw) {
    final List<String> lines = raw.replaceAll('\r\n', '\n').split('\n');
    final Map<String, StringBuffer> buffers = {};
    String? currentKey;

    for (final String line in lines) {
      final RegExpMatch? match = _headerPattern.firstMatch(line.trim());
      if (match != null) {
        final String? key = _normalizeLabel(match.group(1) ?? '');
        if (key != null) {
          currentKey = key;
          buffers.putIfAbsent(key, StringBuffer.new);
          final String inline = (match.group(2) ?? '').trim();
          if (inline.isNotEmpty) {
            if (buffers[key]!.isNotEmpty) {
              buffers[key]!.writeln();
            }
            buffers[key]!.write(inline);
          }
          continue;
        }
      }
      if (currentKey == null) {
        continue;
      }
      final StringBuffer buffer = buffers.putIfAbsent(currentKey, StringBuffer.new);
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.write(line.trimRight());
    }

    return {
      for (final MapEntry<String, StringBuffer> entry in buffers.entries)
        entry.key: entry.value.toString().trim(),
    };
  }

  static String? _normalizeLabel(String raw) {
    final String key = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return switch (key) {
      '제목' || 'title' => 'title',
      '기관' || '소속' || 'organization' || '회사' || '기업' => 'organization',
      '역할' || 'role' || '직무' => 'role',
      '기간' || 'period' => 'period',
      '상황' || 'situation' => 'situation',
      '과제' || 'task' => 'task',
      '행동' || 'action' => 'action',
      '결과' || '성과' || 'result' => 'result',
      '배운점' || 'learned' || 'learning' => 'learned',
      _ => null,
    };
  }

  static DateRange _parsePeriod(String raw) {
    final RegExpMatch? match = _periodPattern.firstMatch(raw.trim());
    if (match == null) {
      return const DateRange();
    }
    return DateRange(
      start: _yearMonth(match.group(1)!, match.group(2)!),
      end: _yearMonth(match.group(3)!, match.group(4)!),
    );
  }

  static DateTime? _yearMonth(String yearRaw, String monthRaw) {
    int year = int.tryParse(yearRaw) ?? 0;
    final int month = int.tryParse(monthRaw) ?? 0;
    if (year <= 0 || month < 1 || month > 12) {
      return null;
    }
    if (year < 100) {
      year += 2000;
    }
    return DateTime(year, month);
  }

  static ExperienceType _guessType(
    Map<String, String> sections,
    String title,
    String fullText,
  ) {
    final String hay = [
      title,
      sections['organization'] ?? '',
      sections['role'] ?? '',
      fullText,
    ].join(' ').toLowerCase();
    if (hay.contains('인턴')) {
      return ExperienceType.internship;
    }
    if (hay.contains('동아리')) {
      return ExperienceType.club;
    }
    if (hay.contains('공모') || hay.contains('해커톤') || hay.contains('수상')) {
      return ExperienceType.contest;
    }
    if (hay.contains('부트캠프')) {
      return ExperienceType.bootcamp;
    }
    if (hay.contains('아르바이트') || hay.contains('알바')) {
      return ExperienceType.partTime;
    }
    if (hay.contains('교환') || hay.contains('어학연수') || hay.contains('워킹홀리데이') || hay.contains('워홀')) {
      return ExperienceType.trainingAbroad;
    }
    if (hay.contains('프로젝트')) {
      return ExperienceType.project;
    }
    return ExperienceType.other;
  }
}
