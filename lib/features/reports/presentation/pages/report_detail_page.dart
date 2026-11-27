import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/report_model.dart';

// Halaman detail laporan barang dengan informasi kontak pelapor & tombol WhatsApp (Issue #11)
class ReportDetailPage extends StatelessWidget {
  final ReportModel report;

  const ReportDetailPage({super.key, required this.report});

  // Mengubah nomor kontak pelapor menjadi tautan WhatsApp https://wa.me/<nomor>
  static Uri buildContactUri(String rawContact) {
    final trimmed = rawContact.trim();
    if (trimmed.startsWith('@')) {
      final username = trimmed.substring(1);
      return Uri.parse('https://instagram.com/$username');
    }
    if (trimmed.contains('@')) {
      return Uri.parse('mailto:$trimmed');
    }

    var digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    }
    return Uri.parse('https://wa.me/$digits');
  }

  static String formatTimestamp(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute WIB';
  }

  Future<void> _contactReporter(BuildContext context) async {
    final uri = buildContactUri(report.contact);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        showAppSnackBar(context, 'Tidak dapat membuka aplikasi kontak: ${report.contact}');
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, 'Kontak pelapor: ${report.contact}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoHeader(),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(report.type),
                  backgroundColor: report.type == 'LOST'
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(report.status),
                  backgroundColor: report.isActive
                      ? Colors.blue.shade100
                      : Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.category_outlined, 'Kategori', report.category),
            _buildInfoRow(Icons.location_on_outlined, 'Lokasi', report.location),
            _buildInfoRow(
              Icons.access_time,
              'Waktu Laporan',
              formatTimestamp(report.createdAt),
            ),
            const Divider(height: 28),
            const Text(
              'Deskripsi Barang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              report.description.isEmpty ? 'Tidak ada deskripsi tambahan.' : report.description,
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(height: 28),
            const Text(
              'Informasi Pelapor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_outline, 'Nama Pelapor', report.reporterName),
            _buildInfoRow(Icons.chat_outlined, 'Kontak', report.contact),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const Key('contact_reporter_button'),
              onPressed: () => _contactReporter(context),
              icon: const Icon(Icons.chat),
              label: const Text('Hubungi Pelapor'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoHeader() {
    if (!report.hasImage) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tidak ada foto dilampirkan'),
          ],
        ),
      );
    }

    final path = report.imagePath!;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: (kIsWeb || isNetwork)
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              )
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
