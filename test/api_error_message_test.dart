import 'dart:async';

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

  test('apiErrorMessage maps expired token to login hint', () {
    final String message = apiErrorMessage(
      ApiException(401, '{"detail":"Invalid or expired token"}'),
    );
    expect(message, '로그인이 만료되었거나 인증이 필요합니다. 설정에서 다시 로그인해 주세요.');
  });

  test('apiErrorMessage keeps login credential detail', () {
    final String message = apiErrorMessage(
      ApiException(401, '{"detail":"이메일 또는 비밀번호가 올바르지 않습니다."}'),
    );
    expect(message, '이메일 또는 비밀번호가 올바르지 않습니다.');
  });

  test('apiErrorMessage maps timeout', () {
    expect(
      apiErrorMessage(TimeoutException('timed out')),
      contains('지연'),
    );
  });

  test('actionErrorMessage prefixes the translated cause', () {
    expect(
      actionErrorMessage(
        '저장 실패',
        ApiException(400, '{"detail":"이미 사용 중인 이메일입니다."}'),
      ),
      '저장 실패: 이미 사용 중인 이메일입니다.',
    );
  });

  test('apiErrorMessage maps connection failures', () {
    expect(
      apiErrorMessage(Exception('ClientException: Connection refused')),
      contains('서버에 연결할 수 없습니다'),
    );
  });
}
