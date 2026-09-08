import 'package:flutter_test/flutter_test.dart';
import 'package:borrow_manager/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Borrow Manager'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Track every rupee you lend or borrow'), findsOneWidget);
  });
}