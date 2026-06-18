import 'package:golf_record_app/models/record.dart';
import 'package:golf_record_app/utils/club_tag_utils.dart';

/// App Store スクリーンショット用のサンプル記録（debug 投入のみ）。
List<Record> screenshotSampleRecords({DateTime? now}) {
  final base = now ?? DateTime.now();
  final t1 = base.subtract(const Duration(days: 1));
  final t2 = base.subtract(const Duration(days: 3));
  final t3 = base.subtract(const Duration(days: 7));

  Record build({
    required String id,
    required DateTime date,
    required SessionType type,
    required String goodFeel,
    required String missCause,
    required String nextTry,
    required List<String> tags,
    String memo = '',
  }) {
    return Record(
      id: id,
      date: date,
      type: type,
      goodFeel: goodFeel,
      missCause: missCause,
      nextTry: nextTry,
      tags: tags,
      memo: memo,
      createdAt: date,
      updatedAt: date,
    );
  }

  return [
    build(
      id: 'sample-screenshot-1',
      date: t1,
      type: SessionType.practice,
      goodFeel: 'テイクバックがゆっくり',
      missCause: '体が早く開いてスライス',
      nextTry: 'フィニッシュまで左側を意識',
      tags: [formatIronTag(7)],
    ),
    build(
      id: 'sample-screenshot-2',
      date: t2,
      type: SessionType.round,
      goodFeel: 'インパクトで芯を捉えた',
      missCause: 'ティー位置が左すぎた',
      nextTry: 'ボールを左足側に置く',
      tags: [kDriverTag],
    ),
    build(
      id: 'sample-screenshot-3',
      date: t3,
      type: SessionType.practice,
      goodFeel: '距離感が合っていた',
      missCause: 'シャンク気味だった',
      nextTry: '体重を左に残す',
      tags: [formatApproachNamedTag('PW')],
    ),
  ];
}
