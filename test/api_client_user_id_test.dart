import 'dart:convert';

import 'package:chatgptmini/core/config/user_identity.dart';
import 'package:chatgptmini/data/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  tearDown(() {
    UserIdentity.debugSet(null);
  });

  test('ApiClient sends X-User-Id on GET', () async {
    UserIdentity.debugSet('user_test_abc');
    String? seenUserId;
    final MockClient mock = MockClient((http.Request request) async {
      seenUserId = request.headers['X-User-Id'];
      return http.Response(jsonEncode(<String, Object?>{'ok': true}), 200);
    });

    final ApiClient client = ApiClient(
      baseUrl: 'http://localhost:8000',
      userId: UserIdentity.forRequest,
      httpClient: mock,
    );
    await client.getJson('/health');
    expect(seenUserId, 'user_test_abc');
    client.close();
  });

  test('ApiClient invokes onUnauthorized for 401 responses', () async {
    int unauthorizedCalls = 0;
    final MockClient mock = MockClient((http.Request request) async {
      return http.Response('{"detail":"Invalid or expired token"}', 401);
    });

    final ApiClient client = ApiClient(
      baseUrl: 'http://localhost:8000',
      httpClient: mock,
      onUnauthorized: () => unauthorizedCalls += 1,
    );

    await expectLater(
      client.getJson('/experiences'),
      throwsA(isA<ApiException>()),
    );
    expect(unauthorizedCalls, 1);
    client.close();
  });

  test('ApiClient streamSse invokes onUnauthorized for 401 responses', () async {
    int unauthorizedCalls = 0;
    final MockClient mock = MockClient((http.Request request) async {
      return http.Response('{"detail":"Authorization Bearer token required"}', 401);
    });

    final ApiClient client = ApiClient(
      baseUrl: 'http://localhost:8000',
      httpClient: mock,
      onUnauthorized: () => unauthorizedCalls += 1,
    );

    await expectLater(
      client.streamSse('/chat', <String, Object?>{}).toList(),
      throwsA(isA<ApiException>()),
    );
    expect(unauthorizedCalls, 1);
    client.close();
  });
}
