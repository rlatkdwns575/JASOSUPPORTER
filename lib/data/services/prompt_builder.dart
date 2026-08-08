import 'package:chatgptmini/data/services/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:chatgptmini/core/constants/jaso_constants.dart';

class PromptBuilder {
  const PromptBuilder();

  /// 앱이 Experience로 파싱할 수 있는 라벨 블록 형식.
  static const String labeledStarFormatGuide =
      "반드시 아래 라벨을 한 줄씩 쓰고, 각 라벨 다음 줄에 내용만 적어 주세요. "
      "없는 사실은 만들지 말고, 모르면 해당 라벨 아래를 비우거나 '없음'이라고 적으세요.\n"
      "제목:\n"
      "기관:\n"
      "역할:\n"
      "기간: (yy.mm-yy.mm)\n"
      "상황:\n"
      "과제:\n"
      "행동:\n"
      "성과:\n"
      "배운 점:";

  String experienceTableRequest(String payload) {
    return "$payload\n\n"
        "위 내용을 경험정리 마크다운 표로 정리하고, 부족한 수치·기간·Tool은 질문으로 보완해줘.\n"
        "표 아래에 동일 내용을 다음 라벨 형식으로도 한 번 더 적어 주세요.\n"
        "$labeledStarFormatGuide";
  }

  String experienceRecommendationRequest(String payload) {
    return "$payload\n\n"
        "위 내용을 바탕으로 추천 직무, 직종, 산업, 기업명 예시를 제안해줘. "
        "사용자가 말하지 않은 경력은 만들지 마세요.";
  }

  String experienceNarrativeMergeRequest(String payload) {
    return "$payload\n\n"
        "위 항목들을 표 없이 STAR 라벨 형식으로만 통합해 주세요. "
        "없음으로 적힌 항목은 생략하거나 '없음'으로 처리하세요.\n"
        "$labeledStarFormatGuide";
  }

  String experienceLabeledStarRequest(String payload) {
    return "$payload\n\n"
        "위 내용을 경험 카드로 바로 저장할 수 있게 STAR 라벨 형식으로 구조화해 주세요.\n"
        "$labeledStarFormatGuide";
  }

  String masterQuestionDraftRequest({
    required MasterQuestionCopy question,
    required int index0Based,
    required String userDraft,
    required String targetJob,
    required List<String> selectedExperienceIds,
    required String selectedExperienceContext,
  }) {
    final String jobBlock = targetJob.trim().isEmpty ? "" : "[지원 희망 직무]\n${targetJob.trim()}\n\n";
    final String draft = userDraft.trim().isEmpty ? "(없음)" : userDraft.trim();
    final String selectedIdsBlock = selectedExperienceIds.isEmpty
        ? ""
        : "[선택한 Experience IDs]\n${selectedExperienceIds.join(", ")}\n\n";
    final String selectedContextBlock = selectedExperienceContext.trim().isEmpty
        ? ""
        : "$selectedExperienceContext\n\n";
    return "$jobBlock$selectedIdsBlock$selectedContextBlock[Q${index0Based + 1} 초안 작성 요청]\n"
        "문항: ${question.body} (${question.charHint}, 공백 포함)\n"
        "사용자 메모:\n$draft";
  }

  String masterFullReviewRequest({
    required String fullDraft,
    required String targetJob,
  }) {
    final String jobBlock = targetJob.trim().isEmpty ? "" : "[지원 희망 직무]\n${targetJob.trim()}\n\n";
    return "$jobBlock[전체 초고 첨삭]\n${fullDraft.trim()}";
  }

  /// 현재 문항에 맞는 Experience 매칭 추천 요청.
  String masterExperienceMatchRequest({
    required MasterQuestionCopy question,
    required int index0Based,
    required String targetJob,
    required List<ExperienceSummaryLine> experiences,
  }) {
    final String jobBlock =
        targetJob.trim().isEmpty ? "" : "[지원 희망 직무]\n${targetJob.trim()}\n\n";
    final StringBuffer catalog = StringBuffer();
    catalog.writeln("[저장된 Experience 목록 — 이 목록에 있는 항목만 추천]");
    if (experiences.isEmpty) {
      catalog.writeln("(저장된 경험 없음)");
    } else {
      for (final ExperienceSummaryLine e in experiences) {
        catalog.writeln("- id: ${e.id}");
        catalog.writeln("  title: ${e.title}");
        if (e.organization.isNotEmpty) {
          catalog.writeln("  organization: ${e.organization}");
        }
        if (e.role.isNotEmpty) {
          catalog.writeln("  role: ${e.role}");
        }
      }
    }
    return "$jobBlock$catalog\n"
        "[Q${index0Based + 1} 경험 매칭 추천]\n"
        "문항: ${question.body}\n"
        "위 목록에서 이 문항에 적합한 경험만 골라 주세요. 없는 경험은 만들지 마세요.\n"
        "출력 형식(항목당):\n"
        "- id: <experience id>\n"
        "  title: <제목>\n"
        "  reason: <한 줄 근거>\n"
        "추천할 경험이 없으면 \"추천 없음\"만 쓰세요.";
  }

  String buildChatPrompt({
    required AssistantMode mode,
    required List<ChatMessage> chats,
    required String attachmentText,
    required List<String> binaryFileNames,
    required String targetJob,
    required String experienceContext,
  }) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln("[시스템 역할 및 형식 규칙]");
    buffer.writeln(systemPromptFor(mode));
    buffer.writeln();

    final String attachment = attachmentText.trim();
    if (attachment.isNotEmpty) {
      buffer.writeln("[사용자 첨부 자료]");
      buffer.writeln(attachment);
      buffer.writeln();
    }

    if (binaryFileNames.isNotEmpty) {
      buffer.writeln(
        "[멀티모달 첨부] 이 요청의 텍스트 직후에 동일 순서로 ${binaryFileNames.length}개의 "
        "바이너리 파트(이미지 또는 PDF)가 전달된다. 파일명: "
        "${binaryFileNames.join(", ")}",
      );
      buffer.writeln();
    }

    if (mode == AssistantMode.masterResume && targetJob.trim().isNotEmpty) {
      buffer.writeln("[지원 희망 직무 — 앱 작성란]");
      buffer.writeln(targetJob.trim());
      buffer.writeln();
    }

    if ((mode == AssistantMode.masterResume ||
            mode == AssistantMode.portfolio ||
            mode == AssistantMode.interview) &&
        experienceContext.trim().isNotEmpty) {
      buffer.writeln(experienceContext.trim());
      buffer.writeln();
    }

    buffer.writeln("위 규칙과 참고 데이터를 지키고, 아래 대화 맥락을 참고해 마지막 사용자 메시지에 답변한다.");
    buffer.writeln();
    buffer.writeln("[이전 대화 기록]");

    for (final ChatMessage chat in chats) {
      final String role = chat.isMe ? "사용자" : "AI";
      final String text = chat.text.trim();
      if (text.isEmpty) {
        continue;
      }
      buffer.writeln("$role: $text");
    }

    buffer.writeln();
    buffer.writeln("[답변 시 유의]");
    buffer.writeln("- 대화 맥락을 반영하고, 마지막 사용자 요청을 최우선으로 처리한다.");
    buffer.writeln("- 불필요한 전체 요약은 하지 않는다.");

    return buffer.toString();
  }
}

/// 매칭 프롬프트용 경험 요약.
class ExperienceSummaryLine {
  const ExperienceSummaryLine({
    required this.id,
    required this.title,
    this.organization = '',
    this.role = '',
  });

  final String id;
  final String title;
  final String organization;
  final String role;
}
