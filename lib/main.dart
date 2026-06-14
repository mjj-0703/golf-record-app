import 'package:flutter/material.dart';
import 'package:golf_record_app/pages/record_list_page.dart';

void main() {
  runApp(const GolfRecordApp());
}

class GolfRecordApp extends StatelessWidget {
  const GolfRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.green);

    return MaterialApp(
      title: 'FeelShot',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(overscroll: false),
      home: const RecordListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}