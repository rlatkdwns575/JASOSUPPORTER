import 'package:chatgptmini/core/config/auth_session.dart';
import 'package:chatgptmini/core/config/user_identity.dart';
import 'package:chatgptmini/data/providers/gemini_models_provider.dart';
import 'package:chatgptmini/data/providers/session_lifecycle.dart';
import 'package:chatgptmini/data/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({
    required this.isLoggedIn,
    this.email,
    this.userId,
  });

  final bool isLoggedIn;
  final String? email;
  final String? userId;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(
      isLoggedIn: AuthSession.isLoggedIn,
      email: AuthSession.email,
      userId: AuthSession.userId ?? UserIdentity.forRequest,
    );
  }

  Future<void> register(String email, String password) async {
    final ApiClient client = ApiClient(accessToken: null, userId: UserIdentity.forRequest);
    try {
      final Object raw = await client.postJson('/auth/register', {
        'email': email.trim(),
        'password': password,
      });
      await _applyTokenResponse(raw);
    } finally {
      client.close();
    }
  }

  Future<void> login(String email, String password) async {
    final ApiClient client = ApiClient(accessToken: null, userId: UserIdentity.forRequest);
    try {
      final Object raw = await client.postJson('/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      await _applyTokenResponse(raw);
    } finally {
      client.close();
    }
  }

  Future<void> logout() async {
    await AuthSession.clear();
    state = AuthState(
      isLoggedIn: false,
      email: null,
      userId: UserIdentity.forRequest,
    );
    refreshUserSessionData(ref);
  }

  /// 앱 시작 시 저장된 JWT가 유효한지 확인한다. 네트워크 오류는 세션을 유지한다.
  Future<void> validateStoredSession() async {
    if (!AuthSession.isLoggedIn) {
      return;
    }
    try {
      final Object raw = await ref.read(apiClientProvider).getJson('/auth/me');
      if (raw is! Map) {
        return;
      }
      if ('${raw['auth'] ?? ''}' != 'jwt') {
        await logout();
        return;
      }
      final String email = '${raw['email'] ?? ''}'.trim();
      final String id = '${raw['user_id'] ?? ''}'.trim();
      if (email.isNotEmpty && id.isNotEmpty) {
        state = AuthState(isLoggedIn: true, email: email, userId: id);
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await logout();
      }
    }
  }

  Future<void> _applyTokenResponse(Object raw) async {
    if (raw is! Map) {
      throw StateError('인증 응답 형식이 올바르지 않습니다.');
    }
    final String token = '${raw['access_token'] ?? ''}'.trim();
    final String id = '${raw['user_id'] ?? ''}'.trim();
    final String userEmail = '${raw['email'] ?? ''}'.trim();
    if (token.isEmpty || id.isEmpty) {
      throw StateError('토큰을 받지 못했습니다.');
    }
    await AuthSession.save(token: token, id: id, userEmail: userEmail);
    state = AuthState(isLoggedIn: true, email: userEmail, userId: id);
    refreshUserSessionData(ref);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
