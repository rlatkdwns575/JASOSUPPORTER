import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마스터 자소서 문항(Q1~Q6)별 선택 Experience id.
class MasterEssaySelectionNotifier extends Notifier<Map<int, Set<String>>> {
  @override
  Map<int, Set<String>> build() => const <int, Set<String>>{};

  List<String> idsFor(int questionIndex) {
    return (state[questionIndex] ?? const <String>{}).toList(growable: false);
  }

  Set<String> setFor(int questionIndex) {
    return Set<String>.unmodifiable(state[questionIndex] ?? const <String>{});
  }

  void toggle(int questionIndex, String experienceId) {
    final String id = experienceId.trim();
    if (id.isEmpty || questionIndex < 0 || questionIndex > 5) {
      return;
    }
    final Map<int, Set<String>> next = _copyState();
    final Set<String> selected = next.putIfAbsent(questionIndex, () => <String>{});
    if (!selected.add(id)) {
      selected.remove(id);
    }
    state = next;
  }

  void selectAll(int questionIndex, Iterable<String> experienceIds) {
    if (questionIndex < 0 || questionIndex > 5) {
      return;
    }
    final Map<int, Set<String>> next = _copyState();
    next[questionIndex] = {
      for (final String raw in experienceIds)
        if (raw.trim().isNotEmpty) raw.trim(),
    };
    state = next;
  }

  void clearQuestion(int questionIndex) {
    if (questionIndex < 0 || questionIndex > 5) {
      return;
    }
    if (!(state[questionIndex]?.isNotEmpty ?? false)) {
      return;
    }
    final Map<int, Set<String>> next = _copyState();
    next[questionIndex] = <String>{};
    state = next;
  }

  void replaceQuestion(int questionIndex, Iterable<String> experienceIds) {
    selectAll(questionIndex, experienceIds);
  }

  void addAll(int questionIndex, Iterable<String> experienceIds) {
    if (questionIndex < 0 || questionIndex > 5) {
      return;
    }
    final Map<int, Set<String>> next = _copyState();
    final Set<String> selected = next.putIfAbsent(questionIndex, () => <String>{});
    for (final String raw in experienceIds) {
      final String id = raw.trim();
      if (id.isNotEmpty) {
        selected.add(id);
      }
    }
    state = next;
  }

  /// Q1~Q6에 선택된 경험 id 합집합.
  List<String> get allSelectedIds {
    return state.values.expand((Set<String> ids) => ids).toSet().toList(growable: false);
  }

  Map<int, Set<String>> _copyState() {
    return {
      for (final MapEntry<int, Set<String>> entry in state.entries)
        entry.key: {...entry.value},
    };
  }
}

final masterEssaySelectionProvider =
    NotifierProvider<MasterEssaySelectionNotifier, Map<int, Set<String>>>(
  MasterEssaySelectionNotifier.new,
);

/// 경험 카드 → 마스터 자소서로 이동할 때 Q1에 미리 선택할 id 대기열.
class MasterEssayPendingSelectionNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => const <String>[];

  void queue(String experienceId) {
    final String id = experienceId.trim();
    if (id.isEmpty) {
      return;
    }
    if (state.contains(id)) {
      return;
    }
    state = [...state, id];
  }

  void queueAll(Iterable<String> experienceIds) {
    final List<String> next = [...state];
    for (final String raw in experienceIds) {
      final String id = raw.trim();
      if (id.isEmpty || next.contains(id)) {
        continue;
      }
      next.add(id);
    }
    state = next;
  }

  /// 워크스페이스가 소비한 뒤 비운다.
  List<String> takeAll() {
    if (state.isEmpty) {
      return const <String>[];
    }
    final List<String> out = List<String>.from(state);
    state = const <String>[];
    return out;
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = const <String>[];
  }
}

final masterEssayPendingSelectionProvider =
    NotifierProvider<MasterEssayPendingSelectionNotifier, List<String>>(
  MasterEssayPendingSelectionNotifier.new,
);
