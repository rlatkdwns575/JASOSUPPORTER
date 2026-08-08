import 'dart:convert';
import 'dart:typed_data';

import 'package:chatgptmini/data/services/api_client.dart';

/// AI로 전달할 바이너리 첨부(이미지·PDF).
class AiBinaryPart {
  const AiBinaryPart({
    required this.name,
    required this.bytes,
    this.mimeType = 'application/octet-stream',
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;
}

/// 대화 맥락 한 줄. role은 "user" 또는 "assistant".
class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.text,
  });

  final String role;
  final String text;

  Map<String, Object?> toJson() => {'role': role, 'text': text};
}

/// AI 응답 스트림 계약. 프롬프트 조합·RAG·API 키는 서버가 담당한다.
abstract class AiService {
  Stream<String> streamChat({
    required String mode,
    required List<AiChatMessage> messages,
    String attachmentText,
    String targetJob,
    List<String> selectedExperienceIds,
    List<AiBinaryPart> attachments,
    String model,
  });
}

/// FastAPI 백엔드의 `/chat` SSE 엔드포인트를 사용하는 구현.
class HttpAiService implements AiService {
  HttpAiService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  @override
  Stream<String> streamChat({
    required String mode,
    required List<AiChatMessage> messages,
    String attachmentText = '',
    String targetJob = '',
    List<String> selectedExperienceIds = const [],
    List<AiBinaryPart> attachments = const [],
    String model = '',
  }) {
    final Map<String, Object?> body = {
      'mode': mode,
      'messages': messages.map((AiChatMessage m) => m.toJson()).toList(),
      'attachmentText': attachmentText,
      'targetJob': targetJob,
      'selectedExperienceIds': selectedExperienceIds,
      'model': model,
      'attachments': attachments
          .map(
            (AiBinaryPart a) => {
              'name': a.name,
              'mimeType': a.mimeType,
              'dataBase64': base64Encode(a.bytes),
            },
          )
          .toList(),
    };
    return _api.streamSse('/chat', body);
  }
}
