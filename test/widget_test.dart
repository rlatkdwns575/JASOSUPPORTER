import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatgptmini/app/app.dart';

void main() {
  testWidgets('JasoSupporter home dashboard renders at initial route', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JasoApp());
    await tester.pump();

    expect(find.text('홈'), findsWidgets);
    expect(find.text('AI 커리어 코칭'), findsOneWidget);
  });

  testWidgets('Home dashboard lays out on wide screens without exceptions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JasoApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('AI 커리어 코칭'), findsOneWidget);
  });
}
