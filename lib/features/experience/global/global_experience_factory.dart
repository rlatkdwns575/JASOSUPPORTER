import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';

/// 글로벌 경험 입력 값을 Experience로 조립한다.
abstract final class GlobalExperienceFactory {
  static String _join(List<String> parts) {
    return parts
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .join(' · ');
  }

  static String _title({
    required String kindLabel,
    required String place,
    required String organization,
  }) {
    if (organization.trim().isNotEmpty && place.trim().isNotEmpty) {
      return _join(<String>[kindLabel, place, organization]);
    }
    if (organization.trim().isNotEmpty) {
      return _join(<String>[kindLabel, organization]);
    }
    if (place.trim().isNotEmpty) {
      return _join(<String>[kindLabel, place]);
    }
    return kindLabel;
  }

  static Experience workingHoliday({
    required String place,
    String workplace = '',
    String activity = '',
    String language = '',
    DateTime? start,
    DateTime? end,
    String situation = '',
    String task = '',
    String action = '',
    String result = '',
    String learned = '',
    List<String> competencyTags = const <String>[],
    List<String> evidenceLinks = const <String>[],
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String org =
        workplace.trim().isNotEmpty ? workplace.trim() : place.trim();
    return Experience(
      id: 'global_wh_${stamp.microsecondsSinceEpoch}',
      title: _title(
        kindLabel: '워킹홀리데이',
        place: place,
        organization: workplace,
      ),
      type: ExperienceType.trainingAbroad,
      period: DateRange(start: start, end: end),
      organization: org.isNotEmpty ? org : '워킹홀리데이',
      role: _join(<String>[activity, language]),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static Experience languageTraining({
    required String place,
    String institute = '',
    String course = '',
    String language = '',
    DateTime? start,
    DateTime? end,
    String situation = '',
    String task = '',
    String action = '',
    String result = '',
    String learned = '',
    List<String> competencyTags = const <String>[],
    List<String> evidenceLinks = const <String>[],
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String org =
        institute.trim().isNotEmpty ? institute.trim() : place.trim();
    return Experience(
      id: 'global_lang_${stamp.microsecondsSinceEpoch}',
      title: _title(
        kindLabel: '어학연수',
        place: place,
        organization: institute,
      ),
      type: ExperienceType.trainingAbroad,
      period: DateRange(start: start, end: end),
      organization: org.isNotEmpty ? org : '어학연수',
      role: _join(<String>[course, language]),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static Experience exchange({
    required String place,
    String university = '',
    String program = '',
    String major = '',
    DateTime? start,
    DateTime? end,
    String situation = '',
    String task = '',
    String action = '',
    String result = '',
    String learned = '',
    List<String> competencyTags = const <String>[],
    List<String> evidenceLinks = const <String>[],
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    final String org =
        university.trim().isNotEmpty ? university.trim() : place.trim();
    return Experience(
      id: 'global_exchange_${stamp.microsecondsSinceEpoch}',
      title: _title(
        kindLabel: '교환학생',
        place: place,
        organization: university,
      ),
      type: ExperienceType.trainingAbroad,
      period: DateRange(start: start, end: end),
      organization: org.isNotEmpty ? org : '교환학생',
      role: _join(<String>[program, major]),
      situation: situation.trim(),
      task: task.trim(),
      action: action.trim(),
      result: result.trim(),
      learned: learned.trim(),
      techStacks: const <String>[],
      competencyTags: competencyTags,
      evidenceLinks: evidenceLinks,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
