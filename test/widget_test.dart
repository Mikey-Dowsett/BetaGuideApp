import 'package:beta_guide/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BetaGuideApp());
    expect(find.byIcon(Icons.videocam), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);
  });
}
