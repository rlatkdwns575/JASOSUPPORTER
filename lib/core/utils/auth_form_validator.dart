/// 로그인·회원가입 폼 검증.
class AuthFormValidator {
  const AuthFormValidator._();

  static String? email(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (!trimmed.contains('@') || trimmed.indexOf('@') == 0) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    final String domain = trimmed.split('@').last;
    if (!domain.contains('.')) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    return null;
  }

  static String? password(String value) {
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    return null;
  }

  static String? credentials({required String emailValue, required String passwordValue}) {
    return email(emailValue) ?? password(passwordValue);
  }
}
