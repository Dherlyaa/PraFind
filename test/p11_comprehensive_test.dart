import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pradita_find_mobile/features/auth/domain/auth_session.dart';
import 'package:pradita_find_mobile/features/reports/data/report_repository.dart';
import 'package:pradita_find_mobile/features/reports/domain/report_model.dart';
import 'package:pradita_find_mobile/features/reports/domain/report_validator.dart';
import 'package:pradita_find_mobile/features/reports/presentation/pages/create_report_page.dart';
import 'package:pradita_find_mobile/features/reports/presentation/pages/report_detail_page.dart';
import 'package:pradita_find_mobile/features/reports/presentation/pages/report_list_page.dart';
import 'package:pradita_find_mobile/features/reports/presentation/providers/report_list_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthSession.resetToDefault();
  });

  // 1. 35 Unit Test untuk Issue #4 (Pencarian case-insensitive & normalisasi spasi)
  group('Issue #4: Pencarian Case-Insensitive & Normalisasi Spasi (35 Tes)', () {
    final sampleReports = [
      {
        'id': '1',
        'title': 'KTM Mahasiswa Informatika',
        'category': 'Dokumen',
        'location': 'Perpustakaan Lantai 2',
        'description': 'Kartu tanda mahasiswa warna biru',
      },
      {
        'id': '2',
        'title': 'Kunci Motor Honda Vario',
        'category': 'Kunci',
        'location': 'Parkiran Gedung B',
        'description': 'Gantungan kunci kulit hitam',
      },
      {
        'id': '3',
        'title': 'Charger Laptop MacBook Pro',
        'category': 'Elektronik',
        'location': 'Ruang Kelas A301',
        'description': 'Adaptor 67W putih',
      },
    ];

    final searchQueries = <String>[
      'ktm', 'KTM', 'Ktm', '  ktm  ', '   KTM   ',
      'kunci motor', 'KUNCI MOTOR', '  kunci   motor  ', '\tkunci\nmotor\t', 'vario',
      'charger', 'CHARGER', '  macbook   pro ', 'laptop', 'adaptor',
      'perpustakaan', 'PERPUSTAKAAN LANTAI 2', '  perpustakaan   lantai   2 ', 'lantai 2', 'gedung b',
      'parkiran', '  parkiran   gedung   b ', 'ruang kelas', 'a301', 'A301',
      'dokumen', 'DOKUMEN', '  dokumen  ', 'elektronik', 'ELEKTRONIK',
      'kunci', '  kunci ', 'informatika', 'biru', 'putih',
    ];

    for (var i = 0; i < searchQueries.length; i++) {
      final query = searchQueries[i];
      test('Search #${i + 1}: query "$query" mengembalikan hasil yang sesuai', () async {
        final mockClient = MockClient((_) async => http.Response(jsonEncode(sampleReports), 200));
        final repo = ReportRepository(client: mockClient);
        final results = await repo.fetchReports(query: query);
        expect(results, isNotEmpty);
      });
    }
  });

  // 2. 40 Unit Test untuk Issue #5 (Validasi input kosong / spasi berlebih)
  group('Issue #5: Validasi Form Input Kosong & Spasi (40 Tes)', () {
    final invalidSpaces = [
      null, '', ' ', '   ', '\t', '\n', ' \t\n ', 'ab', '  a  ', '  xy ',
    ];

    for (var i = 0; i < invalidSpaces.length; i++) {
      final input = invalidSpaces[i];
      test('Validator Title Invalid #${i + 1}: menolak "$input"', () {
        expect(ReportValidator.validateTitle(input), isNotNull);
      });
      test('Validator Location Invalid #${i + 1}: menolak "$input"', () {
        expect(ReportValidator.validateLocation(input), isNotNull);
      });
    }

    final validTitles = [
      'KTM', '  Dompet Kulit  ', 'Charger HP', 'Botol Minum', 'Kunci Kos',
      'Jaket Almamater', 'Flashdisk 32GB', 'Kacamata Minus', 'Payung Lipat', 'Topi Hitam',
    ];
    for (var i = 0; i < validTitles.length; i++) {
      test('Validator Title Valid #${i + 1}: menerima "${validTitles[i]}"', () {
        expect(ReportValidator.validateTitle(validTitles[i]), isNull);
      });
    }

    final contactCases = <MapEntry<String?, bool>>[
      const MapEntry(null, false),
      const MapEntry('', false),
      const MapEntry('     ', false),
      const MapEntry('12345', false),
      const MapEntry('bukan-kontak', false),
      const MapEntry('081234567890', true),
      const MapEntry('+62 812-3456-7890', true),
      const MapEntry('budi@student.pradita.ac.id', true),
      const MapEntry('@budi_pradita', true),
      const MapEntry('  08987654321  ', true),
    ];
    for (var i = 0; i < contactCases.length; i++) {
      final entry = contactCases[i];
      test('Validator Contact #${i + 1}: "${entry.key}" -> valid=${entry.value}', () {
        final result = ReportValidator.validateContact(entry.key);
        expect(result == null, entry.value);
      });
    }
  });

  // 3. 25 Unit Test untuk Issue #6 (ReportStatus & Normalisasi 'OPEN')
  group('Issue #6: ReportStatus & Normalisasi Status OPEN (25 Tes)', () {
    final activeInputs = [
      'OPEN', 'open', 'Open', ' OPEN ', 'ACTIVE', 'active', 'Active', ' ACTIVE ',
      null, '', '   ', 'PENDING', 'UNKNOWN',
    ];
    for (var i = 0; i < activeInputs.length; i++) {
      test('Status Active #${i + 1}: "${activeInputs[i]}" -> ACTIVE', () {
        final status = ReportStatus.fromString(activeInputs[i]);
        expect(status, ReportStatus.active);
        expect(status.value, 'ACTIVE');
      });
    }

    final resolvedInputs = [
      'RESOLVED', 'resolved', 'Resolved', ' RESOLVED ',
      'CLOSED', 'closed', 'DONE', 'done',
    ];
    for (var i = 0; i < resolvedInputs.length; i++) {
      test('Status Resolved #${i + 1}: "${resolvedInputs[i]}" -> RESOLVED', () {
        final status = ReportStatus.fromString(resolvedInputs[i]);
        expect(status, ReportStatus.resolved);
        expect(status.value, 'RESOLVED');
      });
    }

    for (var i = 0; i < 4; i++) {
      test('Seed Report & Model Normalization #${i + 1}', () {
        final seed = ReportRepository.seedReports;
        expect(seed[i % seed.length].isActive, isTrue);
        final parsed = ReportModel.fromJson({
          'id': '$i',
          'title': 'Barang $i',
          'status': 'OPEN',
        });
        expect(parsed.isActive, isTrue);
        expect(parsed.isResolved, isFalse);
      });
    }
  });

  // 4. 25 Unit Test untuk Issue #7 (Penyimpanan Path/URL Foto pada ReportModel)
  group('Issue #7: Penyimpanan Foto pada ReportModel (25 Tes)', () {
    for (var i = 1; i <= 15; i++) {
      test('ImagePath Persistence #${i}: menyimpan & serialisasi path gambar ke-$i', () {
        final path = '/storage/emulated/0/DCIM/foto_barang_$i.jpg';
        final model = ReportModel(
          id: '$i',
          title: 'Barang Foto $i',
          category: 'Elektronik',
          location: 'Gedung A',
          description: 'Deskripsi barang ke-$i',
          type: 'LOST',
          imagePath: path,
        );
        expect(model.hasImage, isTrue);
        final json = model.toJson();
        expect(json['imagePath'], path);
        final restored = ReportModel.fromJson(json);
        expect(restored.imagePath, path);
      });
    }

    for (var i = 1; i <= 10; i++) {
      test('ImageUrl Fallback & Null Handling #${i}', () {
        if (i % 2 == 0) {
          final m = ReportModel.fromJson({
            'id': '$i',
            'title': 'Item $i',
            'imageUrl': 'https://example.com/img_$i.png',
          });
          expect(m.hasImage, isTrue);
          expect(m.imagePath, 'https://example.com/img_$i.png');
        } else {
          final m = ReportModel.fromJson({'id': '$i', 'title': 'Item $i'});
          expect(m.hasImage, isFalse);
          expect(m.imagePath, isNull);
        }
      });
    }
  });

  // 5. 25 Unit Test untuk Issue #8 (Persistensi CRUD & Cache Lokal SharedPreferences)
  group('Issue #8: Persistensi CRUD & Sinkronisasi Cache Lokal (25 Tes)', () {
    for (var i = 1; i <= 10; i++) {
      test('Submit & Persist Local Cache #${i}: laporan ke-$i bertahan antar instance', () async {
        final mockClient = MockClient((req) async {
          if (req.method == 'POST') return http.Response('{"id":"$i"}', 201);
          return http.Response('[]', 200);
        });
        final repo1 = ReportRepository(client: mockClient);
        await repo1.submitReport(
          ReportModel(
            id: 'local_$i',
            title: 'Barang Persisten $i',
            category: 'Dokumen',
            location: 'Lobby',
            description: 'Tersimpan lokal',
            type: 'FOUND',
          ),
        );

        // Buat instance repository baru untuk simulasi aplikasi dibuka ulang
        final repo2 = ReportRepository(client: mockClient);
        final fetched = await repo2.fetchReports();
        expect(fetched.any((e) => e.id == 'local_$i'), isTrue);
      });
    }

    for (var i = 1; i <= 8; i++) {
      test('Update Status & Persist #${i}: status RESOLVED bertahan di cache', () async {
        final mockClient = MockClient((req) async {
          if (req.method == 'PUT') return http.Response('{}', 200);
          return http.Response('[]', 200);
        });
        final repo = ReportRepository(client: mockClient);
        final report = ReportModel(
          id: 'upd_$i',
          title: 'Barang Update $i',
          category: 'Kunci',
          location: 'Kantin',
          description: 'Kunci motor',
          type: 'LOST',
        );
        await repo.submitReport(report);
        await repo.updateReport(report.copyWith(status: 'RESOLVED'));

        final fetched = await repo.fetchReports();
        final found = fetched.firstWhere((e) => e.id == 'upd_$i');
        expect(found.isResolved, isTrue);
      });
    }

    for (var i = 1; i <= 7; i++) {
      test('Delete & Restore Report #${i}: menghapus dan mengembalikan laporan ke-$i', () async {
        final mockClient = MockClient((req) async => http.Response('[]', 200));
        final repo = ReportRepository(client: mockClient);
        final report = ReportModel(
          id: 'del_$i',
          title: 'Barang Hapus $i',
          category: 'Umum',
          location: 'Kelas',
          description: 'Deskripsi',
          type: 'LOST',
        );
        await repo.submitReport(report);
        await repo.deleteReport('del_$i');
        expect((await repo.fetchReports()).any((e) => e.id == 'del_$i'), isFalse);

        await repo.restoreReport(report);
        expect((await repo.fetchReports()).any((e) => e.id == 'del_$i'), isTrue);
      });
    }
  });

  // 6. 20 Unit Test untuk Issue #9 (Retensi Query Pencarian & Debounce)
  group('Issue #9: Retensi Query Pencarian & Debounce State (20 Tes)', () {
    for (var i = 1; i <= 10; i++) {
      test('Query Retention #${i}: currentQuery dipertahankan setelah markAsResolved & deleteReport', () async {
        final mockClient = MockClient((_) async => http.Response(
              jsonEncode([
                {
                  'id': '$i',
                  'title': 'KTM Mahasiswa $i',
                  'category': 'Dokumen',
                  'location': 'Perpustakaan',
                  'status': 'ACTIVE',
                }
              ]),
              200,
            ));
        final repo = ReportRepository(client: mockClient);
        final notifier = ReportListNotifier(repo);
        await notifier.loadReports(query: 'KTM');
        expect(notifier.state.currentQuery, 'KTM');

        await notifier.markAsResolved(notifier.state.reports.first);
        expect(notifier.state.currentQuery, 'KTM');

        await notifier.deleteReport('$i');
        expect(notifier.state.currentQuery, 'KTM');
        notifier.dispose();
      });
    }

    for (var i = 1; i <= 10; i++) {
      test('Debounce Search #${i}: onSearchChanged memperbarui currentQuery dan memicu fetch ter-debounce', () async {
        final mockClient = MockClient((_) async => http.Response('[]', 200));
        final repo = ReportRepository(client: mockClient);
        final notifier = ReportListNotifier(repo);
        await notifier.loadReports();

        notifier.onSearchChanged('kunci_$i', debounce: const Duration(milliseconds: 20));
        expect(notifier.state.currentQuery, 'kunci_$i');
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(notifier.state.status, ListStatus.empty);
        notifier.dispose();
      });
    }
  });

  // 7. 20 Unit Test untuk Issue #10 & #11 (Otorisasi Pemilik & Tautan WhatsApp Kontak)
  group('Issue #10 & #11: Otorisasi Pemilik & URI Kontak Pelapor (20 Tes)', () {
    for (var i = 1; i <= 10; i++) {
      test('Ownership Check #${i}: hanya pemilik atau admin yang dapat memodifikasi laporan', () {
        final report = ReportModel(
          id: '$i',
          title: 'Barang $i',
          category: 'Elektronik',
          location: 'Lab',
          description: 'Deskripsi',
          type: 'LOST',
          ownerId: 'owner_A',
        );
        expect(report.canModify('owner_A'), isTrue);
        expect(report.canModify('user_B'), isFalse);
        expect(report.canModify('user_B', isAdmin: true), isTrue);
      });
    }

    final contactUriCases = <List<String>>[
      ['081234567890', 'https://wa.me/6281234567890'],
      ['+62 812-3456-7890', 'https://wa.me/6281234567890'],
      ['628987654321', 'https://wa.me/628987654321'],
      ['0857-1122-3344', 'https://wa.me/6285711223344'],
      ['08111222333', 'https://wa.me/628111222333'],
      ['@mahasiswa_pradita', 'https://instagram.com/mahasiswa_pradita'],
      ['@pradita.find', 'https://instagram.com/pradita.find'],
      ['budi@student.pradita.ac.id', 'mailto:budi@student.pradita.ac.id'],
      ['siti@pradita.ac.id', 'mailto:siti@pradita.ac.id'],
      ['081900001111', 'https://wa.me/6281900001111'],
    ];

    for (var i = 0; i < contactUriCases.length; i++) {
      test('Contact URI Builder #${i + 1}: ${contactUriCases[i][0]} -> ${contactUriCases[i][1]}', () {
        final uri = ReportDetailPage.buildContactUri(contactUriCases[i][0]);
        expect(uri.toString(), contactUriCases[i][1]);
      });
    }
  });

  // 8. 10 Widget & Integration Tests untuk Issues #6, #7, #10, #11
  group('Widget & Integration Tests PraFind P11 (10 Tes)', () {
    testWidgets('Widget #1: Laporan berstatus OPEN menampilkan tombol tandai selesai', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'KTM Mahasiswa',
                'status': 'OPEN',
                'ownerId': AuthSession.defaultUserId,
              }
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
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('Widget #2: Laporan milik pengguna lain menyembunyikan tombol hapus & selesai', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '2',
                'title': 'Barang Orang Lain',
                'status': 'ACTIVE',
                'ownerId': 'pemilik_lain_99',
              }
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
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });

    testWidgets('Widget #3: Menekan ikon hapus menampilkan dialog konfirmasi', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'KTM Mahasiswa',
                'status': 'ACTIVE',
                'ownerId': AuthSession.defaultUserId,
              }
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
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Hapus laporan ini?'), findsOneWidget);
    });

    testWidgets('Widget #4: Konfirmasi hapus menampilkan SnackBar dengan tombol Urungkan', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'KTM Mahasiswa',
                'status': 'ACTIVE',
                'ownerId': AuthSession.defaultUserId,
              }
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
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(find.text('Urungkan'), findsOneWidget);
    });

    testWidgets('Widget #5: Ketuk kartu laporan membuka halaman ReportDetailPage', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'KTM Mahasiswa',
                'category': 'Dokumen',
                'location': 'Perpustakaan',
                'description': 'KTM atas nama Budi',
                'reporterName': 'Budi Santoso',
                'contact': '081234567890',
                'status': 'ACTIVE',
              }
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
      await tester.tap(find.text('KTM Mahasiswa'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Laporan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Hubungi Pelapor'), findsOneWidget);
    });

    testWidgets('Widget #6: ReportDetailPage menampilkan info lengkap & tombol hubungi', (tester) async {
      final report = ReportModel(
        id: '10',
        title: 'Dompet Kulit Coklat',
        category: 'Aksesoris',
        location: 'Kantin Lt. 1',
        description: 'Berisi kartu ATM dan KTP',
        type: 'LOST',
        reporterName: 'Andi Wijaya',
        contact: '081234567890',
      );
      await tester.pumpWidget(
        MaterialApp(home: ReportDetailPage(report: report)),
      );
      expect(find.text('Dompet Kulit Coklat'), findsOneWidget);
      expect(find.text('Andi Wijaya'), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.byKey(const Key('contact_reporter_button')), findsOneWidget);
    });

    testWidgets('Widget #7: CreateReportPage menampilkan pemilih LOST/FOUND & field kontak', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CreateReportPage())),
      );
      expect(find.text('Kehilangan (LOST)'), findsOneWidget);
      expect(find.text('Menemukan (FOUND)'), findsOneWidget);
      expect(find.byKey(const Key('reporter_name_input')), findsOneWidget);
      expect(find.byKey(const Key('contact_input')), findsOneWidget);
    });

    testWidgets('Widget #8: CreateReportPage menolak input hanya spasi pada kolom kontak', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CreateReportPage())),
      );
      await tester.enterText(find.byKey(const Key('title_input')), 'Dompet');
      await tester.enterText(find.byKey(const Key('location_input')), 'Lobby');
      await tester.enterText(find.byKey(const Key('description_input')), 'Dompet hitam');
      await tester.enterText(find.byKey(const Key('contact_input')), '    ');

      final submitBtn = find.byKey(const Key('submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Kontak pelapor wajib diisi'), findsOneWidget);
    });

    testWidgets('Widget #9: Menandai laporan selesai mengubah teks menjadi coretan', (tester) async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode([
              {
                'id': '1',
                'title': 'Charger MacBook',
                'status': 'ACTIVE',
                'ownerId': AuthSession.defaultUserId,
              }
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
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();

      final titleWidget = tester.widget<Text>(find.text('Charger MacBook'));
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('Widget #10: ReportDetailPage merender fallback foto jika tidak ada lampiran', (tester) async {
      final report = ReportModel(
        id: '11',
        title: 'Payung Biru',
        category: 'Umum',
        location: 'Halte Kampus',
        description: 'Payung lipat otomatis',
        type: 'FOUND',
      );
      await tester.pumpWidget(MaterialApp(home: ReportDetailPage(report: report)));
      expect(find.text('Tidak ada foto dilampirkan'), findsOneWidget);
    });
  });
}
