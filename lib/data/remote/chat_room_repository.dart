import 'package:chatgptmini/data/services/api_client.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';

/// 서버 `/chat-rooms` 영속화.
class ChatRoomRepository {
  ChatRoomRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  static String roomIdFor(AssistantMode mode) => 'room_${mode.name}';

  Future<ChatRoom?> getRoom(AssistantMode mode) async {
    try {
      final Object? raw = await _api.getJson('/chat-rooms/${roomIdFor(mode)}');
      if (raw is! Map) {
        return null;
      }
      return ChatRoom.fromJson(Map<String, Object?>.from(raw));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> saveRoom(AssistantMode mode, ChatRoom room) async {
    final ChatRoom payload = ChatRoom(
      id: roomIdFor(mode),
      mode: mode.name,
      chats: room.chats,
      createdAt: room.createdAt,
    );
    await _api.postJson('/chat-rooms', payload.toJson());
  }
}
