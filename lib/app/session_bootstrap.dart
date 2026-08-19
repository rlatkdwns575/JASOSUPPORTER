import 'package:chatgptmini/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 저장된 JWT 세션을 검증한다.
class SessionBootstrap extends ConsumerStatefulWidget {
  const SessionBootstrap({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<SessionBootstrap> createState() => _SessionBootstrapState();
}

class _SessionBootstrapState extends ConsumerState<SessionBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).validateStoredSession();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
