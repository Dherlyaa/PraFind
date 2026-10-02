import '../domain/report_model.dart';

class ReportRepository {
  // Simulasi database lokal/remote
  final List<ReportModel> _dummyData = [
    ReportModel(
      id: '1',
      title: 'KTM A.N Budi',
      category: 'Dokumen',
      location: 'Gedung A Lnt 2',
      description: 'KTM tertinggal di lab komputer',
      type: 'FOUND',
    ),
    ReportModel(
      id: '2',
      title: 'Charger Laptop Type C',
      category: 'Elektronik',
      location: 'Kantin',
      description: 'Charger warna hitam merek Anker',
      type: 'LOST',
    ),
  ];

  // Fitur 1 Data Provider: Fetch list barang
  Future<List<ReportModel>> fetchReports({
    String query = '',
    bool forceError = false,
    bool forceEmpty = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (forceError) {
      throw Exception('Gagal memuat data dari server kampus.');
    }

    if (forceEmpty) {
      return [];
    }

    if (query.isEmpty) return _dummyData;

    return _dummyData
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Fitur 2 Data Provider: Submit Form
  Future<bool> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi network delay
    _dummyData.add(report);
    return true;
  }
}