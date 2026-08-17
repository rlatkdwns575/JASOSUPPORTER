import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/data/providers/career_draft_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CareerDraftState.formReturnPath', () {
    test('returns subtype path when both focus values exist', () {
      const CareerDraftState state = CareerDraftState(
        lastFormCategory: 'campus',
        lastFormSubtype: 'club',
      );
      expect(
        state.formReturnPath,
        AppRoutes.experienceFormSubtype('campus', 'club'),
      );
    });

    test('returns category path when subtype missing', () {
      const CareerDraftState state = CareerDraftState(
        lastFormCategory: 'spec',
      );
      expect(state.formReturnPath, AppRoutes.experienceFormCategory('spec'));
    });

    test('falls back to experience hub', () {
      expect(const CareerDraftState().formReturnPath, AppRoutes.experience);
    });
  });
}
