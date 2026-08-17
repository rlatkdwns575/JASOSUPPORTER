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

  test('backendHealthBannerMessage warns on pinecone dimension mismatch', () {
    final String? message = backendHealthBannerMessage(
      health: const BackendHealth(
        status: 'ok',
        geminiEnabled: true,
        pineconeEnabled: false,
        authRequired: false,
        pineconeDimensionMismatch: true,
      ),
    );
    expect(message, contains('Pinecone'));
  });

  test('backendHealthBannerMessage warns when gemini disabled', () {
    final String? message = backendHealthBannerMessage(
      health: const BackendHealth(
        status: 'ok',
        geminiEnabled: false,
        pineconeEnabled: true,
        authRequired: false,
        pineconeDimensionMismatch: false,
      ),
    );
    expect(message, contains('Gemini'));
  });

  test('backendHealthBannerMessage is null when healthy', () {
    expect(
      backendHealthBannerMessage(
        health: const BackendHealth(
          status: 'ok',
          geminiEnabled: true,
          pineconeEnabled: true,
          authRequired: false,
          pineconeDimensionMismatch: false,
        ),
      ),
      isNull,
    );
  });
}
