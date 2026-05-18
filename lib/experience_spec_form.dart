import 'package:chatgptmini/app_colors.dart';
import 'package:chatgptmini/core/widgets/app_components.dart';
import 'package:chatgptmini/domain/enums/experience_type.dart';
import 'package:chatgptmini/domain/models/date_range.dart';
import 'package:chatgptmini/domain/models/experience.dart';
import 'package:chatgptmini/domain/models/spec_item.dart';
import 'package:chatgptmini/jaso_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _ActivityKind { clubLike, contest, abroad }

/// 경험·스펙 구조화 입력 폼.
class ExperienceSpecForm extends StatefulWidget {
  const ExperienceSpecForm({
    super.key,
    required this.enabled,
    required this.onAiTable,
    required this.onAiRecommend,
    required this.onMergeToAttachment,
    required this.onExportMerged,
    required this.onAiNarrativeMerge,
    required this.onSaveStructured,
  });

  final bool enabled;
  final void Function(String payload) onAiTable;
  final void Function(String payload) onAiRecommend;
  final void Function(String payload) onAiNarrativeMerge;
  final void Function(String merged) onMergeToAttachment;
  final VoidCallback onExportMerged;
  final Future<void> Function(List<Experience> experiences, List<SpecItem> specItems) onSaveStructured;

  @override
  State<ExperienceSpecForm> createState() => ExperienceSpecFormState();
}

class ExperienceSpecFormState extends State<ExperienceSpecForm> {
  final TextEditingController cHighSchool = TextEditingController();
  final TextEditingController cUniversity = TextEditingController();
  final TextEditingController cGradSchool = TextEditingController();

  final TextEditingController cMajorMain = TextEditingController();
  final TextEditingController cMajorMinor = TextEditingController();
  final TextEditingController cMajorDouble = TextEditingController();

  final TextEditingController cGpaScore = TextEditingController();
  final TextEditingController cGpaFullMarkOther = TextEditingController();

  final List<_CertItem> _certItems = [];

  /// 만점 선택값. `기타`일 때는 [cGpaFullMarkOther]에 숫자 입력.
  String _gpaFullMarkChoice = "4.5";

  final List<ActCtrls> _clubs = [];
  final List<ActCtrls> _campus = [];
  final List<ActCtrls> _interns = [];
  final List<ActCtrls> _parttimes = [];
  final List<ActCtrls> _contests = [];
  final List<ActCtrls> _dx = [];
  final List<ActCtrls> _abroad = [];
  final TextEditingController cEtc = TextEditingController();

  static const List<String> _gpaFullMarkOptions = [
    "4.5",
    "4.3",
    "4.0",
    "100",
    "기타",
  ];

  @override
  void dispose() {
    cHighSchool.dispose();
    cUniversity.dispose();
    cGradSchool.dispose();
    cMajorMain.dispose();
    cMajorMinor.dispose();
    cMajorDouble.dispose();
    cGpaScore.dispose();
    cGpaFullMarkOther.dispose();
    _disposeActList(_clubs);
    _disposeActList(_campus);
    _disposeActList(_interns);
    _disposeActList(_parttimes);
    _disposeActList(_contests);
    _disposeActList(_dx);
    _disposeActList(_abroad);
    cEtc.dispose();
    super.dispose();
  }

  void _disposeActList(List<ActCtrls> list) {
    for (final ActCtrls a in list) {
      a.dispose();
    }
  }

  void _addAct(List<ActCtrls> list) {
    setState(() => list.add(ActCtrls()));
  }

  void _removeAct(List<ActCtrls> list, int index) {
    if (index < 0 || index >= list.length) {
      return;
    }
    setState(() {
      list[index].dispose();
      list.removeAt(index);
    });
  }

  bool _actHasContent(ActCtrls a) {
    return a.primary.text.trim().isNotEmpty ||
        a.secondary.text.trim().isNotEmpty ||
        a.tertiary.text.trim().isNotEmpty ||
        a.body.text.trim().isNotEmpty ||
        a.monthStart != null ||
        a.monthEnd != null;
  }

  String _slug(String raw) {
    final String value = raw.trim().toLowerCase();
    if (value.isEmpty) {
      return "untitled";
    }
    return value.replaceAll(RegExp(r"[^a-z0-9가-힣]+"), "_").replaceAll(RegExp(r"_+"), "_");
  }

  String _experienceId(String prefix, int index, ActCtrls a) {
    final String titleSeed = a.primary.text.trim().isNotEmpty
        ? a.primary.text
        : a.secondary.text.trim().isNotEmpty
        ? a.secondary.text
        : prefix;
    return "draft_${prefix}_${index + 1}_${_slug(titleSeed)}";
  }

  Experience _clubLikeExperience({
    required String prefix,
    required int index,
    required ActCtrls source,
    required ExperienceType type,
    required String fallbackTitle,
    String organization = "",
    String role = "",
  }) {
    final DateTime now = DateTime.now();
    final String title = source.primary.text.trim().isEmpty ? fallbackTitle : source.primary.text.trim();
    return Experience(
      id: _experienceId(prefix, index, source),
      title: title,
      type: type,
      period: DateRange(start: source.monthStart, end: source.monthEnd),
      organization: organization.isEmpty ? source.primary.text.trim() : organization,
      role: role,
      situation: "",
      task: "",
      action: source.body.text.trim(),
      result: "",
      learned: "",
      techStacks: const [],
      competencyTags: const [],
      evidenceLinks: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  List<Experience> _clubLikeExperiences({
    required String prefix,
    required List<ActCtrls> sources,
    required ExperienceType type,
    required String fallbackTitle,
    String role = "",
  }) {
    final List<Experience> items = [];
    for (int i = 0; i < sources.length; i++) {
      final ActCtrls source = sources[i];
      if (!_actHasContent(source)) {
        continue;
      }
      items.add(
        _clubLikeExperience(
          prefix: prefix,
          index: i,
          source: source,
          type: type,
          fallbackTitle: fallbackTitle,
          role: role,
        ),
      );
    }
    return items;
  }

  List<Experience> toExperiences() {
    final List<Experience> experiences = [
      ..._clubLikeExperiences(
        prefix: "club",
        sources: _clubs,
        type: ExperienceType.club,
        fallbackTitle: "동아리 경험",
      ),
      ..._clubLikeExperiences(
        prefix: "campus",
        sources: _campus,
        type: ExperienceType.campusActivity,
        fallbackTitle: "교내 경험",
      ),
      ..._clubLikeExperiences(
        prefix: "internship",
        sources: _interns,
        type: ExperienceType.internship,
        fallbackTitle: "인턴십",
      ),
      ..._clubLikeExperiences(
        prefix: "parttime",
        sources: _parttimes,
        type: ExperienceType.partTime,
        fallbackTitle: "아르바이트",
      ),
      ..._clubLikeExperiences(
        prefix: "project",
        sources: _dx,
        type: ExperienceType.project,
        fallbackTitle: "부트캠프·프로젝트",
      ),
    ];

    for (int i = 0; i < _contests.length; i++) {
      final ActCtrls source = _contests[i];
      if (!_actHasContent(source)) {
        continue;
      }
      final DateTime now = DateTime.now();
      experiences.add(
        Experience(
          id: _experienceId("contest", i, source),
          title: source.primary.text.trim().isEmpty ? "공모전" : source.primary.text.trim(),
          type: ExperienceType.contest,
          period: DateRange(start: source.monthStart, end: source.monthEnd),
          organization: source.primary.text.trim(),
          role: source.secondary.text.trim(),
          situation: "",
          task: "",
          action: source.body.text.trim(),
          result: source.secondary.text.trim(),
          learned: "",
          techStacks: const [],
          competencyTags: const [],
          evidenceLinks: const [],
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    for (int i = 0; i < _abroad.length; i++) {
      final ActCtrls source = _abroad[i];
      if (!_actHasContent(source)) {
        continue;
      }
      final DateTime now = DateTime.now();
      experiences.add(
        Experience(
          id: _experienceId("abroad", i, source),
          title: source.tertiary.text.trim().isEmpty ? "어학연수·교환학생" : source.tertiary.text.trim(),
          type: ExperienceType.trainingAbroad,
          period: DateRange(start: source.monthStart, end: source.monthEnd),
          organization: source.tertiary.text.trim(),
          role: source.secondary.text.trim(),
          situation: "",
          task: "",
          action: source.body.text.trim(),
          result: "",
          learned: "",
          techStacks: const [],
          competencyTags: const [],
          evidenceLinks: const [],
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    return experiences;
  }

  List<SpecItem> toSpecItems() {
    final DateTime now = DateTime.now();
    final List<SpecItem> specs = [];

    void addSpec(SpecItemType type, String title, String value, {String issuedAt = ""}) {
      if (value.trim().isEmpty) {
        return;
      }
      specs.add(
        SpecItem(
          id: "draft_spec_${type.name}_${specs.length + 1}_${_slug(title)}",
          type: type,
          title: title,
          value: value.trim(),
          issuedAt: issuedAt.trim(),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    addSpec(SpecItemType.school, "고등학교", cHighSchool.text);
    addSpec(SpecItemType.school, "대학교", cUniversity.text);
    addSpec(SpecItemType.school, "대학원", cGradSchool.text);
    addSpec(SpecItemType.major, "주전공", cMajorMain.text);
    addSpec(SpecItemType.major, "부전공", cMajorMinor.text);
    addSpec(SpecItemType.major, "복수전공", cMajorDouble.text);
    if (cGpaScore.text.trim().isNotEmpty) {
      addSpec(SpecItemType.gpa, "평균 학점", "${cGpaScore.text.trim()} / ${_resolvedFullMark()}");
    }
    for (final _CertItem cert in _certItems) {
      addSpec(SpecItemType.certificate, cert.name, cert.name, issuedAt: cert.date);
    }

    return specs;
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? kNoneHint,
      alignLabelWithHint: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  String _resolvedFullMark() {
    if (_gpaFullMarkChoice == "기타") {
      final String o = cGpaFullMarkOther.text.trim();
      return o.isEmpty ? "(만점 미입력)" : o;
    }
    return _gpaFullMarkChoice;
  }

  String _lineOrNone(String raw) {
    final String t = raw.trim();
    return t.isEmpty ? "없음" : t;
  }

  String _fmtYearMonth(DateTime? d) {
    if (d == null) {
      return "";
    }
    final String y = d.year.toString().padLeft(4, '0');
    final String m = d.month.toString().padLeft(2, '0');
    return "$y.$m";
  }

  String _periodPayload(ActCtrls a) {
    final String s = _fmtYearMonth(a.monthStart);
    final String e = _fmtYearMonth(a.monthEnd);
    if (s.isEmpty && e.isEmpty) {
      return "";
    }
    if (s.isNotEmpty && e.isNotEmpty) {
      return "$s ~ $e";
    }
    if (s.isNotEmpty) {
      return "$s ~ ";
    }
    return "~ $e";
  }

  Future<DateTime?> _pickYearMonth(
    BuildContext context, {
    DateTime? initial,
    required String helpText,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime init = initial ?? DateTime(now.year, now.month);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(1980, 1),
      lastDate: DateTime(2038, 12),
      helpText: helpText,
      cancelText: "취소",
      confirmText: "확인",
      builder: (BuildContext ctx, Widget? child) {
        return Theme(
          data: Theme.of(ctx).copyWith(colorScheme: AppColors.colorScheme),
          child: child!,
        );
      },
    );
    if (picked == null) {
      return null;
    }
    return DateTime(picked.year, picked.month);
  }

  void _writeClubLikeEntry(StringBuffer b, String primaryFieldLabel, ActCtrls a, int index) {
    b.writeln("  [$index]");
    b.writeln("    $primaryFieldLabel: ${_lineOrNone(a.primary.text)}");
    b.writeln("    시기: ${_lineOrNone(_periodPayload(a))}");
    b.writeln("    내용: ${_lineOrNone(a.body.text)}");
  }

  void _writeClubLikeSection(StringBuffer b, String sectionTitle, String primaryFieldLabel, List<ActCtrls> list) {
    b.writeln(sectionTitle);
    final List<ActCtrls> filled = list.where(_actHasContent).toList();
    if (filled.isEmpty) {
      b.writeln("  (없음)");
      return;
    }
    for (int i = 0; i < filled.length; i++) {
      _writeClubLikeEntry(b, primaryFieldLabel, filled[i], i + 1);
    }
  }

  void _writeContestSection(StringBuffer b, List<ActCtrls> list) {
    b.writeln("공모전");
    final List<ActCtrls> filled = list.where(_actHasContent).toList();
    if (filled.isEmpty) {
      b.writeln("  (없음)");
      return;
    }
    for (int i = 0; i < filled.length; i++) {
      final ActCtrls a = filled[i];
      b.writeln("  [${i + 1}]");
      b.writeln("    공모전 이름: ${_lineOrNone(a.primary.text)}");
      b.writeln("    수상 등급·등수: ${_lineOrNone(a.secondary.text)}");
      b.writeln("    시기: ${_lineOrNone(_periodPayload(a))}");
      b.writeln("    내용: ${_lineOrNone(a.body.text)}");
    }
  }

  void _writeAbroadSection(StringBuffer b, List<ActCtrls> list) {
    b.writeln("어학연수·교환학생 등");
    final List<ActCtrls> filled = list.where(_actHasContent).toList();
    if (filled.isEmpty) {
      b.writeln("  (없음)");
      return;
    }
    for (int i = 0; i < filled.length; i++) {
      final ActCtrls a = filled[i];
      b.writeln("  [${i + 1}]");
      b.writeln("    체류 국가: ${_lineOrNone(a.secondary.text)}");
      b.writeln("    학교·기관명: ${_lineOrNone(a.tertiary.text)}");
      b.writeln("    시기: ${_lineOrNone(_periodPayload(a))}");
      b.writeln("    내용: ${_lineOrNone(a.body.text)}");
    }
  }

  String compilePayload() {
    final StringBuffer b = StringBuffer();
    b.writeln("[구조화 경험·스펙 입력]");
    b.writeln();
    b.writeln("[학적]");
    b.writeln("고등학교: ${cHighSchool.text.trim()}");
    b.writeln("대학교: ${cUniversity.text.trim()}");
    b.writeln("대학원: ${cGradSchool.text.trim()}");
    b.writeln();
    b.writeln("[전공]");
    b.writeln("주전공: ${cMajorMain.text.trim()}");
    b.writeln("부전공: ${cMajorMinor.text.trim()}");
    b.writeln("복수전공: ${cMajorDouble.text.trim()}");
    b.writeln();
    b.writeln("[학점]");
    b.writeln(
      "평균 학점: ${cGpaScore.text.trim()} / 만점: ${_resolvedFullMark()}",
    );
    b.writeln();
    b.writeln("[자격증]");
    if (_certItems.isEmpty) {
      b.writeln("(없음)");
    } else {
      for (int i = 0; i < _certItems.length; i++) {
        final _CertItem c = _certItems[i];
        final String d = c.date.trim().isEmpty ? "(일자 미입력)" : c.date.trim();
        b.writeln("${i + 1}. 취득일자: $d / 자격명: ${c.name.trim()}");
      }
    }
    b.writeln();
    b.writeln("[동아리·교내 활동]");
    _writeClubLikeSection(b, "동아리", "동아리 이름", _clubs);
    b.writeln();
    _writeClubLikeSection(b, "교내 경험", "활동명", _campus);
    b.writeln();
    b.writeln("[실무·공모]");
    _writeClubLikeSection(b, "인턴십", "회사·기관명", _interns);
    b.writeln();
    _writeClubLikeSection(b, "아르바이트", "근무지·담당 업무", _parttimes);
    b.writeln();
    _writeContestSection(b, _contests);
    b.writeln();
    b.writeln("[교외·프로젝트·부트캠프]");
    _writeClubLikeSection(b, "부트캠프·교외·팀 프로젝트", "프로그램·활동명", _dx);
    b.writeln();
    b.writeln("[글로벌·연수]");
    _writeAbroadSection(b, _abroad);
    b.writeln();
    b.writeln("[기타 경험]");
    b.writeln(cEtc.text.trim());
    return b.toString().trim();
  }

  String compileMergedNarrative() {
    return compilePayload();
  }

  void _removeCert(int index) {
    setState(() {
      _certItems.removeAt(index);
    });
  }

  Future<void> _openAddCertDialog() async {
    if (!widget.enabled) {
      return;
    }
    final TextEditingController dateC = TextEditingController();
    final TextEditingController nameC = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        final ColorScheme scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: Text(
            "자격증 추가",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "취득일자와 자격증 이름을 나누어 입력한 뒤 추가하세요.",
                  style: TextStyle(fontSize: 13, height: 1.45, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateC,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "취득일자",
                    hintText: "예: 2024.03, 2025-06, 진행 중",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                    labelText: "자격증 이름",
                    hintText: "예: TOEIC 850, 정보처리기사",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("취소")),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.primary,
                side: BorderSide(color: Theme.of(ctx).colorScheme.primary),
              ),
              onPressed: () {
                if (nameC.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(ctx).pop(true);
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
    if (ok == true && nameC.text.trim().isNotEmpty) {
      setState(() {
        _certItems.add(_CertItem(date: dateC.text.trim(), name: nameC.text.trim()));
      });
    }
    dateC.dispose();
    nameC.dispose();
  }

  ButtonStyle _aiOutlinedButtonStyle(ColorScheme scheme) {
    final Color border = scheme.primary.withValues(alpha: 0.5);
    final Color borderStrong = scheme.primary;

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.38);
        }
        if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
          return scheme.primary;
        }
        return scheme.primary.withValues(alpha: 0.92);
      }),
      side: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        final bool ho = s.contains(WidgetState.hovered) || s.contains(WidgetState.focused);
        return BorderSide(color: ho ? borderStrong : border, width: ho ? 1.6 : 1);
      }),
      backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
          return scheme.primary.withValues(alpha: 0.07);
        }
        return Colors.transparent;
      }),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _copyMerged() async {
    final String t = compileMergedNarrative();
    await Clipboard.setData(ClipboardData(text: t));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("합본이 클립보드에 복사되었습니다.")),
    );
  }

  Widget _periodPickRow(ActCtrls a) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ButtonStyle dateBtn = OutlinedButton.styleFrom(
      foregroundColor: scheme.primary,
      side: BorderSide(color: scheme.outline),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
    final String startT = a.monthStart != null ? _fmtYearMonth(a.monthStart) : "시작 연월";
    final String endT = a.monthEnd != null ? _fmtYearMonth(a.monthEnd) : "끝 연월";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "시기 (연·월)",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: dateBtn,
                onPressed: widget.enabled
                    ? () async {
                        final DateTime? d = await _pickYearMonth(
                          context,
                          initial: a.monthStart ?? DateTime.now(),
                          helpText: "시작 연월 선택",
                        );
                        if (d != null && mounted) {
                          setState(() => a.monthStart = d);
                        }
                      }
                    : null,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: Text(startT, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: dateBtn,
                onPressed: widget.enabled
                    ? () async {
                        final DateTime? d = await _pickYearMonth(
                          context,
                          initial: a.monthEnd ?? a.monthStart ?? DateTime.now(),
                          helpText: "끝 연월 선택",
                        );
                        if (d != null && mounted) {
                          setState(() => a.monthEnd = d);
                        }
                      }
                    : null,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(endT, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        if (a.monthStart != null || a.monthEnd != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.enabled
                  ? () => setState(() {
                      a.monthStart = null;
                      a.monthEnd = null;
                    })
                  : null,
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
              child: const Text("기간 초기화"),
            ),
          ),
      ],
    );
  }

  Widget _entryCardHeader(String title, int index, int total, VoidCallback? onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            total > 1 ? "$title ${index + 1}" : title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          if (onRemove != null)
            IconButton(
              tooltip: "이 항목 삭제",
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.outline),
            ),
        ],
      ),
    );
  }

  Widget _multiActivitySection({
    required String sectionTitle,
    required List<ActCtrls> list,
    required String addButtonLabel,
    required _ActivityKind kind,
    String primaryLabel = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < list.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
            backgroundColor: AppColors.surfaceContainerLowest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _entryCardHeader(
                  sectionTitle,
                  i,
                  list.length,
                  widget.enabled ? () => _removeAct(list, i) : null,
                ),
                switch (kind) {
                  _ActivityKind.clubLike => _activityClubLikeFields(list[i], primaryLabel),
                  _ActivityKind.contest => _activityContestFields(list[i]),
                  _ActivityKind.abroad => _activityAbroadFields(list[i]),
                },
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: widget.enabled ? () => _addAct(list) : null,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(addButtonLabel),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _activityClubLikeFields(ActCtrls a, String primaryLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: a.primary,
          enabled: widget.enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec(primaryLabel),
        ),
        const SizedBox(height: 10),
        _periodPickRow(a),
        const SizedBox(height: 10),
        TextField(
          controller: a.body,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: 10,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("내용"),
        ),
      ],
    );
  }

  Widget _activityContestFields(ActCtrls a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: a.primary,
          enabled: widget.enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("공모전 이름", hint: "예: OO 공모전, 해커톤 명"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: a.secondary,
          enabled: widget.enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("수상 등급·등수", hint: "예: 본선 진출, 장려상, 3위, 미수상"),
        ),
        const SizedBox(height: 10),
        _periodPickRow(a),
        const SizedBox(height: 10),
        TextField(
          controller: a.body,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: 10,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("내용", hint: "주제, 역할, 성과를 적어 주세요."),
        ),
      ],
    );
  }

  Widget _activityAbroadFields(ActCtrls a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: a.secondary,
          enabled: widget.enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("체류 국가", hint: "예: 캐나다, 필리핀"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: a.tertiary,
          enabled: widget.enabled,
          minLines: 1,
          maxLines: 2,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("학교·기관명", hint: "예: OO대학교, OO어학원"),
        ),
        const SizedBox(height: 10),
        _periodPickRow(a),
        const SizedBox(height: 10),
        TextField(
          controller: a.body,
          enabled: widget.enabled,
          minLines: 3,
          maxLines: 10,
          style: const TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec("내용", hint: "과정·어학 목표·생활 등을 적어 주세요."),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: SectionHeader(
        title: title,
        subtitle: subtitle,
        icon: Icons.inventory_2_outlined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String label, {int maxLines = 5}) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          enabled: widget.enabled,
          minLines: 2,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15, height: 1.45),
          decoration: _dec(label),
        ),
      );
    }

    final InputBorder border = OutlineInputBorder(borderRadius: BorderRadius.circular(10));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppCard(
            backgroundColor: AppColors.surfaceContainerLowest,
            child: SectionHeader(
              title: "경험 카드로 재사용할 정보를 모읍니다",
              subtitle: "필수 항목만 먼저 채우고, 활동·자격증은 필요한 만큼 추가하세요. 빈 카테고리에 ‘없음’을 적을 필요는 없습니다.",
              icon: Icons.auto_awesome_mosaic_outlined,
              trailing: StatusPill(
                label: "경험 중심",
                icon: Icons.inventory_2_outlined,
              ),
            ),
          ),
          const SizedBox(height: 8),

          _sectionTitle(
            "학적",
            "고등학교, 대학교, 대학원을 구분해 적어 주세요.",
          ),
          field(cHighSchool, "고등학교", maxLines: 5),
          field(cUniversity, "대학교", maxLines: 5),
          field(cGradSchool, "대학원", maxLines: 5),

          _sectionTitle(
            "전공",
            "주전공, 부전공, 복수전공을 각각 적어 주세요.",
          ),
          field(cMajorMain, "주전공", maxLines: 4),
          field(cMajorMinor, "부전공", maxLines: 4),
          field(cMajorDouble, "복수전공", maxLines: 4),

          _sectionTitle(
            "학점",
            "평균 학점을 적고, 오른쪽에서 만점 기준을 선택하세요. (기타는 만점 숫자를 직접 입력)",
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: TextField(
                  controller: cGpaScore,
                  enabled: widget.enabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  minLines: 1,
                  maxLines: 2,
                  style: TextStyle(fontSize: 15, height: 1.45),
                  decoration: _dec("평균 학점"),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _gpaFullMarkChoice,
                  decoration: InputDecoration(
                    labelText: "만점",
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    border: border,
                    enabledBorder: border.copyWith(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  items: [
                    for (final String opt in _gpaFullMarkOptions)
                      DropdownMenuItem<String>(
                        value: opt,
                        child: Text(
                          opt == "100"
                              ? "100점 만점"
                              : opt == "기타"
                              ? "기타 (직접 입력)"
                              : "$opt 만점",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: widget.enabled
                      ? (String? v) {
                          if (v == null) {
                            return;
                          }
                          setState(() => _gpaFullMarkChoice = v);
                        }
                      : null,
                ),
              ),
            ],
          ),
          if (_gpaFullMarkChoice == "기타") ...[
            SizedBox(height: 10),
            TextField(
              controller: cGpaFullMarkOther,
              enabled: widget.enabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              minLines: 1,
              maxLines: 2,
              style: TextStyle(fontSize: 15, height: 1.45),
              decoration: _dec("만점 (숫자 직접 입력, 예: 20, 7)"),
            ),
          ],
          SizedBox(height: 8),

          _sectionTitle(
            "자격증",
            "있을 때만 ‘자격증 추가’로 입력하세요. 여러 개면 추가를 반복하면 됩니다.",
          ),
          if (_certItems.isNotEmpty) ...[
            ...List<Widget>.generate(_certItems.length, (int i) {
              final _CertItem c = _certItems[i];
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    title: Text(
                      c.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "취득일자: ${c.date.trim().isEmpty ? "—" : c.date.trim()}",
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: "삭제",
                      onPressed: widget.enabled ? () => _removeCert(i) : null,
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.outline),
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 4),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: widget.enabled ? _openAddCertDialog : null,
            icon: Icon(Icons.add_circle_outline, size: 20),
            label: Text("자격증 추가"),
          ),
          SizedBox(height: 8),
          _sectionTitle(
            "동아리·교내 활동",
            "해당 경험이 있을 때만 각 ‘추가’ 버튼으로 입력하세요.",
          ),
          _multiActivitySection(
            sectionTitle: "동아리",
            list: _clubs,
            addButtonLabel: "동아리 추가",
            kind: _ActivityKind.clubLike,
            primaryLabel: "동아리 이름",
          ),
          _multiActivitySection(
            sectionTitle: "교내 경험",
            list: _campus,
            addButtonLabel: "교내 활동 추가",
            kind: _ActivityKind.clubLike,
            primaryLabel: "활동명",
          ),

          _sectionTitle(
            "실무·공모",
            "인턴·알바·공모전도 ‘추가’로 필요한 만큼만 입력하세요.",
          ),
          _multiActivitySection(
            sectionTitle: "인턴십",
            list: _interns,
            addButtonLabel: "인턴십 추가",
            kind: _ActivityKind.clubLike,
            primaryLabel: "회사·기관명",
          ),
          _multiActivitySection(
            sectionTitle: "아르바이트",
            list: _parttimes,
            addButtonLabel: "아르바이트 추가",
            kind: _ActivityKind.clubLike,
            primaryLabel: "근무지·담당 업무",
          ),
          _multiActivitySection(
            sectionTitle: "공모전",
            list: _contests,
            addButtonLabel: "공모전 추가",
            kind: _ActivityKind.contest,
          ),

          _sectionTitle(
            "교외·프로젝트·부트캠프",
            "해당 활동이 있을 때만 ‘활동 추가’로 입력하세요.",
          ),
          _multiActivitySection(
            sectionTitle: "부트캠프·교외·팀 프로젝트",
            list: _dx,
            addButtonLabel: "활동 추가",
            kind: _ActivityKind.clubLike,
            primaryLabel: "프로그램·활동명",
          ),

          _sectionTitle(
            "글로벌·연수",
            "연수·교환 경험이 있을 때만 ‘연수·교환 추가’로 입력하세요.",
          ),
          _multiActivitySection(
            sectionTitle: "어학연수·교환학생 등",
            list: _abroad,
            addButtonLabel: "연수·교환 추가",
            kind: _ActivityKind.abroad,
          ),

          _sectionTitle(
            "기타 경험",
            "위 분류에 들어가지 않는 활동만 간단히 적어 주세요.",
          ),
          field(cEtc, "기타", maxLines: 8),

          Theme(
            data: Theme.of(context).copyWith(
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: _aiOutlinedButtonStyle(Theme.of(context).colorScheme),
              ),
            ),
            child: ActionBar(
              children: [
                OutlinedButton.icon(
                  onPressed: widget.enabled
                      ? () {
                          widget.onAiTable(compilePayload());
                        }
                      : null,
                  icon: Icon(Icons.auto_awesome, size: 18),
                  label: Text("표로 정리"),
                ),
                OutlinedButton.icon(
                  onPressed: widget.enabled
                      ? () {
                          widget.onAiNarrativeMerge(compilePayload());
                        }
                      : null,
                  icon: Icon(Icons.subject, size: 18),
                  label: Text("서술형으로 통합"),
                ),
                OutlinedButton.icon(
                  onPressed: widget.enabled
                      ? () {
                          widget.onAiRecommend(compilePayload());
                        }
                      : null,
                  icon: Icon(Icons.work_outline, size: 18),
                  label: Text("직무 추천"),
                ),
                OutlinedButton.icon(
                  onPressed: widget.enabled ? _copyMerged : null,
                  icon: Icon(Icons.copy, size: 18),
                  label: Text("합본 복사"),
                ),
                OutlinedButton.icon(
                  onPressed: widget.enabled ? widget.onExportMerged : null,
                  icon: Icon(Icons.save_alt, size: 18),
                  label: Text("합본 저장"),
                ),
                OutlinedButton.icon(
                  onPressed: widget.enabled
                      ? () async {
                          await widget.onSaveStructured(toExperiences(), toSpecItems());
                        }
                      : null,
                  icon: Icon(Icons.inventory_2_outlined, size: 18),
                  label: Text("경험 카드로 저장"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActCtrls {
  ActCtrls()
    : primary = TextEditingController(),
      secondary = TextEditingController(),
      tertiary = TextEditingController(),
      body = TextEditingController();

  /// 동아리·인턴 등: 이름/회사명. 공모전: 공모전 이름. (어학연수 UI에서는 미사용 가능)
  final TextEditingController primary;

  /// 공모전: 수상. 어학연수: 국가.
  final TextEditingController secondary;

  /// 어학연수: 학교·기관명. 그 외 항목은 입력란을 숨기고 비워 둡니다.
  final TextEditingController tertiary;

  final TextEditingController body;
  DateTime? monthStart;
  DateTime? monthEnd;

  void dispose() {
    primary.dispose();
    secondary.dispose();
    tertiary.dispose();
    body.dispose();
  }
}

class _CertItem {
  _CertItem({required this.date, required this.name});

  final String date;
  final String name;
}
