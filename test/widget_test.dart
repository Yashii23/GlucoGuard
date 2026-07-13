import 'package:flutter_test/flutter_test.dart';
import 'package:diabetes_health_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DiabetesApp());

    expect(find.byType(DiabetesApp), findsOneWidget);
  });
}