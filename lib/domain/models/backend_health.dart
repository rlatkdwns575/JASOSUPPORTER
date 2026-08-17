/// FastAPI `/health` 응답.
class BackendHealth {
  const BackendHealth({
    required this.status,
    required this.geminiEnabled,
    required this.pineconeEnabled,
    required this.authRequired,
    required this.pineconeDimensionMismatch,
    this.embeddingModel,
    this.embeddingDimension,
    this.genaiSdk,
  });

  final String status;
  final bool geminiEnabled;
  final bool pineconeEnabled;
  final bool authRequired;
  final bool pineconeDimensionMismatch;
  final String? embeddingModel;
  final int? embeddingDimension;
  final String? genaiSdk;

  bool get isOk => status == 'ok';

  factory BackendHealth.fromJson(Map<String, dynamic> json) {
    return BackendHealth(
      status: '${json['status'] ?? ''}',
      geminiEnabled: json['gemini'] == true,
      pineconeEnabled: json['pinecone'] == true,
      authRequired: json['authRequired'] == true,
      pineconeDimensionMismatch: json['pineconeDimensionMismatch'] == true,
      embeddingModel: json['embeddingModel']?.toString(),
      embeddingDimension: _readInt(json['embeddingDimension']),
      genaiSdk: json['genaiSdk']?.toString(),
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
}
