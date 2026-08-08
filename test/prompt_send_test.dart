import 'package:chatgptmini/core/utils/prompt_send.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolvePromptToSend', () {
    test('returns prompt when canSend', () {
      expect(
        resolvePromptToSend(
          canSend: true,
          prompt: '  hello  ',
          errorMessage: null,
          onError: (_) => fail('should not error'),
        ),
        'hello',
      );
    });

    test('reports error and returns null when cannot send', () {
      String? seen;
      expect(
        resolvePromptToSend(
          canSend: false,
          prompt: null,
          errorMessage: '없음',
          onError: (String m) => seen = m,
        ),
        isNull,
      );
      expect(seen, '없음');
    });
  });
}
