import 'package:flutter/material.dart';
import 'package:golf_record_app/pages/record_list_page.dart';

void main() {
  runApp(const GolfRecordApp());
}

class GolfRecordApp extends StatelessWidget {
  const GolfRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ゴルフ感覚メモ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const RecordListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}