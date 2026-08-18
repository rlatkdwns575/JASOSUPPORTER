import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/core/utils/api_error_message.dart';
import 'package:chatgptmini/core/utils/string_extensions.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 경력 데이터 로드 실패 시 작업 영역 상단에 보여주는 배너.
class CareerDataErrorBanner extends ConsumerWidget {
  const CareerDataErrorBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? message = careerDataErrorBannerMessage(
      experiencesError: _errorOf(ref.watch(experiencesProvider)),
      specsError: _errorOf(ref.watch(specItemsProvider)),
      portfolioError: _errorOf(ref.watch(portfolioProjectsProvider)),
      applicationsError: _errorOf(ref.watch(applicationRecordsProvider)),
      interviewError: _errorOf(ref.watch(interviewAnswersProvider)),
    );
    if (message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 20, color: AppColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message.softWrapWords(),
                  style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.invalidate(experiencesProvider);
                  ref.invalidate(specItemsProvider);
                  ref.invalidate(portfolioProjectsProvider);
                  ref.invalidate(applicationRecordsProvider);
                  ref.invalidate(interviewAnswersProvider);
                  ref.invalidate(essayVersionCountsProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Object? _errorOf(AsyncValue<Object?> value) {
  return value.hasError ? value.error : null;
}

String? careerDataErrorBannerMessage({
  Object? experiencesError,
  Object? specsError,
  Object? portfolioError,
  Object? applicationsError,
  Object? interviewError,
}) {
  final Object? first = experiencesError ??
      specsError ??
      portfolioError ??
      applicationsError ??
      interviewError;
  if (first == null) {
    return null;
  }
  return actionErrorMessage('데이터를 불러오지 못했습니다', first);
}
