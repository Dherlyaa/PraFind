import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/create_report_provider.dart';
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
  String _selectedType = 'LOST';
  String _selectedCategory = 'Elektronik';

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // KONDISI 5: Trigger Validasi Input pada Form
    if (_formKey.currentState!.validate()) {
      final report = ReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
      );

      final success = await ref.read(createReportProvider.notifier).submitReport(report);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan Berhasil Dikirim!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createReportProvider);
    
    // KONDISI 6: Cek status submitting untuk mencegah double tap
    final isSubmitting = formState.status == FormSubmitStatus.submitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('title_input'),
                controller: _titleController,
                enabled: !isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                ),
                // KONDISI 5: Aturan Validasi
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: ['Elektronik', 'Dokumen', 'Kunci', 'Pakaian']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: isSubmitting ? null : (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('location_input'),
                controller: _locationController,
                enabled: !isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Kejadian',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Lokasi kejadian wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('description_input'),
                controller: _descriptionController,
                enabled: !isSubmitting,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // KONDISI 6: UI Loading saat submit (onPressed = null jika submitting)
              ElevatedButton(
                key: const Key('submit_button'),
                onPressed: isSubmitting ? null : _submitForm,
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
      ),
    );
  }
}