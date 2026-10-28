import 'package:flutter_test/flutter_test.dart';
import 'package:nasaq/main.dart';

void main() {
  testWidgets('Nasaq welcome portal and hub navigation work in RTL', (WidgetTester tester) async {
    await tester.pumpWidget(const NasaqApp());

    expect(find.text('نَسَق'), findsOneWidget);
    expect(find.text('مساعدك الذكي .. بتخصص أعمق'), findsOneWidget);
    expect(find.text('البرمجة'), findsOneWidget);
    expect(find.text('التصميم'), findsOneWidget);
    expect(find.text('المحاسبة'), findsOneWidget);
    expect(find.text('المشاريع'), findsOneWidget);

    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();

    expect(find.text('ساحة المساعدين المتخصصين'), findsOneWidget);
    expect(find.text('مساعد البرمجة'), findsOneWidget);
  });
}
