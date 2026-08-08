import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 코치 패널에서 고른 Gemini 모델 id.
class SelectedGeminiModelNotifier extends Notifier<String> {
  @override
  String build() => GeminiModelOption.defaultId;

  void select(String modelId) {
    final String id = modelId.trim();
    if (id.isEmpty || id == state) {
      return;
    }
    state = id;
  }
}

final selectedGeminiModelProvider =
    NotifierProvider<SelectedGeminiModelNotifier, String>(
  SelectedGeminiModelNotifier.new,
);

/// 모드별 질문 종류 id. 모드가 바뀌면 해당 모드의 선택을 쓴다.
class CoachQuestionKindSelectionNotifier extends Notifier<Map<AssistantMode, String>> {
  @override
  Map<AssistantMode, String> build() {
    return {
      for (final AssistantMode mode in AssistantMode.values)
        mode: CoachQuestionKind.freeform.id,
    };
  }

  void select(AssistantMode mode, String kindId) {
    final String resolved = CoachQuestionKind.resolve(mode, kindId).id;
    if (state[mode] == resolved) {
      return;
    }
    state = {...state, mode: resolved};
  }

  CoachQuestionKind kindFor(AssistantMode mode) {
    return CoachQuestionKind.resolve(mode, state[mode]);
  }
}

final coachQuestionKindSelectionProvider = NotifierProvider<
    CoachQuestionKindSelectionNotifier, Map<AssistantMode, String>>(
  CoachQuestionKindSelectionNotifier.new,
);
