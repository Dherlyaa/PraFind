import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:pradita_find_mobile/features/reports/data/report_repository.dart';
import 'package:pradita_find_mobile/features/reports/domain/report_model.dart';
import 'package:pradita_find_mobile/features/reports/presentation/pages/report_list_page.dart';
import 'package:pradita_find_mobile/features/reports/presentation/providers/report_list_provider.dart';

void main() {
  group('Verifikasi Bug Aktif PraFind (Target Run Merah Sebelum Perbaikan)', () {
    test('Issue #4: Pencarian harus mencocokkan lokasi & kategori dengan spasi berlebih', () async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'KTM Mahasiswa',
                'category': 'Dokumen',
                'location': 'Perpustakaan Lantai 2',
              }
            ]),
            200,
          ));
      final repo = ReportRepository(client: mockClient);
      final result = await repo.fetchReports(query: '  perpustakaan   lantai 2 ');
      expect(result.length, 1);
    });

    test('Issue #6: Status lama OPEN harus dinormalisasi menjadi ACTIVE', () {
      final model = ReportModel.fromJson({
        'id': '1',
        'title': 'KTM Mahasiswa',
        'status': 'OPEN',
      });
      expect(model.status, 'ACTIVE');
    });

    test('Issue #7: ReportModel.toJson harus menyertakan field imagePath', () {
      final model = ReportModel.fromJson({'id': '1', 'title': 'Tas Hitam'});
      expect(model.toJson().containsKey('imagePath'), isTrue);
    });

    test('Issue #9: Query pencarian tetap bertahan setelah markAsResolved', () async {
      String lastQuery = '';
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {'id': '1', 'title': 'KTM Mahasiswa', 'status': 'ACTIVE'}
            ]),
            200,
          ));
      final repo = _SpyRepository(mockClient, (q) => lastQuery = q);
      final notifier = ReportListNotifier(repo);
      await notifier.loadReports(query: 'KTM');
      await notifier.markAsResolved(
        ReportModel(
          id: '1',
          title: 'KTM Mahasiswa',
          category: 'Dokumen',
          location: 'Perpus',
          description: 'KTM',
          type: 'FOUND',
        ),
      );
      expect(lastQuery, 'KTM');
    });

    testWidgets('Issue #10: Menekan ikon hapus memunculkan dialog konfirmasi', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {'id': '1', 'title': 'KTM Mahasiswa', 'status': 'ACTIVE'}
            ]),
            200,
          ));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [httpClientProvider.overrideWithValue(mockClient)],
          child: const MaterialApp(home: ReportListPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('Hapus laporan ini?'), findsOneWidget);
    });
  });
}

class _SpyRepository extends ReportRepository {
  final void Function(String) onQuery;
  _SpyRepository(http.Client client, this.onQuery) : super(client: client);

  @override
  Future<List<ReportModel>> fetchReports({String query = ''}) {
    onQuery(query);
    return super.fetchReports(query: query);
  }
}
