import 'package:chatgptmini/data/providers/chat_providers.dart';
import 'package:chatgptmini/data/providers/chat_session_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/features/chat/chat_flow_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 어시스턴트 스트리밍을 세션에 반영한다.
///
/// UI(스크롤·mounted)는 콜백으로 위임한다.
class ChatStreamRunner {
  ChatStreamRunner(this.ref);

  final Ref ref;

  Future<void> run({
    required AssistantMode mode,
    required ChatTurn turn,
    required bool Function() isMounted,
    required void Function() onProgress,
  }) async {
    final ChatSessionNotifier session = ref.read(chatSessionProvider.notifier);
    final ChatFlowController flow = ref.read(chatFlowControllerProvider);
    final int assistantIndex = session.addAssistantPlaceholder(mode);
    onProgress();
    try {
      await for (final String chunk in flow.streamAssistantText(turn)) {
        if (!isMounted()) {
          return;
        }
        session.appendAssistantChunk(mode, assistantIndex, chunk);
        onProgress();
      }
      if (!isMounted()) {
        return;
      }
      session.finishGenerating(mode);
    } catch (e) {
      if (!isMounted()) {
        return;
      }
      session.finishGenerating(
        mode,
        errorText: '오류: $e',
        assistantIndex: assistantIndex,
      );
    }
  }
}

final chatStreamRunnerProvider = Provider<ChatStreamRunner>((Ref ref) {
  return ChatStreamRunner(ref);
});
