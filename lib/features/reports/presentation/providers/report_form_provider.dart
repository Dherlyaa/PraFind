import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/report_repository.dart';
import '../../domain/report_model.dart';

enum FormStatus { initialLoading, success, empty, error, submitting, submitSuccess }

class ReportFormState {
  final FormStatus status;
  final List<String> categories;
  final String? errorMessage;

  ReportFormState({
    required this.status,
    this.categories = const [],
    this.errorMessage,
  });

  ReportFormState copyWith({
    FormStatus? status,
    List<String>? categories,
    String? errorMessage,
  }) {
    return ReportFormState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReportFormNotifier extends StateNotifier<ReportFormState> {
  final ReportRepository repository;

  ReportFormNotifier(this.repository)
      : super(ReportFormState(status: FormStatus.initialLoading)) {
    loadCategories();
  }

  Future<void> loadCategories({bool causeError = false, bool forceEmpty = false}) async {
    state = state.copyWith(status: FormStatus.initialLoading, errorMessage: null);
    try {
      final categories = await repository.fetchCategories(
        causeError: causeError,
        forceEmpty: forceEmpty,
      );
      
      if (categories.isEmpty) {
        state = state.copyWith(status: FormStatus.empty, categories: []);
      } else {
        state = state.copyWith(status: FormStatus.success, categories: categories);
      }
    } catch (e) {
      state = state.copyWith(
        status: FormStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> submitReport(ReportModel report) async {
    state = state.copyWith(status: FormStatus.submitting);
    try {
      await repository.submitReport(report);
      state = state.copyWith(status: FormStatus.submitSuccess);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FormStatus.success,
        errorMessage: 'Gagal mengirim laporan',
      );
      return false;
    }
  }
}

final reportRepositoryProvider = Provider((ref) => ReportRepository());

final reportFormProvider = StateNotifierProvider<ReportFormNotifier, ReportFormState>((ref) {
  return ReportFormNotifier(ref.watch(reportRepositoryProvider));
});