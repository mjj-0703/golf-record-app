import 'package:flutter/material.dart';
import 'package:golf_record_app/models/record.dart';
import 'package:golf_record_app/pages/record_form_page.dart';
import 'package:golf_record_app/pages/video_search_page.dart';
import 'package:golf_record_app/utils/date_formatter.dart';
import 'package:golf_record_app/utils/youtube_search_utils.dart';

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({
    required this.record,
    required this.onUpdate,
    required this.onDelete,
    super.key,
  });

  final Record record;
  final ValueChanged<Record> onUpdate;
  final ValueChanged<String> onDelete;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late Record _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  void _handleUpdate(Record updated) {
    setState(() {
      _record = updated;
    });
    widget.onUpdate(updated);
  }

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

    widget.onDelete(_record.id);
    Navigator.of(context).pop();
  }

  void _openYouTubeSearch(BuildContext context) {
    final query = buildYouTubeSearchQuery(
      missCause: _record.missCause,
      tags: _record.tags,
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
            tooltip: '編集',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecordFormPage(
                    initialRecord: _record,
                    onSave: _handleUpdate,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _DetailHeader(record: _record),
          const SizedBox(height: 16),
          _DetailSection(
            icon: Icons.thumb_up_outlined,
            label: '良かった感覚',
            value: _record.goodFeel,
          ),
          const SizedBox(height: 12),
          _DetailSection(
            icon: Icons.error_outline,
            label: 'ミスの原因',
            value: _record.missCause,
            footer: OutlinedButton.icon(
              onPressed: () => _openYouTubeSearch(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('YouTubeで直し方を探す'),
            ),
          ),
          const SizedBox(height: 12),
          _DetailSection(
            icon: Icons.lightbulb_outline,
            label: '次回試すこと',
            value: _record.nextTry,
            highlighted: true,
          ),
          if (_record.memo.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.notes,
              label: 'メモ',
              value: _record.memo,
              subdued: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.record});

  final Record record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPractice = record.type == SessionType.practice;
    final typeColor = isPractice ? Colors.teal : Colors.indigo;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatRecordDate(record.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPractice ? '練習' : 'ラウンド',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...record.tags.map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
                if (record.tags.isEmpty)
                  Text(
                    'クラブ未設定',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.label,
    required this.value,
    this.footer,
    this.highlighted = false,
    this.subdued = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? footer;
  final bool highlighted;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = subdued
        ? colorScheme.onSurfaceVariant
        : highlighted
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant;
    final backgroundColor = highlighted
        ? colorScheme.primaryContainer.withValues(alpha: 0.45)
        : colorScheme.surface;
    final borderColor =
        highlighted ? colorScheme.primary.withValues(alpha: 0.25) : colorScheme.outlineVariant;

    return Card(
      elevation: 0,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: labelColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: subdued ? colorScheme.onSurfaceVariant : null,
                  ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 14),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
