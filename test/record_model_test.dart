import 'package:flutter_test/flutter_test.dart';
import 'package:golf_record_app/models/record.dart';

void main() {
  group('Record.tryFromJson', () {
    test('正常な JSON から Record を生成する', () {
      final record = Record.tryFromJson({
        'id': '1',
        'date': '2026-01-01T00:00:00.000',
        'type': 'practice',
        'goodFeel': 'テンポ',
        'missCause': 'スライス',
        'nextTry': 'グリップ見直し',
        'tags': ['7番アイアン'],
        'memo': '',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      });

      expect(record, isNotNull);
      expect(record!.type, SessionType.practice);
      expect(record.tags, ['7番アイアン']);
    });

    test('不正な type は練習として読み込む', () {
      final record = Record.tryFromJson({
        'id': '2',
        'date': '2026-01-01T00:00:00.000',
        'type': 'invalid',
        'goodFeel': 'a',
        'missCause': 'b',
        'nextTry': 'c',
        'tags': [],
        'memo': '',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      });

      expect(record?.type, SessionType.practice);
    });

    test('id が無い場合は null', () {
      expect(
        Record.tryFromJson({
          'date': '2026-01-01T00:00:00.000',
          'type': 'practice',
          'goodFeel': 'a',
          'missCause': 'b',
          'nextTry': 'c',
        }),
        isNull,
      );
    });

    test('不正な日付はフォールバックする', () {
      final record = Record.tryFromJson({
        'id': '3',
        'date': 'not-a-date',
        'type': 'round',
        'goodFeel': 'a',
        'missCause': 'b',
        'nextTry': 'c',
        'tags': [],
        'memo': '',
        'createdAt': 'bad',
        'updatedAt': 'bad',
      });

      expect(record, isNotNull);
      expect(record!.type, SessionType.round);
    });
  });
}
