import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI가 만든 면접 예상 질문 목록 (I01).
class InterviewQuestionsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const <String>[];

  void replaceWith(Iterable<String> questions) {
    final List<String> cleaned = questions
        .map((String q) => q.trim())
        .where((String q) => q.isNotEmpty)
        .toList(growable: false);
    state = cleaned;
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = const <String>[];
  }
}

final interviewQuestionsProvider =
    NotifierProvider<InterviewQuestionsNotifier, List<String>>(
  InterviewQuestionsNotifier.new,
);

/// AI 답변 텍스트에서 면접 질문 후보를 추출한다.
abstract final class InterviewQuestionParser {
  static final RegExp _bullet = RegExp(
    r'^\s*(?:(?:\d+)[\.\)]|[-*•·]|Q\d*[:.)]|질문\s*\d*[:.)])\s*(.+)$',
    caseSensitive: false,
  );

  static List<String> parse(String raw) {
    final List<String> lines = raw
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);

    final List<String> fromBullets = <String>[];
    for (final String line in lines) {
      final Match? match = _bullet.firstMatch(line);
      if (match != null) {
        final String q = (match.group(1) ?? '').trim();
        if (q.length >= 6) {
          fromBullets.add(_stripQuotes(q));
        }
      }
    }
    if (fromBullets.length >= 2) {
      return _dedupe(fromBullets);
    }

    final List<String> fromQuestions = <String>[];
    for (final String line in lines) {
      final String cleaned = _stripQuotes(line);
      if ((cleaned.endsWith('?') || cleaned.endsWith('？')) &&
          cleaned.length >= 8) {
        fromQuestions.add(cleaned);
      }
    }
    if (fromQuestions.length >= 2) {
      return _dedupe(fromQuestions);
    }

    return const <String>[];
  }

  /// 질문 목록으로 쓸 수 있으면 true (답변 적용과 구분).
  static bool looksLikeQuestionList(String raw) => parse(raw).length >= 2;

  static String _stripQuotes(String value) {
    var text = value.trim();
    if ((text.startsWith('"') && text.endsWith('"')) ||
        (text.startsWith("'") && text.endsWith("'")) ||
        (text.startsWith('“') && text.endsWith('”'))) {
      text = text.substring(1, text.length - 1).trim();
    }
    return text;
  }

  static List<String> _dedupe(List<String> items) {
    final Set<String> seen = <String>{};
    final List<String> out = <String>[];
    for (final String item in items) {
      final String key = item.toLowerCase();
      if (seen.add(key)) {
        out.add(item);
      }
    }
    return out;
  }
}
