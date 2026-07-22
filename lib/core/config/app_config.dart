import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 백엔드(FastAPI) 연결 설정.
///
/// 우선순위: `--dart-define=API_BASE_URL=...` > `assets/.env`의 `API_BASE_URL` > 기본값.
/// API 키는 더 이상 클라이언트에 두지 않는다(서버 `.env`에서만 관리).
class AppConfig {
  const AppConfig._();

  static const String _defineBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_defineBaseUrl.isNotEmpty) {
      return _normalize(_defineBaseUrl);
    }
    try {
      final String? fromEnv = dotenv.maybeGet('API_BASE_URL');
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        return _normalize(fromEnv);
      }
    } catch (_) {
      // dotenv가 로드되지 않았어도 기본값으로 진행.
    }
    return 'http://localhost:8000';
  }

  static String _normalize(String url) {
    final String trimmed = url.trim();
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }
}
