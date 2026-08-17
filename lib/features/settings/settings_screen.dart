import 'package:chatgptmini/core/config/app_config.dart';
import 'package:chatgptmini/core/config/user_identity.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S01 설정. 서버 API·인증·데이터 내보내기·개인정보(RAG) 안내.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    this.experienceCount = 0,
    this.specCount = 0,
    this.interviewAnswerCount = 0,
    this.onExportExperiences,
  });

  final int experienceCount;
  final int specCount;
  final int interviewAnswerCount;
  final VoidCallback? onExportExperiences;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  String? _authError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _runAuth(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() {
      _busy = true;
      _authError = null;
    });
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      setState(() => _authError = '$e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _logout() async {
    setState(() => _busy = true);
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃되었습니다.')),
      );
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '설정',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onSurface),
              ),
              const SizedBox(height: 22),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: '계정',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    if (auth.isLoggedIn) ...[
                      _InfoRow(label: '이메일', value: auth.email ?? '-'),
                      const Divider(height: 22, color: AppColors.outlineVariant),
                      _InfoRow(label: 'User ID', value: auth.userId ?? '-'),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _logout,
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('로그아웃'),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '이메일',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '비밀번호 (8자 이상)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      if (_authError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _authError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12.5),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: _busy
                                ? null
                                : () => _runAuth(
                                      () => ref.read(authProvider.notifier).login(
                                            _email.text,
                                            _password.text,
                                          ),
                                      successMessage: '로그인되었습니다.',
                                    ),
                            child: const Text('로그인'),
                          ),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => _runAuth(
                                      () => ref.read(authProvider.notifier).register(
                                            _email.text,
                                            _password.text,
                                          ),
                                      successMessage: '회원가입 및 로그인되었습니다.',
                                    ),
                            child: const Text('회원가입'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '로그인하지 않으면 개발용 로컬 User ID로 요청합니다.'.softWrapWords(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: '백엔드 연결',
                      icon: Icons.cloud_outlined,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'API Base URL', value: AppConfig.apiBaseUrl),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(
                      label: '인증 모드',
                      value: auth.isLoggedIn ? 'JWT Bearer' : 'Soft X-User-Id',
                    ),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(label: '로컬 Soft ID', value: UserIdentity.forRequest),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    const _InfoRow(
                      label: 'API 키',
                      value: '클라이언트에 노출하지 않습니다.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: '데이터',
                      icon: Icons.storage_outlined,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: '경험 카드', value: '${widget.experienceCount}개'),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(label: '스펙', value: '${widget.specCount}개'),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(label: '면접 답변', value: '${widget.interviewAnswerCount}개'),
                    const Divider(height: 22, color: AppColors.outlineVariant),
                    const _InfoRow(
                      label: '코치 채팅',
                      value: '서버 chat-rooms에 모드별로 저장됩니다.',
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: widget.onExportExperiences,
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('경험·스펙 합본 내보내기'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                backgroundColor: AppColors.coachingTint.withValues(alpha: 0.55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      title: '개인정보·RAG',
                      icon: Icons.privacy_tip_outlined,
                      accent: AppColors.coaching,
                      accentTint: AppColors.surface,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '벡터DB에는 Experience 요약·역할·스킬·성과 메타를 올립니다. '
                      'AI는 선택한 경험과 검색된 경험만 근거로 답합니다.'.softWrapWords(),
                      style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(title: '앱 정보', icon: Icons.info_outline),
                    SizedBox(height: 12),
                    _InfoRow(
                      label: 'JasoSupporter',
                      value: '취업 준비 워크스페이스',
                    ),
                    Divider(height: 22, color: AppColors.outlineVariant),
                    _InfoRow(label: '테마', value: '블루 계열 Material 3 / ProductSans'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
