import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/utils/app_logger.dart';
import '../domain/report_model.dart';

class ReportRepository {
  final http.Client client;
  final String baseUrl = 'https://6ae42e2d933120ae20f98e78.mockapi.io';

  static final List<ReportModel> _mockData = [
    ReportModel(
      id: '1',
      title: 'KTM Mahasiswa',
      category: 'Dokumen',
      location: 'Perpustakaan Lantai 2',
      description: 'Ditemukan KTM atas nama Budi',
      type: 'FOUND',
      status: 'OPEN',
    ),
    ReportModel(
      id: '2',
      title: 'Charger Laptop MacBook',
      category: 'Elektronik',
      location: 'Ruang Kelas A301',
      description: 'Kehilangan charger warna putih, mohon infonya.',
      type: 'LOST',
      status: 'OPEN',
    ),
  ];

  ReportRepository({required this.client});

  Future<List<ReportModel>> fetchReports({String query = ''}) async {
    final uri = _reportsUri();
    AppLogger.info('ReportRepository', 'fetchReports dipanggil (URI: $uri, query: "$query")');

    final response = await client.get(uri);
    if (response.statusCode != 200) {
      AppLogger.error(
        'ReportRepository',
        'Gagal memuat laporan: HTTP ${response.statusCode}',
      );
      throw Exception('Gagal memuat laporan (HTTP ${response.statusCode})');
    }

    try {
      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      final reports = decoded
          .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.info('ReportRepository', 'Berhasil memuat ${reports.length} laporan');
      return _filterByQuery(reports, query);
    } on FormatException catch (e, stackTrace) {
      AppLogger.error(
        'ReportRepository',
        'FormatException saat mem-parsing JSON laporan',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'ReportRepository',
        'Kesalahan saat memproses data laporan',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> submitReport(ReportModel report) async {
    AppLogger.info('ReportRepository', 'submitReport dipanggil: ${report.title}');
    await _simulateNetworkDelay(const Duration(seconds: 1));
    _mockData.insert(0, report);
    return true;
  }

  Future<bool> updateReport(ReportModel updatedReport) async {
    AppLogger.info('ReportRepository', 'updateReport dipanggil (id: ${updatedReport.id})');
    await _simulateNetworkDelay(const Duration(milliseconds: 500));
    final index = _findReportIndexById(updatedReport.id);
    if (index == -1) return false;

    _mockData[index] = updatedReport;
    return true;
  }

  Future<bool> deleteReport(String id) async {
    AppLogger.info('ReportRepository', 'deleteReport dipanggil (id: $id)');
    await _simulateNetworkDelay(const Duration(milliseconds: 500));
    final index = _findReportIndexById(id);
    if (index == -1) return false;

    _mockData.removeAt(index);
    return true;
  }

  Uri _reportsUri() => Uri.parse('$baseUrl/reports');

  List<ReportModel> _filterByQuery(List<ReportModel> reports, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return reports;
    return reports
        .where((item) => item.title.toLowerCase().contains(trimmed))
        .toList();
  }

  int _findReportIndexById(String id) {
    return _mockData.indexWhere((report) => report.id == id);
  }

  Future<void> _simulateNetworkDelay(Duration duration) {
    return Future.delayed(duration);
  }
}