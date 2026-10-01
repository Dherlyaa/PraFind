import '../domain/report_model.dart';

class ReportRepository {
  // Simulasi fetch kategori dari API/Backend
  Future<List<String>> fetchCategories({bool causeError = false, bool forceEmpty = false}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (causeError) {

      throw Exception('Gagal terhubung ke server kampus');
    }
    
    if (forceEmpty) {
      return [];
    }

    return ['Elektronik', 'Dokumen / KTM', 'Pakaian & Jaket', 'Kunci', 'Lainnya'];
  }

  // Simulasi kirim data laporan ke Backend
  Future<bool> submitReport(ReportModel report) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}