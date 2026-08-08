import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';

/// 저장된 경험·스펙을 내보내기용 텍스트로 직렬화한다.
class ExperienceExportBuilder {
  const ExperienceExportBuilder._();

  static String buildSavedContent({
    required List<Experience> experiences,
    required List<SpecItem> specs,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('=== 경험 카드 ===');
    for (final Experience experience in experiences) {
      buffer.writeln('제목: ${experience.title}');
      buffer.writeln('유형: ${experience.type.name}');
      buffer.writeln('기간: ${experience.period}');
      buffer.writeln('조직: ${experience.organization}');
      buffer.writeln('역할: ${experience.role}');
      buffer.writeln('Situation: ${experience.situation}');
      buffer.writeln('Task: ${experience.task}');
      buffer.writeln('Action: ${experience.action}');
      buffer.writeln('Result: ${experience.result}');
      buffer.writeln('Learned: ${experience.learned}');
      if (experience.techStacks.isNotEmpty) {
        buffer.writeln('기술: ${experience.techStacks.join(', ')}');
      }
      if (experience.competencyTags.isNotEmpty) {
        buffer.writeln('역량: ${experience.competencyTags.join(', ')}');
      }
      buffer.writeln('---');
    }
    buffer.writeln();
    buffer.writeln('=== 스펙 ===');
    for (final SpecItem spec in specs) {
      buffer.writeln('${spec.type.name} | ${spec.title}: ${spec.value}');
      if (spec.issuedAt.trim().isNotEmpty) {
        buffer.writeln('발급/취득: ${spec.issuedAt}');
      }
      buffer.writeln('---');
    }
    return buffer.toString();
  }
}
