import 'package:chatgptmini/core/utils/auth_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email rejects empty and invalid formats', () {
    expect(AuthFormValidator.email(''), isNotNull);
    expect(AuthFormValidator.email('invalid'), isNotNull);
    expect(AuthFormValidator.email('user@'), isNotNull);
    expect(AuthFormValidator.email('user@example.com'), isNull);
  });

  test('password requires at least 8 characters', () {
    expect(AuthFormValidator.password('1234567'), isNotNull);
    expect(AuthFormValidator.password('12345678'), isNull);
  });

  test('credentials returns first validation error', () {
    expect(
      AuthFormValidator.credentials(emailValue: '', passwordValue: '12345678'),
      contains('이메일'),
    );
    expect(
      AuthFormValidator.credentials(emailValue: 'user@example.com', passwordValue: 'short'),
      contains('8자'),
    );
  });
}
