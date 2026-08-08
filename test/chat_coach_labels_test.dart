import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/core/widgets/chat_first_shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coachActionLabelsFor covers all modes', () {
    expect(coachActionLabelsFor(AssistantMode.experienceSpec).save, contains('경험'));
    expect(coachActionLabelsFor(AssistantMode.masterResume).apply, contains('초안'));
    expect(coachActionLabelsFor(AssistantMode.portfolio).save, contains('개요'));
    expect(coachActionLabelsFor(AssistantMode.interview).apply, contains('답변'));
  });

  test('coachHintForMode and muted meta', () {
    expect(coachHintForMode(AssistantMode.interview), contains('예상 질문'));
    expect(settingsMutedCoachMeta().muted, isTrue);
  });
}
