class ChatMessage {
  ChatMessage({
    required this.isMe,
    required this.text,
    required this.sentAt,
  });

  final bool isMe;
  String text;
  final DateTime sentAt;
}

class ChatRoom {
  ChatRoom({
    required this.chats,
    required this.createdAt,
  });

  final List<ChatMessage> chats;
  final DateTime createdAt;
}
