import 'package:flutter_test/flutter_test.dart';
import 'package:hexgen_booking/main.dart';

void main() {
  testWidgets('Hexgen Connect app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HexgenConnectApp());
    await tester.pumpAndSettle();
    expect(find.text('HEXGEN CONNECT'), findsOneWidget);
    expect(find.textContaining('Athlete'), findsOneWidget);
  });
}
