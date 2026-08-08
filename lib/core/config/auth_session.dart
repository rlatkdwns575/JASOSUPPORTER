import 'package:shared_preferences/shared_preferences.dart';

/// JWT 로그인 세션. SharedPreferences에 토큰·유저 정보를 보관한다.
class AuthSession {
  AuthSession._();

  static const String _tokenKey = 'jaso_access_token';
  static const String _userIdKey = 'jaso_auth_user_id';
  static const String _emailKey = 'jaso_auth_email';

  static String? accessToken;
  static String? userId;
  static String? email;

  static bool get isLoggedIn =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  static Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_tokenKey);
    userId = prefs.getString(_userIdKey);
    email = prefs.getString(_emailKey);
  }

  static Future<void> save({
    required String token,
    required String id,
    required String userEmail,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_emailKey, userEmail);
    accessToken = token;
    userId = id;
    email = userEmail;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    accessToken = null;
    userId = null;
    email = null;
  }
}
