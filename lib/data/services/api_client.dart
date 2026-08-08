import 'dart:async';
import 'dart:convert';

import 'package:chatgptmini/core/config/app_config.dart';
import 'package:chatgptmini/core/config/auth_session.dart';
import 'package:chatgptmini/core/config/user_identity.dart';
import 'package:http/http.dart' as http;

/// FastAPI 백엔드와 통신하는 저수준 HTTP 클라이언트.
///
/// - JSON GET/POST/DELETE 헬퍼
/// - `/chat` 등 SSE 응답을 텍스트 청크 스트림으로 변환
/// - JWT가 있으면 `Authorization: Bearer`, 없으면 개발용 `X-User-Id`
class ApiClient {
  ApiClient({
    String? baseUrl,
    String? userId,
    String? accessToken,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        userId = userId ?? AuthSession.userId ?? UserIdentity.forRequest,
        accessToken = accessToken ?? AuthSession.accessToken,
        _client = httpClient ?? http.Client();

  final String baseUrl;
  final String userId;
  final String? accessToken;
  final http.Client _client;

  Map<String, String> _headers({bool jsonBody = false, bool sse = false}) {
    final Map<String, String> headers = <String, String>{
      'Accept': sse ? 'text/event-stream' : 'application/json',
      if (jsonBody) 'Content-Type': 'application/json',
    };
    final String? token = accessToken?.trim();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers['X-User-Id'] = userId;
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final String normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final http.Response response = await _client.get(
      _uri(path, query),
      headers: _headers(),
    );
    return _decode(response);
  }

  Future<dynamic> postJson(String path, Object body) async {
    final http.Response response = await _client.post(
      _uri(path),
      headers: _headers(jsonBody: true),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<void> delete(String path) async {
    final http.Response response = await _client.delete(
      _uri(path),
      headers: _headers(),
    );
    _ensureOk(response.statusCode, response.body);
  }

  Stream<String> streamSse(String path, Object body) async* {
    final http.Request request = http.Request('POST', _uri(path))
      ..headers.addAll(_headers(jsonBody: true, sse: true))
      ..body = jsonEncode(body);

    final http.StreamedResponse response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String errorBody = await response.stream.bytesToString();
      throw ApiException(response.statusCode, errorBody);
    }

    final Stream<String> lines =
        response.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final String line in lines) {
      if (!line.startsWith('data:')) {
        continue;
      }
      final String data = line.substring(5).trim();
      if (data.isEmpty) {
        continue;
      }
      final Object? decoded = jsonDecode(data);
      if (decoded is! Map) {
        continue;
      }
      if (decoded['done'] == true) {
        return;
      }
      final Object? chunk = decoded['t'];
      if (chunk is String && chunk.isNotEmpty) {
        yield chunk;
      }
    }
  }

  dynamic _decode(http.Response response) {
    _ensureOk(response.statusCode, response.body);
    if (response.body.trim().isEmpty) {
      return null;
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  void _ensureOk(int statusCode, String body) {
    if (statusCode < 200 || statusCode >= 300) {
      throw ApiException(statusCode, body);
    }
  }

  void close() {
    _client.close();
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
