import 'package:chatgptmini/app/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 앱 라우터. 모드를 URL 라우트로 노출한다.
///
/// ShellRoute가 [ChatGptApp] 셸을 라우트 전환 간 유지하므로 채팅룸·컨트롤러·
/// 저장 경험 등 공유 상태가 보존된다.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) => '/home',
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ChatGptApp(
          location: state.matchedLocation,
          queryParameters: state.uri.queryParameters,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/experience',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: 'form',
              // 대분류는 허브(`/experience`)에만 둔다. category 없이 form으로 오면 허브로 보낸다.
              redirect: (BuildContext context, GoRouterState state) {
                final String? category =
                    state.uri.queryParameters['category']?.trim();
                if (category == null || category.isEmpty) {
                  return '/experience';
                }
                return null;
              },
              builder: (BuildContext context, GoRouterState state) =>
                  const SizedBox.shrink(),
            ),
            GoRoute(
              path: 'specs',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: 'confirm',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: 'complete',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: 'detail/:id',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
          ],
        ),
        GoRoute(
          path: '/master-resume',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: 'preview/:id',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
          ],
        ),
        GoRoute(
          path: '/interview',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: 'question',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: 'answer',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
            GoRoute(
              path: 'saved/:id',
              builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
            ),
          ],
        ),
        GoRoute(
          path: '/applications',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink(),
        ),
      ],
    ),
  ],
);
