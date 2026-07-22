import 'package:chatgptmini/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 앱 라우터. 현재 3개 모드를 URL 라우트로 노출한다.
///
/// ShellRoute가 [ChatGptApp] 셸을 라우트 전환 간 유지하므로 채팅룸·컨트롤러·
/// 저장 경험 등 공유 상태가 보존된다(별도 상태관리 라이브러리 불필요).
final GoRouter appRouter = GoRouter(
  initialLocation: '/experience',
  routes: [
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) => '/experience',
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ChatGptApp(location: state.matchedLocation);
      },
      routes: [
        GoRoute(
          path: '/experience',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/master-resume',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
      ],
    ),
  ],
);
