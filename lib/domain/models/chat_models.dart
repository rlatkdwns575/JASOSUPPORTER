class ChatMessage {
  ChatMessage({
    required this.isMe,
    required this.text,
    required this.sentAt,
  });

  final bool isMe;
  String text;
  final DateTime sentAt;

  Map<String, Object?> toJson() => {
        'role': isMe ? 'user' : 'assistant',
        'text': text,
        'sentAt': sentAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final String role = '${json['role'] ?? ''}';
    final bool isMe = role == 'user' || json['isMe'] == true;
    final DateTime sentAt = DateTime.tryParse('${json['sentAt'] ?? ''}') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return ChatMessage(
      isMe: isMe,
      text: '${json['text'] ?? ''}',
      sentAt: sentAt,
    );
  }
}

class ChatRoom {
  ChatRoom({
    required this.chats,
    required this.createdAt,
    this.id,
    this.mode,
  });

  final List<ChatMessage> chats;
  final DateTime createdAt;
  final String? id;
  final String? mode;

  Map<String, Object?> toJson() => {
        'id': id,
        'mode': mode,
        'messages': chats.map((ChatMessage m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

  factory ChatRoom.fromJson(Map<String, Object?> json) {
    final Object? rawMessages = json['messages'] ?? json['chats'];
    final List<ChatMessage> chats = <ChatMessage>[];
    if (rawMessages is List) {
      for (final Object? item in rawMessages) {
        if (item is Map) {
          chats.add(ChatMessage.fromJson(Map<String, Object?>.from(item)));
        }
      }
    }
    return ChatRoom(
      id: json['id'] is String ? json['id'] as String : null,
      mode: json['mode'] is String ? json['mode'] as String : null,
      chats: chats,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
    );
  }
}
