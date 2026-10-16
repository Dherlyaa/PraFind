import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/report_model.dart';

class ReportRepository {
  static const String _storageKey = 'pradita_reports_data';

  Future<List<ReportModel>> fetchReports({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_storageKey);
    
    if (jsonData == null) return [];

    final List<dynamic> decodedList = jsonDecode(jsonData);
    final List<ReportModel> allData = decodedList.map((item) => ReportModel.fromJson(item)).toList();

    if (query.isEmpty) return allData;
    return allData.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<bool> submitReport(ReportModel report) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ReportModel> currentData = await fetchReports();
    currentData.add(report);
    return _saveData(prefs, currentData);
  }

  Future<bool> updateReport(ReportModel updatedReport) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ReportModel> currentData = await fetchReports();
    
    final index = currentData.indexWhere((r) => r.id == updatedReport.id);
    if (index != -1) {
      currentData[index] = updatedReport;
      return _saveData(prefs, currentData);
    }
    return false;
  }

  Future<bool> deleteReport(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ReportModel> currentData = await fetchReports();
    
    currentData.removeWhere((r) => r.id == id);
    return _saveData(prefs, currentData);
  }

  Future<bool> _saveData(SharedPreferences prefs, List<ReportModel> data) {
    final String encodedData = jsonEncode(data.map((r) => r.toJson()).toList());
    return prefs.setString(_storageKey, encodedData);
  }
}
