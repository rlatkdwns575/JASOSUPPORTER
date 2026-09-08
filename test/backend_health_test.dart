import 'package:chatgptmini/domain/models/backend_health.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BackendHealth.fromJson parses health payload', () {
    final BackendHealth health = BackendHealth.fromJson(<String, dynamic>{
      'status': 'ok',
      'gemini': false,
      'authRequired': false,
      'genaiSdk': null,
      'llmProvider': 'ollama',
      'ollamaConfigured': true,
      'cloudAiEnabled': false,
      'localModel': 'jaso-coach',
    });

    expect(health.isOk, isTrue);
    expect(health.geminiEnabled, isFalse);
    expect(health.statusLabel, '정상');
    expect(health.authRequiredLabel, 'Soft ID 허용');
    expect(health.isLocalLlm, isTrue);
    expect(health.llmProviderLabel, contains('Ollama'));
    expect(health.cloudAiLabel, contains('로컬 Ollama'));
  });

  test('BackendHealth authRequiredLabel reflects server mode', () {
    final BackendHealth strict = BackendHealth.fromJson(<String, dynamic>{
      'status': 'ok',
      'gemini': false,
      'authRequired': true,
      'llmProvider': 'ollama',
      'ollamaConfigured': true,
    });
    expect(strict.authRequiredLabel, 'JWT 필수');
  });
}
