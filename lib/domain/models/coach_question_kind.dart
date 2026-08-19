import 'package:chatgptmini/core/constants/jaso_constants.dart';
import 'package:chatgptmini/data/services/assistant_prompts.dart';

/// 코치 입력창에서 고르는 질문/작업 종류.
class CoachQuestionKind {
  const CoachQuestionKind({
    required this.id,
    required this.label,
    this.promptTemplate,
    this.hint,
  });

  final String id;
  final String label;

  /// null이면 자유 질문(사용자 입력만 전송).
  final String? promptTemplate;
  final String? hint;

  bool get isFreeform => promptTemplate == null;

  /// 사용자 입력과 템플릿을 합쳐 실제 전송 텍스트를 만든다.
  String composeMainText(String userInput) {
    final String main = userInput.trim();
    final String? template = promptTemplate;
    if (template == null || template.trim().isEmpty) {
      return main;
    }
    if (main.isEmpty) {
      return template.trim();
    }
    return '${template.trim()}\n\n[추가 요청]\n$main';
  }

  static const CoachQuestionKind freeform = CoachQuestionKind(
    id: 'freeform',
    label: '자유 질문',
    hint: '원하는 내용을 자유롭게 입력하세요.',
  );

  static List<CoachQuestionKind> forMode(AssistantMode mode) {
    switch (mode) {
      case AssistantMode.experienceSpec:
        return const [
          freeform,
          CoachQuestionKind(
            id: 'star',
            label: 'STAR로 정리',
            hint: '경험 카드용 STAR 라벨 형식으로 구조화합니다.',
            promptTemplate:
                '이 내용을 경험 카드로 저장할 수 있게 아래 라벨 형식으로만 구조화해 주세요. '
                '없는 사실은 만들지 마세요.\n'
                '제목:\n기관:\n역할:\n기간: (yy.mm-yy.mm)\n상황:\n과제:\n행동:\n성과:\n배운 점:',
          ),
          CoachQuestionKind(
            id: 'gaps',
            label: '보완 질문',
            hint: '부족한 정보를 짧은 질문으로 받습니다.',
            promptTemplate: '지금 입력만으로 부족한 정보를 보완 질문으로 짧게 물어봐 주세요.',
          ),
        ];
      case AssistantMode.masterResume:
        return [
          freeform,
          const CoachQuestionKind(
            id: 'match',
            label: '경험 매칭',
            hint: '현재 문항에 맞는 저장 경험을 추천합니다.',
            promptTemplate:
                '현재 문항에 적합한 저장된 경험만 골라 id·title·reason 형식으로 추천해 주세요. '
                '없는 경험은 만들지 마세요. 추천이 없으면 "추천 없음"만 쓰세요.',
          ),
          const CoachQuestionKind(
            id: 'draft',
            label: '초안 생성',
            hint: '선택 경험 사실만 근거로, 의미·표현은 확장해 초안을 씁니다.',
            promptTemplate:
                '선택한 경험만 근거로 현재 문항 초안을 작성해 주세요. '
                '행동·결과·수치 등 사실은 Experience에 있는 것만 쓰고, '
                '강점·인사이트·두괄식 전개·차별화 관점은 사실 위에서 확장해 주세요. '
                'STAR를 그대로 요약하지 마세요. 없는 사실은 만들지 마세요.',
          ),
          const CoachQuestionKind(
            id: 'review',
            label: '첨삭',
            hint: '과장·키워드 나열 없이 첨삭합니다.',
            promptTemplate: '현재 초안을 과장·키워드 나열 없이 첨삭해 주세요.',
          ),
          for (final MasterQuestionCopy q in MasterQuestionCopy.all)
            CoachQuestionKind(
              id: 'q_${q.id.toLowerCase()}',
              label: q.id,
              hint: q.title,
              promptTemplate:
                  '[${q.id} 초안 작성 요청]\n${q.body}\n'
                  '선택한 경험만 근거로 초안을 작성해 주세요. '
                  '사실(행동·결과·수치)은 Experience에 있는 것만 쓰고, '
                  '강점·인사이트·두괄식·차별화는 사실 위에서 확장해 주세요. '
                  'STAR 요약-only는 피하세요. 없는 사실은 만들지 마세요. '
                  '글자 수 목표: ${q.charHint}',
            ),
        ];
      case AssistantMode.portfolio:
        return const [
          freeform,
          CoachQuestionKind(
            id: 'outline',
            label: '개요 보완',
            hint: '포지셔닝·목차·섹션 불릿만 다룹니다.',
            promptTemplate:
                '한 줄 포지셔닝과 목차·섹션 불릿만으로 포트폴리오 개요를 보완해 주세요. 시각 레이아웃은 다루지 마세요.',
          ),
          CoachQuestionKind(
            id: 'bullets',
            label: '섹션 불릿',
            hint: '경험 기준 섹션별 불릿만 제안합니다.',
            promptTemplate: '선택한 경험 기준으로 섹션별 불릿만 제안해 주세요.',
          ),
        ];
      case AssistantMode.interview:
        return const [
          freeform,
          CoachQuestionKind(
            id: 'questions',
            label: '예상 질문',
            hint: '선택 경험 STAR만 근거로 예상 질문을 만듭니다.',
            promptTemplate:
                '선택한 경험 STAR만 근거로 면접 예상 질문을 번호 목록으로 작성해 주세요. '
                '없는 사실은 만들지 마세요.',
          ),
          CoachQuestionKind(
            id: 'answer',
            label: '답변 초안',
            hint: 'STAR 근거로 방어 가능한 답변을 씁니다.',
            promptTemplate:
                '선택한 경험 STAR만 근거로 방어 가능한 면접 답변 초안을 작성해 주세요.',
          ),
          CoachQuestionKind(
            id: 'defense',
            label: '방어 점검',
            hint: '과장·허위 위험을 짚고 고칩니다.',
            promptTemplate:
                '이 답변에서 과장·허위 위험이 있는 문장을 짚고 방어 가능한 표현으로 고쳐 주세요.',
          ),
        ];
    }
  }

  static CoachQuestionKind resolve(AssistantMode mode, String? id) {
    final List<CoachQuestionKind> kinds = forMode(mode);
    if (id == null || id.isEmpty) {
      return kinds.first;
    }
    for (final CoachQuestionKind kind in kinds) {
      if (kind.id == id) {
        return kind;
      }
    }
    return kinds.first;
  }
}
