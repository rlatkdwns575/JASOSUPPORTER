import 'package:chatgptmini/app/router.dart';
import 'package:chatgptmini/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 최상위 앱 위젯. go_router 기반 MaterialApp.router 를 구성한다.
class JasoApp extends StatelessWidget {
  const JasoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JasoSupporter',
      theme: AppTheme.light(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
