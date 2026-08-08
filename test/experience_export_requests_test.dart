import 'package:chatgptmini/features/experience/experience_export_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceExportRequests', () {
    test('formMerged rejects empty payload', () {
      expect(ExperienceExportRequests.formMerged(null).isOk, isFalse);
      expect(ExperienceExportRequests.formMerged('   ').isOk, isFalse);
    });

    test('formMerged builds request', () {
      final ExperienceExportOutcome outcome =
          ExperienceExportRequests.formMerged('payload');
      expect(outcome.isOk, isTrue);
      expect(outcome.request!.content, 'payload');
      expect(outcome.request!.defaultBaseName, 'experience_spec');
    });

    test('saved rejects empty lists', () {
      expect(
        ExperienceExportRequests.saved(experiences: const [], specs: const []).isOk,
        isFalse,
      );
    });
  });
}
