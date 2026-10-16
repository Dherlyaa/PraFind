import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../lib/features/reports/data/report_repository.dart';
import '../../../../lib/features/reports/domain/report_model.dart';
import '../../../../lib/features/reports/presentation/pages/report_list_page.dart';
import '../../../../lib/features/reports/presentation/pages/create_report_page.dart';
import '../../../../lib/features/reports/presentation/providers/report_list_provider.dart';

class MockReportRepository extends ReportRepository {
  final bool forceError;
  final bool forceEmpty;

  MockReportRepository({this.forceError = false, this.forceEmpty = false});

  @override
  Future<List<ReportModel>> fetchReports({
    String query = '',
    bool forceError = false,
    bool forceEmpty = false,
  }) async {
    if (this.forceError || forceError) throw Exception('Server error');
    if (this.forceEmpty || forceEmpty) return [];
    return [
      ReportModel(
        id: '1',
        title: 'KTM Budi',
        category: 'Dokumen',
        location: 'Gedung A',
        description: 'Detail KTM',
        type: 'FOUND',
      )
    ];
  }

  @override
  Future<bool> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}

void main() {
  Widget buildTestableWidget(ReportRepository repo, Widget child) {
    return ProviderScope(
      overrides: [
        reportRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('1. Verifikasi Initial Loading State', (tester) async {
    await tester.pumpWidget(buildTestableWidget(MockReportRepository(), const ReportListPage()));
    expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
  });

  testWidgets('2. Verifikasi Data Berhasil Dimuat (Success State)', (tester) async {
    await tester.pumpWidget(buildTestableWidget(MockReportRepository(), const ReportListPage()));
    await tester.pumpAndSettle();

    expect(find.text('KTM Budi'), findsOneWidget);
  });

  testWidgets('3. Verifikasi Empty State', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(MockReportRepository(forceEmpty: true), const ReportListPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada laporan barang ditemukan.'), findsOneWidget);
  });

  testWidgets('4. Verifikasi Error State & Tombol Retry', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(MockReportRepository(forceError: true), const ReportListPage()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('retry_button')), findsOneWidget);
  });

  testWidgets('5. Verifikasi Validasi Input Form (Fitur 2)', (tester) async {
    await tester.pumpWidget(buildTestableWidget(MockReportRepository(), const CreateReportPage()));

    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();

    expect(find.text('Nama barang tidak boleh kosong'), findsOneWidget);
    expect(find.text('Lokasi kejadian wajib diisi'), findsOneWidget);
  });

  testWidgets('6. Verifikasi Submitting Loading State & Prevent Double Tap', (tester) async {
    await tester.pumpWidget(buildTestableWidget(MockReportRepository(), const CreateReportPage()));

    await tester.enterText(find.byKey(const Key('title_input')), 'Tas');
    await tester.enterText(find.byKey(const Key('location_input')), 'Kantin');
    await tester.enterText(find.byKey(const Key('description_input')), 'Warna Hitam');

    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byKey(const Key('submit_button')));
    expect(button.onPressed, isNull);

    // Menyelesaikan timer 300ms agar tidak ada pending async timer saat tes selesai
    await tester.pumpAndSettle();
  });
}
