/// 프롬프트 플랜을 전송 가능한 문자열로 해석한다.
///
/// 전송 불가면 [onError]로 메시지를 넘기고 `null`을 반환한다.
String? resolvePromptToSend({
  required bool canSend,
  required String? prompt,
  required String? errorMessage,
  required void Function(String message) onError,
}) {
  if (!canSend) {
    final String? message = errorMessage?.trim();
    if (message != null && message.isNotEmpty) {
      onError(message);
    }
    return null;
  }
  final String? text = prompt?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}
