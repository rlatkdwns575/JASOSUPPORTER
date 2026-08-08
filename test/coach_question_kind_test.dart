import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/coach_question_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoachQuestionKind', () {
    test('composeMainText uses template when input empty', () {
      const CoachQuestionKind kind = CoachQuestionKind(
        id: 'star',
        label: 'STAR',
        promptTemplate: '템플릿 본문',
      );
      expect(kind.composeMainText(''), '템플릿 본문');
      expect(
        kind.composeMainText('추가'),
        '템플릿 본문\n\n[추가 요청]\n추가',
      );
    });

    test('forMode includes freeform and mode-specific kinds', () {
      final List<CoachQuestionKind> experience =
          CoachQuestionKind.forMode(AssistantMode.experienceSpec);
      expect(experience.first.id, 'freeform');
      expect(experience.map((CoachQuestionKind k) => k.id), contains('star'));

      final List<CoachQuestionKind> master =
          CoachQuestionKind.forMode(AssistantMode.masterResume);
      expect(master.map((CoachQuestionKind k) => k.id), contains('q_q1'));
    });
  });
}
