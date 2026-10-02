import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/reports/presentation/pages/report_list_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PraditaFindApp(),
    ),
  );
}

class PraditaFindApp extends StatelessWidget {
  const PraditaFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pradita Find',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReportListPage(),
    );
  }
}