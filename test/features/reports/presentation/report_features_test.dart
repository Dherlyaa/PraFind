import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../../lib/features/reports/data/report_repository.dart';
import '../../../../lib/features/reports/domain/report_model.dart';

void main() {
  group('UNIT TEST: Model & API (Tugas P6)', () {
    // 1. Model Valid
    test('Model valid dapat di-parse dari JSON', () {
      final json = {'id': '1', 'title': 'Tas Hitam', 'category': 'Aksesoris'};
      final model = ReportModel.fromJson(json);
      expect(model.id, '1');
      expect(model.title, 'Tas Hitam');
    });

    // 2. Model Invalid
    test('Model melempar FormatException jika JSON kehilangan field id/title', () {
      final invalidJson = {'category': 'Aksesoris'}; // id dan title hilang
      expect(() => ReportModel.fromJson(invalidJson), throwsA(isA<FormatException>()));
    });

    // 3. API Sukses
    test('Mengembalikan List ReportModel jika HTTP 200 (Sukses)', () async {
      final mockClient = MockClient((request) async {
        final mockResponse = jsonEncode([
          {'id': '101', 'title': 'Kunci Motor', 'category': 'Kunci'}
        ]);
        return http.Response(mockResponse, 200);
      });
      final repo = ReportRepository(client: mockClient);
      final result = await repo.fetchReports();
      expect(result.length, 1);
      expect(result.first.title, 'Kunci Motor');
    });

    // 4. Data Kosong
    test('Mengembalikan List kosong jika API merespon array kosong', () async {
      final mockClient = MockClient((req) async => http.Response('[]', 200));
      final repo = ReportRepository(client: mockClient);
      final result = await repo.fetchReports();
      expect(result.isEmpty, true);
    });

    // 5. HTTP Gagal
    test('Melempar Exception jika HTTP status bukan 200', () async {
      final mockClient = MockClient((req) async => http.Response('Not Found', 404));
      final repo = ReportRepository(client: mockClient);
      expect(repo.fetchReports(), throwsException);
    });

    // 6. JSON Rusak
    test('Melempar error jika JSON dari API rusak', () async {
      final mockClient = MockClient((req) async => http.Response('Data bukan json {', 200));
      final repo = ReportRepository(client: mockClient);
      expect(repo.fetchReports(), throwsFormatException);
    });
  });
}