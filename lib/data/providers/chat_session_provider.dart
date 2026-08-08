import 'package:chatgptmini/data/providers/gemini_models_provider.dart';
import 'package:chatgptmini/data/remote/chat_room_repository.dart';
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

/// 채팅 메시지·생성 상태를 모드별로 보관하고 서버에 저장한다.
class ChatSessionNotifier extends Notifier<ChatSessionState> {
  bool _hydrated = false;

  ChatRoomRepository get _repo =>
      ChatRoomRepository(apiClient: ref.read(apiClientProvider));

  @override
  ChatSessionState build() {
    final DateTime now = DateTime.now();
    final ChatSessionState initial = ChatSessionState(
      rooms: {
        for (final AssistantMode mode in AssistantMode.values)
          mode: ChatRoom(
            id: ChatRoomRepository.roomIdFor(mode),
            mode: mode.name,
            chats: <ChatMessage>[],
            createdAt: now,
          ),
      },
      isGenerating: false,
    );
    Future<void>.microtask(_hydrate);
    return initial;
  }

  Future<void> _hydrate() async {
    if (_hydrated) {
      return;
    }
    _hydrated = true;
    try {
      final Map<AssistantMode, ChatRoom> next =
          Map<AssistantMode, ChatRoom>.of(state.rooms);
      for (final AssistantMode mode in AssistantMode.values) {
        final ChatRoom? remote = await _repo.getRoom(mode);
        if (remote != null && remote.chats.isNotEmpty) {
          next[mode] = ChatRoom(
            id: ChatRoomRepository.roomIdFor(mode),
            mode: mode.name,
            chats: remote.chats,
            createdAt: remote.createdAt,
          );
        }
      }
      state = state.copyWith(rooms: next);
    } catch (_) {
      // 오프라인·미기동 시 메모리 세션만 사용
    }
  }

  Future<void> _persist(AssistantMode mode) async {
    try {
      await _repo.saveRoom(mode, state.roomFor(mode));
    } catch (_) {
      // 저장 실패해도 화면 흐름은 유지
    }
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
    Future<void>.microtask(() => _persist(mode));
  }
}

final chatSessionProvider =
    NotifierProvider<ChatSessionNotifier, ChatSessionState>(ChatSessionNotifier.new);
