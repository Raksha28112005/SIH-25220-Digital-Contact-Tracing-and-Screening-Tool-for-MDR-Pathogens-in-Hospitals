import 'package:flutter_test/flutter_test.dart';
import 'package:mdr_screening_app/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MDRApp());
  });
}
