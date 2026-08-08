import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 면접 대비에서 선택한 Experience id 집합.
class InterviewSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    final Set<String> next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  void replaceWith(Iterable<String> ids) {
    state = {...ids};
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = <String>{};
  }

  List<String> get asList => state.toList(growable: false);
}

final interviewSelectionProvider =
    NotifierProvider<InterviewSelectionNotifier, Set<String>>(
  InterviewSelectionNotifier.new,
);
