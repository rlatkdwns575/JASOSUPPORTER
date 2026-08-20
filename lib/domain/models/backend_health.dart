/// FastAPI `/health` 응답.
class BackendHealth {
  const BackendHealth({
    required this.status,
    required this.geminiEnabled,
    required this.pineconeEnabled,
    required this.authRequired,
    required this.pineconeDimensionMismatch,
    this.jwtSecretConfigured = true,
    this.embeddingModel,
    this.embeddingDimension,
    this.genaiSdk,
    this.llmProvider = 'gemini',
    this.ollamaConfigured = false,
    this.cloudAiEnabled = true,
    this.localModel,
  });

  final String status;
  final bool geminiEnabled;
  final bool pineconeEnabled;
  final bool authRequired;
  final bool pineconeDimensionMismatch;
  final bool jwtSecretConfigured;
  final String? embeddingModel;
  final int? embeddingDimension;
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
      pineconeEnabled: json['pinecone'] == true,
      authRequired: json['authRequired'] == true,
      pineconeDimensionMismatch: json['pineconeDimensionMismatch'] == true,
      jwtSecretConfigured: json['jwtSecretConfigured'] != false,
      embeddingModel: json['embeddingModel']?.toString(),
      embeddingDimension: _readInt(json['embeddingDimension']),
      genaiSdk: json['genaiSdk']?.toString(),
      llmProvider: json['llmProvider']?.toString() ?? 'gemini',
      ollamaConfigured: json['ollamaConfigured'] == true,
      cloudAiEnabled: json['cloudAiEnabled'] != false,
      localModel: json['localModel']?.toString(),
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  String get statusLabel {
    if (!isOk) {
      return '비정상';
    }
    if (pineconeDimensionMismatch) {
      return '연결됨 (Pinecone 차원 불일치)';
    }
    return '정상';
  }

  String get geminiLabel => geminiEnabled ? '활성' : '비활성 (키 없음)';

  String get pineconeLabel {
    if (!pineconeEnabled) {
      return '비활성 (키 없음 또는 차원 불일치)';
    }
    return '활성';
  }

  String get embeddingLabel {
    final String model = embeddingModel ?? '-';
    final String dim = embeddingDimension?.toString() ?? '-';
    return '$model · $dim차원';
  }

  String get authRequiredLabel => authRequired ? 'JWT 필수' : 'Soft ID 허용';

  String get llmProviderLabel {
    if (isLocalLlm) {
      final String model = localModel ?? 'jaso-coach';
      return '로컬 (Ollama · $model)';
    }
    return '클라우드 (Gemini)';
  }

  String get cloudAiLabel {
    if (isLocalLlm && !cloudAiEnabled) {
      return '비활성 — 외부 AI 미전송';
    }
    if (cloudAiEnabled && geminiEnabled) {
      return '활성 — 첨부·폴백 시 Gemini';
    }
    if (!cloudAiEnabled) {
      return '비활성';
    }
    return '키 없음';
  }
}
