import 'package:http/http.dart' as http;
import '../domain/report_model.dart';

class ReportRepository {
  final http.Client client;
  final String baseUrl = 'https://6ae42e2d933120ae20f98e78.mockapi.io';

  // Data dummy yang disimpan di RAM selama aplikasi berjalan
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

  // READ (GET lokal)
  Future<List<ReportModel>> fetchReports({String query = ''}) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
    if (query.isEmpty) return _mockData;
    return _mockData
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // CREATE (POST lokal)
  Future<bool> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockData.insert(0, report);
    return true;
  }

  // UPDATE (PUT lokal)
  Future<bool> updateReport(ReportModel updatedReport) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockData.indexWhere((r) => r.id == updatedReport.id);
    if (index != -1) {
      _mockData[index] = updatedReport;
      return true;
    }
    return false;
  }

  // DELETE (DELETE lokal)
  Future<bool> deleteReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockData.removeWhere((r) => r.id == id);
    return true;
  }
}