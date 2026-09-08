import 'package:chatgptmini/domain/models/backend_health.dart';
import 'package:chatgptmini/features/home/backend_health_banner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backendHealthBannerMessage warns on connection error', () {
    expect(
      backendHealthBannerMessage(hasError: true),
      contains('백엔드에 연결할 수 없습니다'),
    );
  });

  test('backendHealthBannerMessage warns when ollama not ready', () {
    final String? message = backendHealthBannerMessage(
      health: const BackendHealth(
        status: 'ok',
        geminiEnabled: false,
        authRequired: false,
        llmProvider: 'none',
        ollamaConfigured: false,
      ),
    );
    expect(message, contains('Ollama'));
  });

  test('backendHealthBannerMessage warns when auth required but logged out', () {
    expect(
      backendHealthBannerMessage(
        health: const BackendHealth(
          status: 'ok',
          geminiEnabled: false,
          authRequired: true,
          llmProvider: 'ollama',
          ollamaConfigured: true,
        ),
        isLoggedIn: false,
      ),
      contains('JWT 인증'),
    );
  });

  test('backendHealthBannerMessage warns when jwt secret not configured', () {
    expect(
      backendHealthBannerMessage(
        health: const BackendHealth(
          status: 'ok',
          geminiEnabled: false,
          authRequired: false,
          jwtSecretConfigured: false,
          llmProvider: 'ollama',
          ollamaConfigured: true,
        ),
      ),
      contains('JWT_SECRET'),
    );
  });

  test('backendHealthBannerMessage is null when healthy', () {
    expect(
      backendHealthBannerMessage(
        health: const BackendHealth(
          status: 'ok',
          geminiEnabled: false,
          authRequired: false,
          jwtSecretConfigured: true,
          llmProvider: 'ollama',
          ollamaConfigured: true,
          localModel: 'jaso-coach',
        ),
      ),
      isNull,
    );
  });
}
