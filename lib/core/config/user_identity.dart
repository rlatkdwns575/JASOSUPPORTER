import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// 로그인 전 soft identity. 기기에 고정 UUID를 두고 `X-User-Id`로 보낸다.
class UserIdentity {
  UserIdentity._();

  static const String _prefsKey = 'jaso_user_id';
  static String? _cached;

  /// 캐시된 id. [ensure] 호출 전에는 null일 수 있다.
  static String? get cached => _cached;

  /// 요청 헤더용. ensure 전이면 `default`(서버 DEFAULT_USER_ID와 동일 계열).
  static String get forRequest => _cached ?? 'default';

  static Future<String> ensure() async {
    if (_cached != null && _cached!.isNotEmpty) {
      return _cached!;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existing = prefs.getString(_prefsKey)?.trim();
    if (existing == null || existing.isEmpty) {
      existing = _generateId();
      await prefs.setString(_prefsKey, existing);
    }
    _cached = existing;
    return existing;
  }

  /// 테스트용.
  static void debugSet(String? id) {
    _cached = id;
  }

  static String _generateId() {
    final Random random = Random.secure();
    final String hex = List<String>.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return 'user_$hex';
  }
}
