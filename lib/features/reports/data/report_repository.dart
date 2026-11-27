import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_logger.dart';
import '../domain/report_model.dart';

class ReportRepository {
  final http.Client client;
  final String baseUrl = 'https://6ae42e2d933120ae20f98e78.mockapi.io';
  static const String _cacheStorageKey = 'prafind_cached_reports_v1';

  // Data awal menggunakan status ACTIVE yang seragam dengan model & UI (Issue #6)
  static List<ReportModel> _defaultSeedData() => [
        ReportModel(
          id: '1',
          title: 'KTM Mahasiswa',
          category: 'Dokumen',
          location: 'Perpustakaan Lantai 2',
          description: 'Ditemukan KTM atas nama Budi di meja baca lantai 2.',
          type: 'FOUND',
          status: ReportStatus.active.value,
          ownerId: 'user_pradita_01',
          reporterName: 'Budi Santoso',
          contact: '081234567890',
          createdAt: DateTime(2026, 11, 26, 10, 30),
        ),
        ReportModel(
          id: '2',
          title: 'Charger Laptop MacBook',
          category: 'Elektronik',
          location: 'Ruang Kelas A301',
          description: 'Kehilangan charger USB-C warna putih, mohon infonya.',
          type: 'LOST',
          status: ReportStatus.active.value,
          ownerId: 'user_pradita_02',
          reporterName: 'Siti Rahma',
          contact: '081298765432',
          createdAt: DateTime(2026, 11, 26, 14, 15),
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
      final remoteReports = decoded
          .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Gabungkan data backend dengan cache lokal agar laporan baru tidak hilang saat aplikasi ditutup (Issue #8)
      final cachedReports = await _readLocalCache();
      final mergedReports = _mergeRemoteAndLocal(remoteReports, cachedReports);
      await _writeLocalCache(mergedReports);

      AppLogger.info('ReportRepository', 'Berhasil memuat ${mergedReports.length} laporan');
      return _filterByQuery(mergedReports, query);
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
    try {
      await client.post(
        _reportsUri(),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(report.toJson()),
      );
    } catch (e) {
      AppLogger.warn('ReportRepository', 'Sinkronisasi POST tertunda, menyimpan ke cache lokal: $e');
    }

    final current = await _readLocalCache();
    current.removeWhere((item) => item.id == report.id);
    current.insert(0, report);
    await _writeLocalCache(current);
    return true;
  }

  Future<bool> updateReport(ReportModel updatedReport) async {
    AppLogger.info('ReportRepository', 'updateReport dipanggil (id: ${updatedReport.id})');
    try {
      await client.put(
        _reportDetailUri(updatedReport.id),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedReport.toJson()),
      );
    } catch (e) {
      AppLogger.warn('ReportRepository', 'Sinkronisasi PUT tertunda, memperbarui cache lokal: $e');
    }

    final current = await _readLocalCache();
    final index = current.indexWhere((report) => report.id == updatedReport.id);
    if (index != -1) {
      current[index] = updatedReport;
    } else {
      current.insert(0, updatedReport);
    }
    await _writeLocalCache(current);
    return true;
  }

  Future<bool> deleteReport(String id) async {
    AppLogger.info('ReportRepository', 'deleteReport dipanggil (id: $id)');
    try {
      await client.delete(_reportDetailUri(id));
    } catch (e) {
      AppLogger.warn('ReportRepository', 'Sinkronisasi DELETE tertunda, menghapus di cache lokal: $e');
    }

    final current = await _readLocalCache();
    current.removeWhere((report) => report.id == id);
    await _writeLocalCache(current);
    return true;
  }

  Future<bool> restoreReport(ReportModel report) async {
    AppLogger.info('ReportRepository', 'restoreReport dipanggil (id: ${report.id})');
    return submitReport(report);
  }

  Uri _reportsUri() => Uri.parse('$baseUrl/reports');
  Uri _reportDetailUri(String id) => Uri.parse('$baseUrl/reports/$id');

  // Pencarian case-insensitive dan menormalkan spasi berlebih pada title, category, dan location (Issue #4)
  List<ReportModel> _filterByQuery(List<ReportModel> reports, String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return reports;

    return reports.where((item) {
      final searchable = _normalizeSearchText(
        '${item.title} ${item.category} ${item.location} ${item.description}',
      );
      return searchable.contains(normalizedQuery);
    }).toList();
  }

  String _normalizeSearchText(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  List<ReportModel> _mergeRemoteAndLocal(
    List<ReportModel> remote,
    List<ReportModel> local,
  ) {
    if (local.isEmpty) return remote;
    final byId = <String, ReportModel>{
      for (final item in remote) item.id: item,
    };
    for (final localItem in local) {
      byId[localItem.id] = localItem;
    }
    return byId.values.toList();
  }

  Future<List<ReportModel>> _readLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheStorageKey);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeLocalCache(List<ReportModel> reports) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(reports.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheStorageKey, encoded);
    } catch (_) {
      // Abaikan jika binding SharedPreferences tidak tersedia di lingkungan test tertentu
    }
  }

  // Helper seed data jika diperlukan saat inisialisasi offline
  static List<ReportModel> get seedReports => _defaultSeedData();
}
