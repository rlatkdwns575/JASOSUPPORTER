import 'package:flutter_test/flutter_test.dart';
import 'package:chatgptmini/app/app.dart';

void main() {
  testWidgets('JasoSupporter app shell renders at initial route', (WidgetTester tester) async {
    await tester.pumpWidget(const JasoApp());
    await tester.pump();

    expect(find.text('JasoSupporter'), findsOneWidget);
    expect(find.text('경험·스펙'), findsOneWidget);
  });
}
