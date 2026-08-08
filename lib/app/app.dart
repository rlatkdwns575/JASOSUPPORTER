import 'package:chatgptmini/app/router.dart';
import 'package:chatgptmini/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 최상위 앱 위젯. Riverpod [ProviderScope] + go_router 기반 MaterialApp.router.
class JasoApp extends StatelessWidget {
  const JasoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'JasoSupporter',
        theme: AppTheme.light(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
