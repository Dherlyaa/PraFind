import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_list_provider.dart';
import 'create_report_page.dart';

class ReportListPage extends ConsumerWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(reportListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pradita Find — Daftar Barang'),
        actions: [
          // Simulated test toggles untuk dosen/tester
          PopupMenuButton<String>(
            onSelected: (value) {
              final notifier = ref.read(reportListProvider.notifier);
              if (value == 'empty') notifier.loadReports(forceEmpty: true);
              if (value == 'error') notifier.loadReports(forceError: true);
              if (value == 'normal') notifier.loadReports();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'normal', child: Text('Simulasi Success')),
              const PopupMenuItem(value: 'empty', child: Text('Simulasi Empty State')),
              const PopupMenuItem(value: 'error', child: Text('Simulasi Error State')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              key: const Key('search_input'),
              decoration: const InputDecoration(
                hintText: 'Cari barang (e.g. KTM, Charger)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                ref.read(reportListProvider.notifier).loadReports(query: val);
              },
            ),
          ),
          Expanded(child: _buildContent(context, ref, listState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_report_fab'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateReportPage()),
          );
        },
        label: const Text('Buat Laporan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ReportListState state) {
    // KONDISI 1: Initial Loading State
    if (state.status == ListStatus.initialLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(key: Key('loading_indicator')),
            SizedBox(height: 8),
            Text('Memuat data barang...'),
          ],
        ),
      );
    }

    // KONDISI 3: Empty State
    if (state.status == ListStatus.empty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tidak ada laporan barang ditemukan.'),
          ],
        ),
      );
    }

    // KONDISI 4: Error State dengan Tombol Retry
    if (state.status == ListStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 8),
            Text(state.errorMessage),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              key: const Key('retry_button'),
              onPressed: () {
                ref.read(reportListProvider.notifier).loadReports();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // KONDISI 2: Data Berhasil Dimuat (Success State)
    return ListView.builder(
      itemCount: state.reports.length,
      itemBuilder: (context, index) {
        final item = state.reports[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.category} • ${item.location}'),
            trailing: Chip(
              label: Text(item.type),
              backgroundColor: item.type == 'LOST' ? Colors.red.shade100 : Colors.green.shade100,
            ),
          ),
        );
      },
    );
  }
}