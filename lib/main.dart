import 'package:chatgptmini/app/app.dart';
import 'package:chatgptmini/core/config/auth_session.dart';
import 'package:chatgptmini/core/config/user_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // API 키는 서버에서만 관리한다. .env는 API_BASE_URL 등 비민감 설정 용도.
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: 'assets/.env.example');
    } catch (_) {
      // 에셋이 없어도 AppConfig 기본값으로 진행한다.
    }
  }
  await UserIdentity.ensure();
  await AuthSession.load();
  runApp(const JasoApp());
}
