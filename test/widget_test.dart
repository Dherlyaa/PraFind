import 'package:flutter_test/flutter_test.dart';
import 'package:pradita_find_mobile/main.dart';

void main() {
  testWidgets('PraditaFindApp menampilkan halaman login awal', (WidgetTester tester) async {
    await tester.pumpWidget(const PraditaFindApp());

    expect(find.text('Pradita Find'), findsOneWidget);
    expect(find.text('Login dengan Biometrik'), findsOneWidget);
  });
}