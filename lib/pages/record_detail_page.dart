import 'package:flutter/material.dart';
import 'package:golf_record_app/models/record.dart';
import 'package:golf_record_app/pages/record_form_page.dart';
import 'package:golf_record_app/pages/video_search_page.dart';
import 'package:golf_record_app/utils/date_formatter.dart';
import 'package:golf_record_app/utils/youtube_search_utils.dart';

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({
    required this.record,
    required this.onUpdate,
    required this.onDelete,
    super.key,
  });

  final Record record;
  final ValueChanged<Record> onUpdate;
  final ValueChanged<String> onDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除'),
        content: const Text('この記録を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    onDelete(record.id);
    Navigator.of(context).pop();
  }

  void _openYouTubeSearch(BuildContext context) {
    final query = buildYouTubeSearchQuery(
      missCause: record.missCause,
      tags: record.tags,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoSearchPage(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecordFormPage(
                    initialRecord: record,
                    onSave: onUpdate,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailTile(
            label: '日付',
            value: formatRecordDate(record.date),
          ),
          _DetailTile(
            label: '種別',
            value: record.type == SessionType.practice ? '練習' : 'ラウンド',
          ),
          _DetailTile(label: '良かった感覚', value: record.goodFeel),
          _DetailTile(label: 'ミスの原因', value: record.missCause),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: () => _openYouTubeSearch(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('YouTubeで直し方を探す'),
            ),
          ),
          _DetailTile(label: '次回試すこと', value: record.nextTry),
          _DetailTile(
            label: 'タグ',
            value: record.tags.isEmpty ? 'なし' : record.tags.join(' / '),
          ),
          _DetailTile(
            label: 'メモ',
            value: record.memo.isEmpty ? '未入力' : record.memo,
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}
