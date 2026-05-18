import 'package:chatgptmini/assistant_prompts.dart';
import 'package:chatgptmini/data/services/attachment_service.dart';
import 'package:chatgptmini/data/services/gemini_service.dart';
import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:chatgptmini/model.dart';

class ChatTurn {
  const ChatTurn({
    required this.userMessage,
    required this.prompt,
    required this.attachments,
  });

  final ChatMessage userMessage;
  final String prompt;
  final List<AiBinaryPart> attachments;
}

class ChatFlowController {
  const ChatFlowController({
    required this.promptBuilder,
    required this.aiService,
  });

  final PromptBuilder promptBuilder;
  final AiService aiService;

  ChatTurn? createUserTurn({
    required AssistantMode mode,
    required List<ChatMessage> currentChats,
    required String mainText,
    required String attachmentText,
    required List<PickedAttachment> attachments,
    required String targetJob,
    required String experienceContext,
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
      experienceContext: experienceContext,
    );
  }

  ChatTurn createProgrammaticTurn({
    required AssistantMode mode,
    required List<ChatMessage> currentChats,
    required String chatBubbleText,
    required String attachmentText,
    required List<PickedAttachment> attachments,
    required String targetJob,
    required String experienceContext,
  }) {
    return _createTurn(
      mode: mode,
      currentChats: currentChats,
      chatBubbleText: chatBubbleText,
      attachmentText: attachmentText,
      attachments: attachments,
      targetJob: targetJob,
      experienceContext: experienceContext,
    );
  }

  Stream<String> streamAssistantText(ChatTurn turn) {
    return aiService.streamText(
      prompt: turn.prompt,
      attachments: turn.attachments,
    );
  }

  ChatTurn _createTurn({
    required AssistantMode mode,
    required List<ChatMessage> currentChats,
    required String chatBubbleText,
    required String attachmentText,
    required List<PickedAttachment> attachments,
    required String targetJob,
    required String experienceContext,
  }) {
    final ChatMessage userMessage = ChatMessage(
      isMe: true,
      text: chatBubbleText,
      sentAt: DateTime.now(),
    );
    final List<ChatMessage> chatsForPrompt = [
      ...currentChats,
      userMessage,
    ];
    final String prompt = promptBuilder.buildChatPrompt(
      mode: mode,
      chats: chatsForPrompt,
      attachmentText: attachmentText,
      binaryFileNames: attachments.map((e) => e.name).toList(),
      targetJob: targetJob,
      experienceContext: experienceContext,
    );

    return ChatTurn(
      userMessage: userMessage,
      prompt: prompt,
      attachments: attachments
          .map(
            (PickedAttachment attachment) => AiBinaryPart(
              name: attachment.name,
              bytes: attachment.bytes,
            ),
          )
          .toList(),
    );
  }
}
