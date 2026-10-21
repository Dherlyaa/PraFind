import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/report_model.dart';

class ReportRepository {
  final http.Client client;
  final String baseUrl = 'https://api.praditafind.com/v1'; // Dummy URL

  ReportRepository({required this.client});

  // READ (GET dari API)
  Future<List<ReportModel>> fetchReports({String query = ''}) async {

    // KODE ASLI DI BAWAH INI (Akan diabaikan saat demo karena sudah di-return di atas)
    try {
      final response = await client.get(Uri.parse('$baseUrl/reports'));

      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(response.body);
        
        if (decodedList.isEmpty) return [];

        final allData = decodedList.map((item) => ReportModel.fromJson(item)).toList();
        
        if (query.isEmpty) return allData;
        return allData.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        throw Exception('Gagal memuat data dari API. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  } // <-- Penutup fungsi yang benar ada di paling bawah ini

  // CREATE (POST ke API)
  Future<bool> submitReport(ReportModel report) async {
    final response = await client.post(
      Uri.parse('$baseUrl/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // UPDATE (PUT ke API)
  Future<bool> updateReport(ReportModel updatedReport) async {
    final response = await client.put(
      Uri.parse('$baseUrl/reports/${updatedReport.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedReport.toJson()),
    );
    return response.statusCode == 200;
  }

  // DELETE (DELETE ke API)
  Future<bool> deleteReport(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/reports/$id'));
    return response.statusCode == 200;
  }
}