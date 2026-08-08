import 'package:chatgptmini/app/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppRoutes builds experience and interview paths', () {
    expect(AppRoutes.experienceFormCategory('campus'), '/experience/form?category=campus');
    expect(
      AppRoutes.experienceFormSubtype('campus', 'club'),
      '/experience/form?category=campus&subtype=club',
    );
    expect(AppRoutes.experienceDetail('exp_1'), '/experience/detail/exp_1');
    expect(AppRoutes.portfolioPreview('p1'), '/portfolio/preview/p1');
    expect(AppRoutes.interviewSaved('i1'), '/interview/saved/i1');
  });
}
