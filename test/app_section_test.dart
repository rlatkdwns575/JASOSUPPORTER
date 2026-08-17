import 'package:chatgptmini/app/app_section.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/features/experience/experience_hub_panel.dart';
import 'package:chatgptmini/features/experience/experience_subtype.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appSectionForLocation', () {
    test('maps core routes', () {
      expect(appSectionForLocation('/home'), AppSection.home);
      expect(appSectionForLocation('/experience/form'), AppSection.experience);
      expect(appSectionForLocation('/master-resume'), AppSection.masterResume);
      expect(appSectionForLocation('/portfolio/preview/1'), AppSection.portfolio);
      expect(appSectionForLocation('/interview/answer'), AppSection.interview);
      expect(appSectionForLocation('/applications'), AppSection.applications);
      expect(appSectionForLocation('/settings'), AppSection.settings);
    });
  });

  group('assistantModeForLocation', () {
    test('maps assistant modes', () {
      expect(assistantModeForLocation('/experience'), AssistantMode.experienceSpec);
      expect(assistantModeForLocation('/master-resume'), AssistantMode.masterResume);
      expect(assistantModeForLocation('/portfolio'), AssistantMode.portfolio);
      expect(assistantModeForLocation('/applications'), AssistantMode.portfolio);
      expect(assistantModeForLocation('/interview'), AssistantMode.interview);
    });
  });

  group('ExperienceCategory query', () {
    test('round-trips category query values', () {
      expect(ExperienceCategory.campus.queryValue, 'campus');
      expect(ExperienceCategoryCopy.fromQuery('campus'), ExperienceCategory.campus);
      expect(ExperienceCategoryCopy.fromQuery('EXTERNAL'), ExperienceCategory.external);
      expect(ExperienceCategoryCopy.fromQuery('spec'), ExperienceCategory.spec);
      expect(ExperienceCategoryCopy.fromQuery(null), isNull);
      expect(ExperienceCategoryCopy.fromQuery('unknown'), isNull);
    });
  });

  group('ExperienceSubtype query', () {
    test('spec subtypes map under spec category', () {
      final subtypes = ExperienceSubtypeCopy.forCategory(ExperienceCategory.spec);
      expect(subtypes.map((s) => s.name), [
        'highSchool',
        'university',
        'gradSchool',
        'certificate',
        'language',
        'scholarship',
        'volunteer',
        'otherSpec',
      ]);
      expect(
        ExperienceSubtypeCopy.fromQuery('university')?.category,
        ExperienceCategory.spec,
      );
    });
  });

  group('workspaceHeaderCopy', () {
    test('uses form-specific title', () {
      final copy = workspaceHeaderCopy(
        section: AppSection.experience,
        location: '/experience/form',
      );
      expect(copy.title, '경험 입력');
    });
  });
}
