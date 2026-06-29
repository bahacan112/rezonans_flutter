import 'package:flutter_test/flutter_test.dart';
import 'package:rezonans_flutter/main.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const RezonansApp());
    expect(find.byType(RezonansApp), findsOneWidget);
  });
}
