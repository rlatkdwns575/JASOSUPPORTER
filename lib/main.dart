import 'package:chatgptmini/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // API 키는 서버에서만 관리한다. .env는 API_BASE_URL 등 비민감 설정 용도로만 선택 로드한다.
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (_) {
    // .env가 없어도 기본 설정으로 진행한다.
  }
  runApp(const JasoApp());
}
