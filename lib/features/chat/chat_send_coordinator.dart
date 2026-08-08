import 'package:chatgptmini/data/providers/attachment_session_provider.dart';
import 'package:chatgptmini/data/providers/chat_providers.dart';
import 'package:chatgptmini/data/providers/chat_session_provider.dart';
import 'package:chatgptmini/data/providers/coach_prefs_provider.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:chatgptmini/features/chat/chat_flow_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사용자/프로그래밍 전송을 세션에 등록하고 [ChatTurn]을 반환한다.
///
/// 스트리밍 시작은 호출부([ChatStreamRunner]) 책임이다.
class ChatSendCoordinator {
  ChatSendCoordinator(this.ref);

  final Ref ref;

  ChatTurn? beginUserSend({
    required AssistantMode mode,
    required String mainText,
    required String attachmentText,
    required String targetJob,
    List<String> selectedExperienceIds = const [],
  }) {
    final ChatSessionState session = ref.read(chatSessionProvider);
    if (session.isGenerating) {
      return null;
    }
    final CoachQuestionKind kind =
        ref.read(coachQuestionKindSelectionProvider.notifier).kindFor(mode);
    final String composedMain = kind.composeMainText(mainText);
    final ChatTurn? turn = ref.read(chatFlowControllerProvider).createUserTurn(
          mode: mode,
          currentChats: session.roomFor(mode).chats,
          mainText: composedMain,
          attachmentText: attachmentText,
          attachments: ref.read(attachmentSessionProvider),
          targetJob: targetJob,
          selectedExperienceIds: selectedExperienceIds,
          model: ref.read(selectedGeminiModelProvider),
        );
    if (turn == null) {
      return null;
    }
    ref.read(chatSessionProvider.notifier).addUserAndStart(mode, turn.userMessage);
    return turn;
  }

  ChatTurn? beginProgrammaticSend({
    required AssistantMode mode,
    required String chatBubbleText,
    required String attachmentText,
    required String targetJob,
    List<String> selectedExperienceIds = const [],
  }) {
    final ChatSessionState session = ref.read(chatSessionProvider);
    if (session.isGenerating) {
      return null;
    }
    final ChatTurn turn = ref.read(chatFlowControllerProvider).createProgrammaticTurn(
          mode: mode,
          currentChats: session.roomFor(mode).chats,
          chatBubbleText: chatBubbleText,
          attachmentText: attachmentText,
          attachments: ref.read(attachmentSessionProvider),
          targetJob: targetJob,
          selectedExperienceIds: selectedExperienceIds,
          model: ref.read(selectedGeminiModelProvider),
        );
    ref.read(chatSessionProvider.notifier).addUserAndStart(mode, turn.userMessage);
    return turn;
  }

  Future<AttachmentPickResult> pickBinaryFiles() {
    return ref.read(attachmentServiceProvider).pickBinaryFiles(
          existingCount: ref.read(attachmentSessionProvider).length,
        );
  }

  void addAttachments(List<PickedAttachment> attachments) {
    if (attachments.isEmpty) {
      return;
    }
    ref.read(attachmentSessionProvider.notifier).addAll(attachments);
  }

  void removeAttachmentAt(int index) {
    ref.read(attachmentSessionProvider.notifier).removeAt(index);
  }

  bool clearAttachments() {
    if (ref.read(attachmentSessionProvider).isEmpty) {
      return false;
    }
    ref.read(attachmentSessionProvider.notifier).clear();
    return true;
  }
}

final chatSendCoordinatorProvider = Provider<ChatSendCoordinator>((Ref ref) {
  return ChatSendCoordinator(ref);
});
