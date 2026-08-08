import 'package:chatgptmini/core/constants/jaso_constants.dart';
import 'package:chatgptmini/data/services/prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('master question prompt keeps selected experience context explicit', () {
    final String prompt = const PromptBuilder().masterQuestionDraftRequest(
      question: MasterQuestionCopy.all.first,
      index0Based: 0,
      userDraft: '사용자 초안',
      targetJob: '물류 영업',
      selectedExperienceIds: const ['exp-1'],
      selectedExperienceContext: '[이 문항에 선택한 Experience 카드]\n- id: exp-1\n  제목: 프로젝트',
    );

    expect(prompt, contains('[지원 희망 직무]'));
    expect(prompt, contains('[선택한 Experience IDs]'));
    expect(prompt, contains('exp-1'));
    expect(prompt, contains('사용자 초안'));
  });

  test('experience labeled STAR request includes parseable labels', () {
    final String prompt = const PromptBuilder().experienceLabeledStarRequest('동아리 메모');
    expect(prompt, contains('동아리 메모'));
    expect(prompt, contains('제목:'));
    expect(prompt, contains('상황:'));
    expect(prompt, contains('행동:'));
    expect(prompt, contains('배운 점:'));
  });
}
