import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/data/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShellActionResult marks error results', () {
    const ShellActionResult result = ShellActionResult(
      snack: '포트폴리오 개요 저장 실패: 요청에 실패했습니다.',
      isError: true,
    );
    expect(result.isError, isTrue);
    expect(result.hasSnack, isTrue);
  });

  test('actionErrorMessage formats portfolio save failures', () {
    expect(
      actionErrorMessage('포트폴리오 개요 저장 실패', ApiException(503, '{"detail":"busy"}')),
      contains('포트폴리오 개요 저장 실패'),
    );
  });
}
