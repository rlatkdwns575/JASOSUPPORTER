import 'package:chatgptmini/domain/models/backend_health.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BackendHealth.fromJson parses health payload', () {
    final BackendHealth health = BackendHealth.fromJson(<String, dynamic>{
      'status': 'ok',
      'gemini': true,
      'pinecone': false,
      'authRequired': false,
      'pineconeDimensionMismatch': true,
      'embeddingModel': 'models/text-embedding-004',
      'embeddingDimension': 512,
      'genaiSdk': 'google-genai',
    });

    expect(health.isOk, isTrue);
    expect(health.geminiEnabled, isTrue);
    expect(health.pineconeDimensionMismatch, isTrue);
    expect(health.embeddingDimension, 512);
    expect(health.statusLabel, '연결됨 (Pinecone 차원 불일치)');
    expect(health.embeddingLabel, contains('512'));
    expect(health.authRequiredLabel, 'Soft ID 허용');
  });

  test('BackendHealth authRequiredLabel reflects server mode', () {
    final BackendHealth strict = BackendHealth.fromJson(<String, dynamic>{
      'status': 'ok',
      'gemini': true,
      'pinecone': true,
      'authRequired': true,
      'pineconeDimensionMismatch': false,
    });
    expect(strict.authRequiredLabel, 'JWT 필수');
  });
}
