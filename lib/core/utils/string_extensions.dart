/// 문자열 표시용 공용 확장.
extension StringExtension on String {
  /// 한글 등 공백 없는 긴 문자열이 컨테이너를 벗어나지 않도록,
  /// 인접한 글자 사이에 U+200D(zero-width joiner)를 삽입해
  /// 글자 단위 줄바꿈 기회를 만들어 준다.
  String softWrapWords() {
    return replaceAllMapped(RegExp(r"(\S)(?=\S)"), (m) => "${m[1]}\u200D");
  }
}
