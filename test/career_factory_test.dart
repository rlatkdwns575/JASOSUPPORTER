import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/features/experience/experience_export_builder.dart';
import 'package:chatgptmini/features/interview/interview_prompt_planner.dart';
import 'package:chatgptmini/features/interview/interview_workspace_controller.dart';
import 'package:chatgptmini/features/portfolio/portfolio_project_factory.dart';
import 'package:flutter_test/flutter_test.dart';

Experience _sampleExperience({
  String id = 'exp-1',
  String title = '프로젝트',
  ExperienceType type = ExperienceType.project,
}) {
  return Experience(
    id: id,
    title: title,
    type: type,
    period: DateRange(start: DateTime(2024, 1), end: DateTime(2024, 6)),
    organization: '동아리',
    role: '팀장',
    situation: '상황',
    task: '과제',
    action: '행동',
    result: '결과',
    learned: '배움',
    techStacks: const ['Flutter'],
    competencyTags: const ['리더십'],
    evidenceLinks: const ['https://example.com'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('InterviewWorkspaceController buildAnswer requires body', () {
    final InterviewWorkspaceController c = InterviewWorkspaceController();
    addTearDown(c.dispose);
    c.question.text = '강점?';
    final InterviewAnswerBuildResult empty =
        c.buildAnswer(sourceExperienceIds: const ['e1']);
    expect(empty.isOk, isFalse);

    c.answer.text = '  근거 기반 답변  ';
    final InterviewAnswerBuildResult ok = c.buildAnswer(
      sourceExperienceIds: const ['e1'],
      now: DateTime(2026, 7, 29),
    );
    expect(ok.isOk, isTrue);
    expect(ok.answer!.question, '강점?');
    expect(ok.answer!.answer, '근거 기반 답변');
    expect(ok.answer!.sourceExperienceIds, ['e1']);
  });

  test('InterviewWorkspaceController draft/polish plans delegate to planner', () {
    final InterviewWorkspaceController c = InterviewWorkspaceController();
    addTearDown(c.dispose);
    const InterviewPromptPlanner planner = InterviewPromptPlanner();
    expect(c.draftAnswerPlan(planner).canSend, isFalse);
    c.question.text = '협업 경험?';
    expect(c.draftAnswerPlan(planner).canSend, isTrue);
    c.answer.text = '답';
    expect(c.polishAnswerPlan(planner).canSend, isTrue);
  });

  test('PortfolioProjectFactory.fromExperience maps STAR fields', () {
    final project = PortfolioProjectFactory.fromExperience(
      _sampleExperience(),
      now: DateTime(2026, 7, 29),
    );
    expect(project.title, '프로젝트');
    expect(project.linkedExperienceIds, ['exp-1']);
    expect(project.role, '팀장');
    expect(project.problem, '상황');
    expect(project.solution, '행동');
    expect(project.result, '결과');
    expect(project.portfolioCopy, contains('소속/기관: 동아리'));
    expect(project.portfolioCopy, contains('과제: 과제'));
    expect(project.portfolioCopy, contains('배운 점: 배움'));
  });

  test('ExperienceExportBuilder includes experience and spec sections', () {
    final String text = ExperienceExportBuilder.buildSavedContent(
      experiences: [
        _sampleExperience(title: '인턴', type: ExperienceType.internship),
      ],
      specs: const [],
    );
    expect(text, contains('=== 경험 카드 ==='));
    expect(text, contains('제목: 인턴'));
    expect(text, contains('=== 스펙 ==='));
  });
}
