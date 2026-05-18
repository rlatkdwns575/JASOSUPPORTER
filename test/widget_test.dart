import 'package:flutter_test/flutter_test.dart';
import 'package:chatgptmini/main.dart';

void main() {
  testWidgets('JasoSupporter app shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ChatGptApp());
    await tester.pump();

    expect(find.text('JasoSupporter'), findsOneWidget);
    expect(find.text('경험·스펙'), findsOneWidget);
  });

  testWidgets('Missing API key screen renders instead of blank app', (WidgetTester tester) async {
    await tester.pumpWidget(const MissingApiKeyApp());
    await tester.pump();

    expect(find.text('Gemini API 키가 필요합니다'), findsOneWidget);
    expect(find.text('JasoSupporter 시작'), findsOneWidget);
  });
}
