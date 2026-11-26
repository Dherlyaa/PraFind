import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan path import dengan struktur folder proyek Anda
import 'package:pradita_find_mobile/features/reports/presentation/pages/create_report_page.dart';

void main() {
  testWidgets('Menampilkan pesan error validasi jika form dikirim kosong', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CreateReportPage()),
      ),
    );

    // Tekan tombol submit tanpa mengisi form
    final submitBtn = find.byKey(const Key('submit_button'));
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Pastikan pesan error validasi muncul
    expect(find.text('Nama barang tidak boleh kosong'), findsOneWidget);
    expect(find.text('Lokasi kejadian wajib diisi'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi'), findsOneWidget);
  });
}