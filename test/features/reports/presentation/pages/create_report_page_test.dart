import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pradita_find_mobile/features/reports/data/report_repository.dart';
import 'package:pradita_find_mobile/features/reports/domain/report_model.dart';
import 'package:pradita_find_mobile/features/reports/presentation/pages/create_report_page.dart';
import 'package:pradita_find_mobile/features/reports/presentation/providers/report_form_provider.dart';

class MockReportRepository extends ReportRepository {
  final bool causeError;
  final bool forceEmpty;

  MockReportRepository({this.causeError = false, this.forceEmpty = false});

  @override
  Future<List<String>> fetchCategories({bool causeError = false, bool forceEmpty = false}) async {
    if (this.causeError) throw Exception('Gagal terhubung ke server kampus');
    if (this.forceEmpty) return [];
    return ['Elektronik', 'Dokumen'];
  }

  @override
  Future<bool> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}

void main() {
  Widget createWidgetUnderTest(ReportRepository repo) {
    return ProviderScope(
      overrides: [
        reportRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: CreateReportPage()),
    );
  }

  testWidgets('1. Menampilkan State Initial Loading', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockReportRepository()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Memuat kategori data...'), findsOneWidget);
  });

  testWidgets('2. Menampilkan Data Berhasil Dimuat (Form Render)', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockReportRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('title_field')), findsOneWidget);
    expect(find.byKey(const Key('category_dropdown')), findsOneWidget);
  });

  testWidgets('3. Menampilkan Empty State saat kategori kosong', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockReportRepository(forceEmpty: true)));
    await tester.pumpAndSettle();

    expect(find.text('Kategori barang tidak tersedia.'), findsOneWidget);
  });

  testWidgets('4. Menampilkan Error State dan Tombol Retry saat gagal', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockReportRepository(causeError: true)));
    await tester.pumpAndSettle();

    expect(find.text('Gagal terhubung ke server kampus'), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);
  });

  testWidgets('5. Menampilkan Validasi Form saat dikirim kosong', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockReportRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();

    expect(find.text('Nama barang wajib diisi'), findsOneWidget);
    expect(find.text('Pilih salah satu kategori'), findsOneWidget);
  });

  testWidgets('6. Menampilkan Loading saat Submit (Prevent Double Tap)', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockReportRepository()));
    await tester.pumpAndSettle();

    // Isi Form
    await tester.enterText(find.byKey(const Key('title_field')), 'KTM');
    await tester.tap(find.byKey(const Key('category_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elektronik').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('location_field')), 'Gedung A');
    await tester.enterText(find.byKey(const Key('description_field')), 'Warna Biru');

    // Tap Submit
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump(); // Trigger frame pertama saat submit berjalan

    // Tombol dalam keadaan disabled (loading)
    final button = tester.widget<ElevatedButton>(find.byKey(const Key('submit_button')));
    expect(button.onPressed, isNull);
  });
}