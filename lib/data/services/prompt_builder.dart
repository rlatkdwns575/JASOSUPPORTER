import 'package:chatgptmini/assistant_prompts.dart';
import 'package:chatgptmini/domain/models/chat_models.dart';
import 'package:chatgptmini/jaso_constants.dart';

class PromptBuilder {
  const PromptBuilder();

  String experienceTableRequest(String payload) {
    return "$payload\n\n"
        "위 내용을 경험정리 마크다운 표로 정리하고, 부족한 수치·기간·Tool은 질문으로 보완해줘.";
  }

  String experienceRecommendationRequest(String payload) {
    return "$payload\n\n"
        "위 내용을 바탕으로 추천 직무, 직종, 산업, 기업명 예시를 제안해줘.";
  }

  String experienceNarrativeMergeRequest(String payload) {
    return "$payload\n\n"
        "위 항목들을 표 없이 하나의 자연스러운 서술형 글로만 통합해줘. 없음으로 적힌 항목은 생략하거나 한 줄로 처리해줘.";
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
      buffer.writeln("[사용자 자료함 — 아래 칸에 붙여 둔 최신 내용]");
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

    if ((mode == AssistantMode.masterResume || mode == AssistantMode.portfolio) &&
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
