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
    test('fromJson includes default model', () {
      final GeminiModelsCatalog catalog = GeminiModelsCatalog.fromJson({
        'defaultModel': 'gemini-3.6-flash',
        'models': ['gemini-2.5-flash', 'gemini-2.5-pro'],
      });
      expect(catalog.defaultModel, 'gemini-3.6-flash');
      expect(
        catalog.models.map((GeminiModelOption o) => o.id),
        contains('gemini-3.6-flash'),
      );
    });
  });
}
