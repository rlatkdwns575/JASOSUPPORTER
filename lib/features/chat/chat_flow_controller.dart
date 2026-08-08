import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/data/services/ai_service.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';

/// 한 번의 사용자 요청에 필요한 구조화 데이터.
///
/// 프롬프트 조합과 RAG 컨텍스트 주입은 서버가 담당하므로, 클라이언트는
/// 대화 맥락과 부가 정보만 전달한다.
class ChatTurn {
  const ChatTurn({
    required this.userMessage,
    required this.mode,
    required this.history,
    required this.attachmentText,
    required this.targetJob,
    required this.selectedExperienceIds,
    required this.attachments,
    this.model = '',
  });

  final ChatMessage userMessage;
  final AssistantMode mode;
  final List<AiChatMessage> history;
  final String attachmentText;
  final String targetJob;
  final List<String> selectedExperienceIds;
  final List<AiBinaryPart> attachments;
  final String model;
}

class ChatFlowController {
  const ChatFlowController({
    required this.aiService,
  });

  final AiService aiService;

  ChatTurn? createUserTurn({
    required AssistantMode mode,
    required List<ChatMessage> currentChats,
    required String mainText,
    required String attachmentText,
    required List<PickedAttachment> attachments,
    required String targetJob,
    List<String> selectedExperienceIds = const [],
    String model = '',
  }) {
    final String main = mainText.trim();
    final String attachment = attachmentText.trim();

    if (main.isEmpty && attachment.isEmpty && attachments.isEmpty) {
      return null;
    }

    final List<String> fileNames = attachments.map((e) => e.name).toList();
    final String displayForChat;
    if (main.isNotEmpty) {
      displayForChat = fileNames.isEmpty ? main : "$main\n(첨부 파일: ${fileNames.join(", ")})";
    } else if (attachment.isNotEmpty) {
      displayForChat = "(자료·링크만 전달함)\n$attachment";
    } else {
      displayForChat = "(파일 첨부) ${fileNames.join(", ")}";
    }

    return _createTurn(
      mode: mode,
      currentChats: currentChats,
      chatBubbleText: displayForChat,
      attachmentText: attachmentText,
      attachments: attachments,
      targetJob: targetJob,
      selectedExperienceIds: selectedExperienceIds,
      model: model,
    );
  }

  ChatTurn createProgrammaticTurn({
    required AssistantMode mode,
    required List<ChatMessage> currentChats,
    required String chatBubbleText,
    required String attachmentText,
    required List<PickedAttachment> attachments,
    required String targetJob,
    List<String> selectedExperienceIds = const [],
    String model = '',
  }) {
    return _createTurn(
      mode: mode,
      currentChats: currentChats,
      chatBubbleText: chatBubbleText,
      attachmentText: attachmentText,
      attachments: attachments,
      targetJob: targetJob,
      selectedExperienceIds: selectedExperienceIds,
      model: model,
    );
  }

  Stream<String> streamAssistantText(ChatTurn turn) {
    return aiService.streamChat(
      mode: modeKey(turn.mode),
      messages: turn.history,
      attachmentText: turn.attachmentText,
      targetJob: turn.targetJob,
      selectedExperienceIds: turn.selectedExperienceIds,
      attachments: turn.attachments,
      model: turn.model,
    );
  }

  static String modeKey(AssistantMode mode) {
    switch (mode) {
      case AssistantMode.experienceSpec:
        return 'experienceSpec';
      case AssistantMode.masterResume:
        return 'masterResume';
      case AssistantMode.portfolio:
        return 'portfolio';
      case AssistantMode.interview:
        return 'interview';
    }
  }

  ChatTurn _createTurn({
    required AssistantMode mode,
    required List<ChatMessage> currentChats,
    required String chatBubbleText,
    required String attachmentText,
    required List<PickedAttachment> attachments,
    required String targetJob,
    required List<String> selectedExperienceIds,
    String model = '',
  }) {
    final ChatMessage userMessage = ChatMessage(
      isMe: true,
      text: chatBubbleText,
      sentAt: DateTime.now(),
    );

    final List<AiChatMessage> history = [
      for (final ChatMessage chat in [...currentChats, userMessage])
        if (chat.text.trim().isNotEmpty)
          AiChatMessage(role: chat.isMe ? 'user' : 'assistant', text: chat.text),
    ];

    return ChatTurn(
      userMessage: userMessage,
      mode: mode,
      history: history,
      attachmentText: attachmentText,
      targetJob: targetJob,
      selectedExperienceIds: selectedExperienceIds,
      model: model,
      attachments: attachments
          .map(
            (PickedAttachment attachment) => AiBinaryPart(
              name: attachment.name,
              bytes: attachment.bytes,
              mimeType: attachment.mimeType,
            ),
          )
          .toList(),
    );
  }
}
