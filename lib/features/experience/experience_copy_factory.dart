import 'package:chatgptmini/domain/models/experience.dart';

/// Experience 복제본 생성.
class ExperienceCopyFactory {
  const ExperienceCopyFactory._();

  static Experience duplicate(Experience experience, {DateTime? now}) {
    final DateTime stamp = now ?? DateTime.now();
    return experience.copyWith(
      id: '${experience.id}_copy_${stamp.microsecondsSinceEpoch}',
      title: '${experience.title} 복사본',
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
