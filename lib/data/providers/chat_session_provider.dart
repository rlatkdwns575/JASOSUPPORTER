import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 모드별 채팅룸 + 생성 중 플래그.
class ChatSessionState {
  ChatSessionState({
    required this.rooms,
    required this.isGenerating,
  });

  final Map<AssistantMode, ChatRoom> rooms;
  final bool isGenerating;

  ChatRoom roomFor(AssistantMode mode) => rooms[mode]!;

  ChatSessionState copyWith({
    Map<AssistantMode, ChatRoom>? rooms,
    bool? isGenerating,
  }) {
    return ChatSessionState(
      rooms: rooms ?? this.rooms,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

/// 채팅 메시지·생성 상태를 모드별로 보관한다.
class ChatSessionNotifier extends Notifier<ChatSessionState> {
  @override
  ChatSessionState build() {
    final DateTime now = DateTime.now();
    return ChatSessionState(
      rooms: {
        for (final AssistantMode mode in AssistantMode.values)
          mode: ChatRoom(chats: <ChatMessage>[], createdAt: now),
      },
      isGenerating: false,
    );
  }

  void _emit({
    Map<AssistantMode, ChatRoom>? rooms,
    bool? isGenerating,
  }) {
    state = state.copyWith(
      rooms: rooms ?? Map<AssistantMode, ChatRoom>.of(state.rooms),
      isGenerating: isGenerating,
    );
  }

  void addUserAndStart(AssistantMode mode, ChatMessage userMessage) {
    state.roomFor(mode).chats.add(userMessage);
    _emit(isGenerating: true);
  }

  int addAssistantPlaceholder(AssistantMode mode) {
    final ChatMessage gptMessage = ChatMessage(
      isMe: false,
      text: '',
      sentAt: DateTime.now(),
    );
    state.roomFor(mode).chats.add(gptMessage);
    _emit();
    return state.roomFor(mode).chats.length - 1;
  }

  void appendAssistantChunk(AssistantMode mode, int index, String chunk) {
    state.roomFor(mode).chats[index].text += chunk;
    _emit();
  }

  void finishGenerating(AssistantMode mode, {String? errorText, int? assistantIndex}) {
    if (errorText != null && assistantIndex != null) {
      state.roomFor(mode).chats[assistantIndex].text = errorText;
    }
    _emit(isGenerating: false);
  }
}

final chatSessionProvider =
    NotifierProvider<ChatSessionNotifier, ChatSessionState>(ChatSessionNotifier.new);
