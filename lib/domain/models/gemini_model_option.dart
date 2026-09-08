/// 클라이언트가 고를 수 있는 LLM 모델 옵션 (Ollama).
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
      id: 'jaso-coach',
      label: 'Jaso Coach',
      subtitle: '로컬 Ollama · QLoRA 자소서 코치',
    ),
    GeminiModelOption(
      id: 'qwen3:1.7b',
      label: 'Qwen3 1.7B',
      subtitle: '로컬 Ollama 베이스',
    ),
  ];

  static const String defaultId = 'jaso-coach';

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
        .split(RegExp(r'[-:]'))
        .where((String part) => part.isNotEmpty)
        .map((String part) {
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
    this.provider = 'ollama',
  });

  final String defaultModel;
  final List<GeminiModelOption> models;
  final String provider;

  bool get isOllama => provider == 'ollama';

  static const GeminiModelsCatalog fallback = GeminiModelsCatalog(
    defaultModel: GeminiModelOption.defaultId,
    models: GeminiModelOption.defaults,
  );

  factory GeminiModelsCatalog.fromJson(Map<String, dynamic> json) {
    final Object? defaultRaw = json['defaultModel'] ?? json['default_model'];
    final Object? modelsRaw = json['models'];
    final String provider = json['provider']?.toString() ?? 'ollama';
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
      provider: provider,
    );
  }
}
