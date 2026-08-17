import 'dart:convert';

import 'package:chatgptmini/data/services/api_client.dart';

/// API 오류를 사용자에게 보여줄 한국어 메시지로 변환한다.
String apiErrorMessage(Object error) {
  if (error is ApiException) {
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
