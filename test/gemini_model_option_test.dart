import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeminiModelOption', () {
    test('fromIds merges known metadata and unknown ids', () {
      final List<GeminiModelOption> options = GeminiModelOption.fromIds([
        'jaso-coach',
        'qwen3:1.7b',
        'custom-model-x',
      ]);
      expect(options.map((GeminiModelOption o) => o.id), [
        'jaso-coach',
        'qwen3:1.7b',
        'custom-model-x',
      ]);
      expect(options.first.label, 'Jaso Coach');
      expect(options.last.label, contains('Custom'));
    });
  });

  group('GeminiModelsCatalog', () {
    test('fromJson includes default model and provider', () {
      final GeminiModelsCatalog catalog = GeminiModelsCatalog.fromJson({
        'provider': 'ollama',
        'defaultModel': 'jaso-coach',
        'models': ['jaso-coach', 'qwen3:1.7b'],
      });
      expect(catalog.defaultModel, 'jaso-coach');
      expect(catalog.isOllama, isTrue);
      expect(
        catalog.models.map((GeminiModelOption o) => o.id),
        contains('jaso-coach'),
      );
    });
  });
}
