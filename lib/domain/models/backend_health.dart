/// FastAPI `/health` 응답.
class BackendHealth {
  const BackendHealth({
    required this.status,
    required this.geminiEnabled,
    required this.authRequired,
    this.jwtSecretConfigured = true,
    this.genaiSdk,
    this.llmProvider = 'ollama',
    this.ollamaConfigured = true,
    this.cloudAiEnabled = false,
    this.localModel,
  });

  final String status;
  final bool geminiEnabled;
  final bool authRequired;
  final bool jwtSecretConfigured;
  final String? genaiSdk;
  final String llmProvider;
  final bool ollamaConfigured;
  final bool cloudAiEnabled;
  final String? localModel;

  bool get isOk => status == 'ok';

  bool get isLocalLlm => llmProvider == 'ollama';

  factory BackendHealth.fromJson(Map<String, dynamic> json) {
    return BackendHealth(
      status: '${json['status'] ?? ''}',
      geminiEnabled: json['gemini'] == true,
      authRequired: json['authRequired'] == true,
      jwtSecretConfigured: json['jwtSecretConfigured'] != false,
      genaiSdk: json['genaiSdk']?.toString(),
      llmProvider: json['llmProvider']?.toString() ?? 'ollama',
      ollamaConfigured: json['ollamaConfigured'] != false,
      cloudAiEnabled: json['cloudAiEnabled'] == true,
      localModel: json['localModel']?.toString(),
    );
  }

  String get statusLabel {
    if (!isOk) {
      return '비정상';
    }
    return '정상';
  }

  String get geminiLabel => geminiEnabled ? '활성' : '비활성 (키 없음)';

  String get authRequiredLabel => authRequired ? 'JWT 필수' : 'Soft ID 허용';

  String get llmProviderLabel {
    if (isLocalLlm) {
      final String model = localModel ?? 'jaso-coach';
      return '로컬 (Ollama · $model)';
    }
    return '미설정';
  }

  String get cloudAiLabel => '비활성 — 로컬 Ollama만 사용';
}
