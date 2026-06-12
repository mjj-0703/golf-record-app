import 'dart:convert';

import 'package:golf_record_app/models/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordLoadResult {
  const RecordLoadResult({
    required this.records,
    this.corruptedFile = false,
    this.skippedCount = 0,
  });

  final List<Record> records;
  final bool corruptedFile;
  final int skippedCount;
}

class RecordStorage {
  static const _recordsKey = 'records_v1';

  Future<RecordLoadResult> loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recordsKey);
      if (raw == null || raw.isEmpty) {
        return const RecordLoadResult(records: []);
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const RecordLoadResult(records: [], corruptedFile: true);
      }

      final records = <Record>[];
      var skipped = 0;
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          skipped++;
          continue;
        }
        final record = Record.tryFromJson(item);
        if (record == null) {
          skipped++;
          continue;
        }
        records.add(record);
      }

      records.sort((a, b) => b.date.compareTo(a.date));
      return RecordLoadResult(
        records: records,
        corruptedFile: false,
        skippedCount: skipped,
      );
    } catch (_) {
      return const RecordLoadResult(records: [], corruptedFile: true);
    }
  }

  Future<bool> saveRecords(List<Record> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(records.map((record) => record.toJson()).toList());
      return prefs.setString(_recordsKey, encoded);
    } catch (_) {
      return false;
    }
  }
}
