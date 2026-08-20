import 'package:chatgptmini/domain/models/gemini_model_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeminiModelOption', () {
    test('fromIds merges known metadata and unknown ids', () {
      final List<GeminiModelOption> options = GeminiModelOption.fromIds([
        'gemini-2.5-flash',
        'gemini-3.6-flash',
        'custom-model-x',
      ]);
      expect(options.map((GeminiModelOption o) => o.id), [
        'gemini-2.5-flash',
        'gemini-3.6-flash',
        'custom-model-x',
      ]);
      expect(options.first.label, 'Gemini 2.5 Flash');
      expect(options.last.label, contains('Custom'));
    });
  });

  group('GeminiModelsCatalog', () {
    test('fromJson includes default model and provider', () {
      final GeminiModelsCatalog catalog = GeminiModelsCatalog.fromJson({
        'provider': 'ollama',
        'defaultModel': 'jaso-coach',
        'models': ['jaso-coach', 'qwen2.5:7b-instruct'],
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
