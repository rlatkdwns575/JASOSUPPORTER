import 'package:chatgptmini/features/home/career_data_loading_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('careerDataLoadingBannerVisible is false when all sources have data', () {
    expect(
      careerDataLoadingBannerVisible(
        experiences: const AsyncData(<dynamic>[]),
        specs: const AsyncData(<dynamic>[]),
        portfolio: const AsyncData(<dynamic>[]),
        applications: const AsyncData(<dynamic>[]),
        interview: const AsyncData(<dynamic>[]),
      ),
      isFalse,
    );
  });

  test('careerDataLoadingBannerVisible is true while any source is loading', () {
    expect(
      careerDataLoadingBannerVisible(
        experiences: const AsyncLoading(),
        specs: const AsyncData(<dynamic>[]),
        portfolio: const AsyncData(<dynamic>[]),
        applications: const AsyncData(<dynamic>[]),
        interview: const AsyncData(<dynamic>[]),
      ),
      isTrue,
    );
  });

  test('careerDataLoadingBannerVisible is false when an error is present', () {
    expect(
      careerDataLoadingBannerVisible(
        experiences: AsyncError(Exception('fail'), StackTrace.empty),
        specs: const AsyncLoading(),
        portfolio: const AsyncData(<dynamic>[]),
        applications: const AsyncData(<dynamic>[]),
        interview: const AsyncData(<dynamic>[]),
      ),
      isFalse,
    );
  });
}
