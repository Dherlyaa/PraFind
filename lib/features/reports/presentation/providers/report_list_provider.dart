import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/report_repository.dart';
import '../../domain/report_model.dart';

enum ListStatus { initialLoading, success, empty, error }

class ReportListState {
  final ListStatus status;
  final List<ReportModel> reports;
  final String errorMessage;

  ReportListState({
    required this.status,
    this.reports = const [],
    this.errorMessage = '',
  });

  ReportListState copyWith({ListStatus? status, List<ReportModel>? reports, String? errorMessage}) {
    return ReportListState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReportListNotifier extends StateNotifier<ReportListState> {
  final ReportRepository repository;

  ReportListNotifier(this.repository) : super(ReportListState(status: ListStatus.initialLoading)) {
    loadReports();
  }

  Future<void> loadReports({String query = ''}) async {
    state = state.copyWith(status: ListStatus.initialLoading);
    try {
      final result = await repository.fetchReports(query: query);
      if (result.isEmpty) {
        state = state.copyWith(status: ListStatus.empty, reports: []);
      } else {
        state = state.copyWith(status: ListStatus.success, reports: result);
      }
    } catch (e) {
      state = state.copyWith(status: ListStatus.error, errorMessage: e.toString());
    }
  }

  // Fungsi RETRY yang diminta dosen
  void retry() => loadReports();

  Future<void> markAsResolved(ReportModel report) async {
    final updatedReport = ReportModel(
      id: report.id, title: report.title, category: report.category, 
      location: report.location, description: report.description, type: report.type, status: 'RESOLVED',
    );
    await repository.updateReport(updatedReport);
    loadReports();
  }

  Future<void> deleteReport(String id) async {
    await repository.deleteReport(id);
    loadReports();
  }
}

// Injeksi API Client
final httpClientProvider = Provider((ref) => http.Client());

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(client: ref.watch(httpClientProvider));
});

final reportListProvider = StateNotifierProvider<ReportListNotifier, ReportListState>((ref) {
  return ReportListNotifier(ref.watch(reportRepositoryProvider));
});