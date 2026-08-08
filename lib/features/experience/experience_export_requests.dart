import 'package:chatgptmini/app/shell_action_result.dart';
import 'package:chatgptmini/data/services/export_service.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/features/experience/experience_export_builder.dart';

/// 경험·스펙 export 요청 생성. 실패 시 [error], 성공 시 [request].
class ExperienceExportOutcome {
  const ExperienceExportOutcome._({this.error, this.request});

  ExperienceExportOutcome.fail(String snack)
      : this._(error: ShellActionResult(snack: snack));

  const ExperienceExportOutcome.ok(ExportRequest request)
      : this._(request: request);

  final ShellActionResult? error;
  final ExportRequest? request;

  bool get isOk => request != null;
}

class ExperienceExportRequests {
  const ExperienceExportRequests._();

  static ExperienceExportOutcome formMerged(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return ExperienceExportOutcome.fail('입력 폼이 비어 있습니다.');
    }
    return ExperienceExportOutcome.ok(
      ExportRequest(
        defaultBaseName: 'experience_spec',
        content: payload,
        artifactType: ExportArtifactType.experienceSummary,
        title: '경험·스펙 합본',
      ),
    );
  }

  static ExperienceExportOutcome saved({
    required List<Experience> experiences,
    required List<SpecItem> specs,
  }) {
    if (experiences.isEmpty && specs.isEmpty) {
      return ExperienceExportOutcome.fail('내보낼 경험·스펙이 없습니다.');
    }
    return ExperienceExportOutcome.ok(
      ExportRequest(
        defaultBaseName: 'saved_experiences',
        content: ExperienceExportBuilder.buildSavedContent(
          experiences: experiences,
          specs: specs,
        ),
        artifactType: ExportArtifactType.experienceSummary,
        title: '저장된 경험·스펙',
      ),
    );
  }
}
