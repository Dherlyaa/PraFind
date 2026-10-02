import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/report_repository.dart';
import '../../domain/report_model.dart';
import 'report_list_provider.dart';

enum FormSubmitStatus { idle, submitting, success, error }

class CreateReportState {
  final FormSubmitStatus status;
  final String errorMessage;

  CreateReportState({
    this.status = FormSubmitStatus.idle,
    this.errorMessage = '',
  });

  CreateReportState copyWith({
    FormSubmitStatus? status,
    String? errorMessage,
  }) {
    return CreateReportState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CreateReportNotifier extends StateNotifier<CreateReportState> {
  final ReportRepository repository;
  final Ref ref;

  CreateReportNotifier(this.repository, this.ref) : super(CreateReportState());

  Future<bool> submitReport(ReportModel report) async {
    // Mengubah status ke submitting untuk mencegah double tap pada UI
    state = state.copyWith(status: FormSubmitStatus.submitting);

    try {
      await repository.submitReport(report);
      state = state.copyWith(status: FormSubmitStatus.success);
      
      // Auto refresh data di Fitur 1 setelah submit berhasil
      ref.read(reportListProvider.notifier).loadReports();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FormSubmitStatus.error,
        errorMessage: 'Gagal mengirim laporan.',
      );
      return false;
    }
  }
}

final createReportProvider =
    StateNotifierProvider<CreateReportNotifier, CreateReportState>((ref) {
  return CreateReportNotifier(ref.watch(reportRepositoryProvider), ref);
});