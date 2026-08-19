import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:chatgptmini/data/providers/career_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 경력 데이터를 처음 불러오는 동안 작업 영역 상단에 보여주는 배너.
class CareerDataLoadingBanner extends ConsumerWidget {
  const CareerDataLoadingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!careerDataLoadingBannerVisible(
      experiences: ref.watch(experiencesProvider),
      specs: ref.watch(specItemsProvider),
      portfolio: ref.watch(portfolioProjectsProvider),
      applications: ref.watch(applicationRecordsProvider),
      interview: ref.watch(interviewAnswersProvider),
    )) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppColors.experienceTint,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '경력 데이터를 불러오는 중입니다…',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool careerDataLoadingBannerVisible({
  required AsyncValue<dynamic> experiences,
  required AsyncValue<dynamic> specs,
  required AsyncValue<dynamic> portfolio,
  required AsyncValue<dynamic> applications,
  required AsyncValue<dynamic> interview,
}) {
  if (_hasError(experiences) ||
      _hasError(specs) ||
      _hasError(portfolio) ||
      _hasError(applications) ||
      _hasError(interview)) {
    return false;
  }
  return experiences.isLoading ||
      specs.isLoading ||
      portfolio.isLoading ||
      applications.isLoading ||
      interview.isLoading;
}

bool _hasError(AsyncValue<dynamic> value) => value.hasError;
