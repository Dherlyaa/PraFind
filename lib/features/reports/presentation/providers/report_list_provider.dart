import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/report_repository.dart';
import '../../domain/report_model.dart';

enum ListStatus { initialLoading, success, empty, error }

class ReportListState {
  final ListStatus status;
  final List<ReportModel> reports;
  final String errorMessage;
  // Menyimpan query pencarian aktif agar tidak hilang setelah aksi tandai selesai/hapus (Issue #9)
  final String currentQuery;

  ReportListState({
    required this.status,
    this.reports = const [],
    this.errorMessage = '',
    this.currentQuery = '',
  });

  ReportListState copyWith({
    ListStatus? status,
    List<ReportModel>? reports,
    String? errorMessage,
    String? currentQuery,
  }) {
    return ReportListState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      errorMessage: errorMessage ?? this.errorMessage,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

class ReportListNotifier extends StateNotifier<ReportListState> {
  final ReportRepository repository;
  Timer? _debounceTimer;
  int _latestRequestId = 0;

  ReportListNotifier(this.repository) : super(ReportListState(status: ListStatus.initialLoading)) {
    loadReports();
  }

  // Pencarian dengan debounce 300ms untuk mencegah request beruntun dan race condition (Issue #9)
  void onSearchChanged(String query, {Duration debounce = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    state = state.copyWith(currentQuery: query);
    _debounceTimer = Timer(debounce, () {
      loadReports(query: query);
    });
  }

  Future<void> loadReports({String? query}) async {
    final effectiveQuery = query ?? state.currentQuery;
    final requestId = ++_latestRequestId;

    state = state.copyWith(
      status: ListStatus.initialLoading,
      currentQuery: effectiveQuery,
    );

    try {
      final result = await repository.fetchReports(query: effectiveQuery);
      // Abaikan respons dari request yang sudah usang (Issue #9)
      if (!mounted || requestId != _latestRequestId) return;

      if (result.isEmpty) {
        state = state.copyWith(status: ListStatus.empty, reports: []);
      } else {
        state = state.copyWith(status: ListStatus.success, reports: result);
      }
    } catch (e) {
      if (!mounted || requestId != _latestRequestId) return;
      state = state.copyWith(status: ListStatus.error, errorMessage: e.toString());
    }
  }

  // Fungsi RETRY yang diminta dosen
  void retry() => loadReports(query: state.currentQuery);

  Future<void> markAsResolved(ReportModel report) async {
    final updatedReport = report.copyWith(status: ReportStatus.resolved.value);
    await repository.updateReport(updatedReport);
    await loadReports(query: state.currentQuery);
  }

  Future<void> deleteReport(String id) async {
    await repository.deleteReport(id);
    await loadReports(query: state.currentQuery);
  }

  Future<void> undoDeleteReport(ReportModel report) async {
    await repository.restoreReport(report);
    await loadReports(query: state.currentQuery);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
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
