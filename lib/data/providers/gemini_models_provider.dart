import 'package:chatgptmini/core/config/auth_session.dart';
import 'package:chatgptmini/core/config/user_identity.dart';
import 'package:chatgptmini/data/providers/auth_provider.dart';
import 'package:chatgptmini/data/services/api_client.dart';
import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((Ref ref) {
  // 로그인 상태에 따라 Bearer / soft id 를 다시 읽는다.
  ref.watch(authProvider);
  final ApiClient client = ApiClient(
    userId: AuthSession.userId ?? UserIdentity.forRequest,
    accessToken: AuthSession.accessToken,
    onUnauthorized: () {
      if (AuthSession.isLoggedIn) {
        ref.read(authProvider.notifier).logout();
      }
    },
  );
  ref.onDispose(client.close);
  return client;
});

/// 서버 `/models` 목록. 실패 시 로컬 폴백.
final geminiModelsCatalogProvider =
    FutureProvider<GeminiModelsCatalog>((Ref ref) async {
  try {
    final Object raw = await ref.watch(apiClientProvider).getJson('/models');
    if (raw is Map<String, dynamic>) {
      return GeminiModelsCatalog.fromJson(raw);
    }
    if (raw is Map) {
      return GeminiModelsCatalog.fromJson(
        raw.map((Object? key, Object? value) => MapEntry('$key', value)),
      );
    }
  } catch (_) {
    // 오프라인·서버 미기동 시 로컬 목록 사용
  }
  return GeminiModelsCatalog.fallback;
});
