import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// E10 확인 대기 중인 경험·스펙과 직전 저장 개수.
class CareerDraftState {
  const CareerDraftState({
    this.pendingExperiences = const <Experience>[],
    this.pendingSpecs = const <SpecItem>[],
    this.lastSavedCount = 0,
    this.lastSavedExperienceIds = const <String>[],
    this.lastFormCategory,
    this.lastFormSubtype,
  });

  final List<Experience> pendingExperiences;
  final List<SpecItem> pendingSpecs;
  final int lastSavedCount;

  /// E11 완료 화면에서 자소서·면접으로 넘길 직전 저장 Experience id.
  final List<String> lastSavedExperienceIds;

  /// 확인·완료 후 입력 화면으로 돌아갈 때 쓰는 쿼리 값.
  final String? lastFormCategory;
  final String? lastFormSubtype;

  bool get isEmpty => pendingExperiences.isEmpty && pendingSpecs.isEmpty;

  int get pendingCount => pendingExperiences.length + pendingSpecs.length;

  String get formReturnPath {
    final String? category = lastFormCategory?.trim();
    final String? subtype = lastFormSubtype?.trim();
    if (category != null && category.isNotEmpty) {
      if (subtype != null && subtype.isNotEmpty) {
        return AppRoutes.experienceFormSubtype(category, subtype);
      }
      return AppRoutes.experienceFormCategory(category);
    }
    return AppRoutes.experience;
  }

  CareerDraftState copyWith({
    List<Experience>? pendingExperiences,
    List<SpecItem>? pendingSpecs,
    int? lastSavedCount,
    List<String>? lastSavedExperienceIds,
    String? lastFormCategory,
    String? lastFormSubtype,
    bool clearFormFocus = false,
  }) {
    return CareerDraftState(
      pendingExperiences: pendingExperiences ?? this.pendingExperiences,
      pendingSpecs: pendingSpecs ?? this.pendingSpecs,
      lastSavedCount: lastSavedCount ?? this.lastSavedCount,
      lastSavedExperienceIds:
          lastSavedExperienceIds ?? this.lastSavedExperienceIds,
      lastFormCategory:
          clearFormFocus ? null : (lastFormCategory ?? this.lastFormCategory),
      lastFormSubtype:
          clearFormFocus ? null : (lastFormSubtype ?? this.lastFormSubtype),
    );
  }
}

/// 경험·스펙 저장 전 확인용 초안 상태.
class CareerDraftNotifier extends Notifier<CareerDraftState> {
  @override
  CareerDraftState build() => const CareerDraftState();

  void rememberFormFocus({String? category, String? subtype}) {
    final String? cat = category?.trim();
    if (cat == null || cat.isEmpty) {
      return;
    }
    state = state.copyWith(
      lastFormCategory: cat,
      lastFormSubtype: subtype?.trim().isEmpty == true ? null : subtype?.trim(),
    );
  }

  void setPending({
    required List<Experience> experiences,
    required List<SpecItem> specItems,
  }) {
    state = state.copyWith(
      pendingExperiences: List<Experience>.from(experiences),
      pendingSpecs: List<SpecItem>.from(specItems),
    );
  }

  void setExperienceDraft(Experience draft) {
    state = state.copyWith(
      pendingExperiences: [draft],
      pendingSpecs: const <SpecItem>[],
    );
  }

  /// 확인 화면에서 대기 중인 경험 카드를 교체한다.
  void updatePendingExperience(Experience updated) {
    final List<Experience> next = state.pendingExperiences
        .map((Experience e) => e.id == updated.id ? updated : e)
        .toList(growable: false);
    final bool replaced = next.any((Experience e) => e.id == updated.id);
    state = state.copyWith(
      pendingExperiences: replaced ? next : [...state.pendingExperiences, updated],
    );
  }

  /// 확인 화면에서 대기 중인 스펙을 교체한다.
  void updatePendingSpec(SpecItem updated) {
    final List<SpecItem> next = state.pendingSpecs
        .map((SpecItem s) => s.id == updated.id ? updated : s)
        .toList(growable: false);
    final bool replaced = next.any((SpecItem s) => s.id == updated.id);
    state = state.copyWith(
      pendingSpecs: replaced ? next : [...state.pendingSpecs, updated],
    );
  }

  /// 저장 성공 후 pending을 비우고 lastSavedCount를 갱신한다.
  void markSaved() {
    state = CareerDraftState(
      lastSavedCount: state.pendingCount,
      lastSavedExperienceIds: [
        for (final Experience e in state.pendingExperiences) e.id,
      ],
      lastFormCategory: state.lastFormCategory,
      lastFormSubtype: state.lastFormSubtype,
    );
  }

  void clearPending() {
    state = state.copyWith(
      pendingExperiences: const <Experience>[],
      pendingSpecs: const <SpecItem>[],
    );
  }
}

final careerDraftProvider =
    NotifierProvider<CareerDraftNotifier, CareerDraftState>(CareerDraftNotifier.new);
