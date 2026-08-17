import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/data/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('apiErrorMessage extracts FastAPI detail string', () {
    final String message = apiErrorMessage(
      ApiException(400, '{"detail":"이미 사용 중인 이메일입니다."}'),
    );
    expect(message, '이미 사용 중인 이메일입니다.');
  });

  test('apiErrorMessage falls back for unknown errors', () {
    expect(
      apiErrorMessage(Exception('network')),
      '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.',
    );
  });
}
