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
      appBar: AppBar(title: const Text('Pradita Find — API Integration')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari barang (e.g. KTM, Charger)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => ref.read(reportListProvider.notifier).loadReports(query: val),
            ),
          ),
          Expanded(child: _buildContent(context, ref, listState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportPage())),
        label: const Text('Buat Laporan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ReportListState state) {
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

    // 4. Tampilan SUCCESS
    return ListView.builder(
      itemCount: state.reports.length,
      itemBuilder: (context, index) {
        final item = state.reports[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(item.title, style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: item.status == 'RESOLVED' ? TextDecoration.lineThrough : null,
            )),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.category} • ${item.location}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(label: Text(item.type, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero,
                      backgroundColor: item.type == 'LOST' ? Colors.red.shade100 : Colors.green.shade100,
                    ),
                  ],
                )
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.status == 'ACTIVE')
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () => ref.read(reportListProvider.notifier).markAsResolved(item),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref.read(reportListProvider.notifier).deleteReport(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}