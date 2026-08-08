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
}
