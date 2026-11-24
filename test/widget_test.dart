import 'package:flutter_test/flutter_test.dart';
import 'package:hexgen_booking/main.dart';

void main() {
  testWidgets('Hexgen Player app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HexgenConnectApp());
    await tester.pumpAndSettle();
    expect(find.text('HEXGEN PLAYER'), findsOneWidget);
    expect(find.textContaining('Athlete'), findsOneWidget);
  });
}
