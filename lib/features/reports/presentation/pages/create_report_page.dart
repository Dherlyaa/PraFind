import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_form_provider.dart';
import '../../domain/report_model.dart';

class CreateReportPage extends ConsumerStatefulWidget {
  const CreateReportPage({super.key});

  @override
  ConsumerState<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends ConsumerState<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final report = ReportModel(
        title: _titleController.text,
        category: _selectedCategory!,
        location: _locationController.text,
        description: _descriptionController.text,
      );

      final success = await ref.read(reportFormProvider.notifier).submitReport(report);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan Berhasil Dibuat!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(reportFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Barang')),
      body: _buildBody(context, formState),
    );
  }

  Widget _buildBody(BuildContext context, ReportFormState formState) {
    // KONDISI 1: Initial Loading
    if (formState.status == FormStatus.initialLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat kategori data...'),
          ],
        ),
      );
    }

    // KONDISI 3: Empty State
    if (formState.status == FormStatus.empty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Kategori barang tidak tersedia.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(reportFormProvider.notifier).loadCategories(),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    // KONDISI 4: Error State dengan Tombol Retry
    if (formState.status == FormStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                formState.errorMessage ?? 'Terjadi kesalahan sistem.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                key: const Key('retry_button'),
                onPressed: () => ref.read(reportFormProvider.notifier).loadCategories(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // KONDISI 2, 5, & 6: Data Berhasil Dimuat, Form Validasi, & Submit Loading
    final isSubmitting = formState.status == FormStatus.submitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Field Nama Barang
            TextFormField(
              key: const Key('title_field'),
              controller: _titleController,
              enabled: !isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              // KONDISI 5: Validasi Input
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dropdown Kategori
            DropdownButtonFormField<String>(
              key: const Key('category_dropdown'),
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: formState.categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: isSubmitting ? null : (val) => setState(() => _selectedCategory = val),
              // KONDISI 5: Validasi Dropdown
              validator: (value) {
                if (value == null) {
                  return 'Pilih salah satu kategori';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Field Lokasi
            TextFormField(
              key: const Key('location_field'),
              controller: _locationController,
              enabled: !isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Lokasi Kejadian',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Field Deskripsi
            TextFormField(
              key: const Key('description_field'),
              controller: _descriptionController,
              enabled: !isSubmitting,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Ciri-Ciri',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // KONDISI 6: Loading Saat Submit (Prevent Double Tap)
            ElevatedButton(
              key: const Key('submit_button'),
              // onPressed dikosongkan (null) saat isSubmitting agar tidak bisa di-tap ganda
              onPressed: isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}