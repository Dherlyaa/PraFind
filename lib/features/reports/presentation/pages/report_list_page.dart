import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_session.dart';
import '../../domain/report_model.dart';
import '../providers/report_list_provider.dart';
import 'create_report_page.dart';
import 'report_detail_page.dart';

class ReportListPage extends ConsumerStatefulWidget {
  const ReportListPage({super.key});

  @override
  ConsumerState<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends ConsumerState<ReportListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dialog konfirmasi hapus beserta opsi Urungkan (Undo) via SnackBar (Issue #10)
  Future<void> _confirmAndDelete(ReportModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus laporan ini?'),
        content: Text('Laporan "${item.title}" akan dihapus dari daftar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(reportListProvider.notifier).deleteReport(item.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Laporan "${item.title}" dihapus.'),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () {
              ref.read(reportListProvider.notifier).undoDeleteReport(item);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(reportListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pradita Find — API Integration')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              key: const Key('search_input'),
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari barang (e.g. KTM, Charger)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => ref.read(reportListProvider.notifier).onSearchChanged(val),
            ),
          ),
          Expanded(child: _buildContent(context, listState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateReportPage()),
        ),
        label: const Text('Buat Laporan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReportListState state) {
    // 1. Tampilan LOADING
    if (state.status == ListStatus.initialLoading) {
      return const Center(
        key: Key('loading_indicator'),
        child: CircularProgressIndicator(),
      );
    }

    // 2. Tampilan EMPTY
    if (state.status == ListStatus.empty) {
      return const Center(child: Text('Data dari server kosong.'));
    }

    // 3. Tampilan ERROR & RETRY
    if (state.status == ListStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data:\n${state.errorMessage}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              key: const Key('retry_button'),
              onPressed: () => ref.read(reportListProvider.notifier).retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi (Retry)'),
            )
          ],
        ),
      );
    }

    // 4. Tampilan SUCCESS dengan Pull-to-Refresh, Thumbnail Foto, & Navigasi Detail
    return RefreshIndicator(
      onRefresh: () => ref.read(reportListProvider.notifier).loadReports(),
      child: ListView.builder(
        itemCount: state.reports.length,
        itemBuilder: (context, index) {
          final item = state.reports[index];
          final canEdit = item.canModify(
            AuthSession.currentUserId,
            isAdmin: AuthSession.isAdmin,
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReportDetailPage(report: item)),
              ),
              leading: _buildItemThumbnail(item),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: item.isResolved ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.category} • ${item.location}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(item.type, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        backgroundColor: item.type == 'LOST'
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                      ),
                    ],
                  )
                ],
              ),
              trailing: canEdit
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isActive)
                          IconButton(
                            tooltip: 'Tandai selesai',
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            onPressed: () =>
                                ref.read(reportListProvider.notifier).markAsResolved(item),
                          ),
                        IconButton(
                          tooltip: 'Hapus laporan',
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmAndDelete(item),
                        ),
                      ],
                    )
                  : const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemThumbnail(ReportModel item) {
    if (!item.hasImage) {
      return CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
      );
    }

    final path = item.imagePath!;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: (kIsWeb || isNetwork)
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              )
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
      ),
    );
  }
}
