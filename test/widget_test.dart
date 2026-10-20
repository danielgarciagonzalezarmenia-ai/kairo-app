import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kairo/main.dart';

void main() {
  testWidgets('Kairo app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const KairoApp());
    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}
