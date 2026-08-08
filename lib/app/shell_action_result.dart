import 'package:chatgptmini/domain/models/career_artifacts.dart';

/// 셸 액션 결과. UI는 snack/navigate/후속 편집만 처리하면 된다.
class ShellActionResult {
  const ShellActionResult({
    this.snack,
    this.navigateTo,
    this.cancelled = false,
    this.editPortfolio,
  });

  const ShellActionResult.cancelled()
      : snack = null,
        navigateTo = null,
        cancelled = true,
        editPortfolio = null;

  final String? snack;
  final String? navigateTo;
  final bool cancelled;

  /// 저장 직후 개요 편집기를 열 포트폴리오 프로젝트.
  final PortfolioProject? editPortfolio;

  bool get hasSnack => snack != null && snack!.trim().isNotEmpty;
}
