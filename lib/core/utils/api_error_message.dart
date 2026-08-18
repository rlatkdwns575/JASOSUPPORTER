import 'dart:async';
import 'dart:convert';

import 'package:chatgptmini/data/services/api_client.dart';

/// API 오류를 사용자에게 보여줄 한국어 메시지로 변환한다.
String apiErrorMessage(Object error) {
  if (error is TimeoutException) {
    return '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해 주세요.';
  }
  if (error is ApiException) {
    if (error.statusCode == 401) {
      return _unauthorizedMessage(error);
    }
    try {
      final Object? decoded = jsonDecode(error.body);
      if (decoded is Map) {
        final Object? detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail.trim();
        }
        if (detail is List && detail.isNotEmpty) {
          final Object first = detail.first;
          if (first is Map && first['msg'] != null) {
            return '${first['msg']}';
          }
        }
      }
    } catch (_) {
      // JSON 파싱 실패 시 아래 기본 메시지 사용
    }
  }
  return '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

String _unauthorizedMessage(ApiException error) {
  try {
    final Object? decoded = jsonDecode(error.body);
    if (decoded is Map) {
      final Object? detail = decoded['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        final String message = detail.trim();
        if (message.contains('이메일') || message.contains('비밀번호')) {
          return message;
        }
      }
    }
  } catch (_) {
    // JSON 파싱 실패 시 아래 기본 메시지 사용
  }
  return '로그인이 만료되었거나 인증이 필요합니다. 설정에서 다시 로그인해 주세요.';
}

/// 저장·삭제 등 작업 실패 스낵바에 쓰는 `접두사: 원인` 형식.
String actionErrorMessage(String prefix, Object error) {
  return '$prefix: ${apiErrorMessage(error)}';
}
