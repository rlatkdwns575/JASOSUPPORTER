import 'package:chatgptmini/data/services/api_client.dart';
import 'package:chatgptmini/features/home/career_data_error_banner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('careerDataErrorBannerMessage is null when all sources succeed', () {
    expect(careerDataErrorBannerMessage(), isNull);
  });

  test('careerDataErrorBannerMessage uses the first load error', () {
    expect(
      careerDataErrorBannerMessage(
        experiencesError: ApiException(503, '{"detail":"unavailable"}'),
      ),
      contains('데이터를 불러오지 못했습니다'),
    );
  });
}
