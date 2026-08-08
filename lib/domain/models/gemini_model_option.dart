/// 클라이언트가 고를 수 있는 Gemini 모델 옵션.
class GeminiModelOption {
  const GeminiModelOption({
    required this.id,
    required this.label,
    this.subtitle = '',
  });

  final String id;
  final String label;
  final String subtitle;

  /// UI·오프라인 폴백용 기본 목록 (서버 `/models`와 맞춤).
  static const List<GeminiModelOption> defaults = [
    GeminiModelOption(
      id: 'gemini-2.5-flash',
      label: 'Gemini 2.5 Flash',
      subtitle: '빠르고 가벼운 기본 모델',
    ),
    GeminiModelOption(
      id: 'gemini-2.5-pro',
      label: 'Gemini 2.5 Pro',
      subtitle: '더 깊은 추론·긴 문서',
    ),
    GeminiModelOption(
      id: 'gemini-2.0-flash',
      label: 'Gemini 2.0 Flash',
      subtitle: '빠른 응답',
    ),
    GeminiModelOption(
      id: 'gemini-1.5-flash',
      label: 'Gemini 1.5 Flash',
      subtitle: '경량',
    ),
    GeminiModelOption(
      id: 'gemini-1.5-pro',
      label: 'Gemini 1.5 Pro',
      subtitle: '고품질',
    ),
    GeminiModelOption(
      id: 'gemini-3.6-flash',
      label: 'Gemini 3.6 Flash',
      subtitle: '서버 기본(환경 설정)',
    ),
  ];

  static const String defaultId = 'gemini-2.5-flash';

  static GeminiModelOption? findById(String id) {
    for (final GeminiModelOption option in defaults) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  static String displayLabel(String id) {
    return findById(id)?.label ?? _prettyId(id);
  }

  /// 서버 id 목록을 UI 옵션으로 변환한다. 알려진 메타가 없으면 id를 예쁘게 표시.
  static List<GeminiModelOption> fromIds(Iterable<String> ids) {
    final List<GeminiModelOption> out = [];
    final Set<String> seen = <String>{};
    for (final String raw in ids) {
      final String id = raw.trim();
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      out.add(findById(id) ?? GeminiModelOption(id: id, label: _prettyId(id)));
    }
    return out.isEmpty ? defaults : out;
  }

  static String _prettyId(String id) {
    final String trimmed = id.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed
        .replaceAll('models/', '')
        .split('-')
        .map((String part) {
          if (part.isEmpty) {
            return part;
          }
          if (RegExp(r'^\d').hasMatch(part)) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }
}

/// `/models` 응답.
class GeminiModelsCatalog {
  const GeminiModelsCatalog({
    required this.defaultModel,
    required this.models,
  });

  final String defaultModel;
  final List<GeminiModelOption> models;

  static const GeminiModelsCatalog fallback = GeminiModelsCatalog(
    defaultModel: GeminiModelOption.defaultId,
    models: GeminiModelOption.defaults,
  );

  factory GeminiModelsCatalog.fromJson(Map<String, dynamic> json) {
    final Object? defaultRaw = json['defaultModel'] ?? json['default_model'];
    final Object? modelsRaw = json['models'];
    final List<String> ids = <String>[];
    if (modelsRaw is List) {
      for (final Object? item in modelsRaw) {
        if (item is String && item.trim().isNotEmpty) {
          ids.add(item.trim());
        }
      }
    }
    final String defaultModel = (defaultRaw is String && defaultRaw.trim().isNotEmpty)
        ? defaultRaw.trim()
        : (ids.isNotEmpty ? ids.first : GeminiModelOption.defaultId);
    if (!ids.contains(defaultModel)) {
      ids.insert(0, defaultModel);
    }
    return GeminiModelsCatalog(
      defaultModel: defaultModel,
      models: GeminiModelOption.fromIds(ids),
    );
  }
}
