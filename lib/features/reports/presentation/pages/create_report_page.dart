import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/create_report_provider.dart';
import '../../domain/report_model.dart';
import '../../domain/report_validator.dart';

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

  XFile? _imageFile;
  bool _isLocationLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('GPS tidak aktif. Harap nyalakan GPS perangkat Anda.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak pengguna.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Ubah di pengaturan HP.');
      }

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _locationController.text = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  void _submitForm() async {
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

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan Berhasil Dikirim!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan laporan. Coba lagi.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createReportProvider);
    final isSubmitting = formState.status == FormSubmitStatus.submitting;

    // Komponen Input Data (Kiri pada layar lebar)
    Widget formInputs = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: const Key('title_input'),
          controller: _titleController,
          enabled: !isSubmitting,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Nama Barang',
            helperText: 'Contoh: KTM, Charger, Dompet',
            border: OutlineInputBorder(),
          ),
          validator: ReportValidator.validateTitle,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                key: const Key('location_input'),
                controller: _locationController,
                enabled: !isSubmitting,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Kejadian',
                  helperText: 'Gunakan tombol di samping untuk akurasi',
                  border: OutlineInputBorder(),
                ),
                validator: ReportValidator.validateLocation,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: IconButton.filledTonal(
                onPressed: _isLocationLoading || isSubmitting ? null : _getCurrentLocation,
                icon: _isLocationLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                tooltip: 'Gunakan lokasi saat ini',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('description_input'),
          controller: _descriptionController,
          enabled: !isSubmitting,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Deskripsi',
            helperText: 'Jelaskan ciri-ciri barang secara detail',
            border: OutlineInputBorder(),
          ),
          validator: ReportValidator.validateDescription,
        ),
      ],
    );

    // Komponen Media & Aksi (Kanan pada layar lebar)
    Widget formActions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                      : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                )
              : const Center(child: Text('Belum ada foto yang dipilih')),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: isSubmitting ? null : () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kamera'),
            ),
            TextButton.icon(
              onPressed: isSubmitting ? null : () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text('Galeri'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          key: const Key('submit_button'),
          onPressed: isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(48),
          ),
          child: isSubmitting
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    SizedBox(width: 12),
                    Text('Menyimpan...'),
                  ],
                )
              : const Text('Kirim Laporan'),
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Buat Laporan Baru')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth >= 700;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16.0),
                    child: isWideScreen
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: formInputs),
                              const SizedBox(width: 32),
                              Expanded(flex: 2, child: formActions),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              formInputs,
                              const SizedBox(height: 24),
                              formActions,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}