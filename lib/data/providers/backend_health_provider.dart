import 'package:chatgptmini/data/providers/gemini_models_provider.dart';
import 'package:chatgptmini/domain/models/backend_health.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 백엔드 `/health` 상태. 설정 화면·연결 진단용.
final backendHealthProvider = FutureProvider<BackendHealth>((Ref ref) async {
  ref.watch(apiClientProvider);
  final Object raw = await ref.read(apiClientProvider).getJson('/health');
  if (raw is Map<String, dynamic>) {
    return BackendHealth.fromJson(raw);
  }
  if (raw is Map) {
    return BackendHealth.fromJson(
      raw.map((Object? key, Object? value) => MapEntry('$key', value)),
    );
  }
  throw StateError('헬스 응답 형식이 올바르지 않습니다.');
});
