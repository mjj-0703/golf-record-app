import 'package:flutter/material.dart';
import 'package:golf_record_app/constants/tag_options.dart';
import 'package:golf_record_app/models/record.dart';
import 'package:golf_record_app/pages/record_detail_page.dart';
import 'package:golf_record_app/pages/record_form_page.dart';
import 'package:golf_record_app/services/record_storage.dart';
import 'package:golf_record_app/utils/club_tag_utils.dart';
import 'package:golf_record_app/utils/date_formatter.dart';
import 'package:golf_record_app/widgets/feelshot_title.dart';
import 'package:golf_record_app/widgets/record_card.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  final _storage = RecordStorage();
  final List<Record> _records = [];
  bool _isLoading = true;
  SessionType? _typeFilter;
  String? _tagFilter;
  String? _tagSubFilter;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  List<Record> get _filteredRecords {
    return _records.where((record) {
      if (_typeFilter != null && record.type != _typeFilter) {
        return false;
      }
      if (!recordMatchesTagFilter(
        record.tags,
        _tagFilter,
        _tagSubFilter,
      )) {
        return false;
      }
      return true;
    }).toList();
  }

  /// 日付が最も新しく、nextTry が入っている記録（フィルタ前）
  Record? get _latestNextTryRecord {
    for (final record in _records) {
      if (record.nextTry.trim().isNotEmpty) {
        return record;
      }
    }
    return null;
  }

  Future<void> _loadRecords() async {
    final result = await _storage.loadRecords();
    if (!mounted) {
      return;
    }
    setState(() {
      _records
        ..clear()
        ..addAll(result.records);
      _isLoading = false;
    });

    if (result.corruptedFile) {
      _showSnackBar('保存データを読み込めませんでした。空の状態で開始します。');
    } else if (result.skippedCount > 0) {
      _showSnackBar('一部の記録を読み込めませんでした（${result.skippedCount}件）');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _persistRecords() async {
    final saved = await _storage.saveRecords(_records);
    if (!saved && mounted) {
      _showSnackBar('保存に失敗しました。空き容量などを確認してください。');
    }
  }

  void _saveRecord(Record newRecord) {
    setState(() {
      final index = _records.indexWhere((record) => record.id == newRecord.id);
      if (index == -1) {
        _records.insert(0, newRecord);
      } else {
        _records[index] = newRecord;
      }
      _records.sort((a, b) => b.date.compareTo(a.date));
    });
    _persistRecords();
  }

  void _deleteRecord(String id) {
    setState(() {
      _records.removeWhere((record) => record.id == id);
    });
    _persistRecords();
  }

  void _openCreatePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordFormPage(onSave: _saveRecord),
      ),
    );
  }

  void _openDetailPage(Record record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecordDetailPage(
          record: record,
          onUpdate: _saveRecord,
          onDelete: _deleteRecord,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_golf,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'まだ記録がありません',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '練習やラウンドで感じたことを\n右下の＋ボタンから記録しましょう',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      selected: selected,
      onSelected: onSelected,
    );
  }

  Widget _buildHorizontalChipRow(List<Widget> chips) {
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }

  List<Widget> _buildSubFilterChipWidgets() {
    if (_tagFilter == kWoodTag) {
      return kWoodNumbers.map((number) {
        final value = number.toString();
        final isSelected = _tagSubFilter == value;
        return _compactFilterChip(
          label: '${number}W',
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _tagSubFilter = selected ? value : null;
            });
          },
        );
      }).toList();
    }
    if (_tagFilter == kUtilityTag) {
      return kUtilityNumbers.map((number) {
        final value = number.toString();
        final isSelected = _tagSubFilter == value;
        return _compactFilterChip(
          label: '${number}UT',
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _tagSubFilter = selected ? value : null;
            });
          },
        );
      }).toList();
    }
    if (_tagFilter == kIronTag) {
      return kIronNumbers.map((number) {
        final value = number.toString();
        final isSelected = _tagSubFilter == value;
        return _compactFilterChip(
          label: '$number',
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _tagSubFilter = selected ? value : null;
            });
          },
        );
      }).toList();
    }
    if (_tagFilter == kApproachTag) {
      return kApproachSubFilterOptions.map((option) {
        final label =
            kApproachNamedTypes.contains(option) ? option : '$option°';
        final isSelected = _tagSubFilter == option;
        return _compactFilterChip(
          label: label,
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _tagSubFilter = selected ? option : null;
            });
          },
        );
      }).toList();
    }
    return [];
  }

  String _subFilterTitle() {
    if (_tagFilter == kApproachTag) {
      return 'ロフト';
    }
    return '番手';
  }

  Widget _buildFilterBar() {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final tagChips = kTagOptions.map((tag) {
      final isSelected = _tagFilter == tag;
      return _compactFilterChip(
        label: tagFilterChipLabel(tag),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _tagFilter = selected ? tag : null;
            if (!selected || !tagHasSubFilter(tag)) {
              _tagSubFilter = null;
            }
          });
        },
      );
    }).toList();
    final subFilterChips = _buildSubFilterChipWidgets();
    final showSubFilter =
        _tagFilter != null && tagHasSubFilter(_tagFilter!) && subFilterChips.isNotEmpty;

    return Material(
      color: surfaceColor,
      elevation: 1,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<SessionType?>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: null, label: Text('全部')),
                  ButtonSegment(
                    value: SessionType.practice,
                    label: Text('練習'),
                  ),
                  ButtonSegment(
                    value: SessionType.round,
                    label: Text('ラウンド'),
                  ),
                ],
                selected: {_typeFilter},
                onSelectionChanged: (selection) {
                  setState(() {
                    _typeFilter = selection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildHorizontalChipRow(tagChips),
            if (showSubFilter) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: Row(
                  children: [
                    Text(
                      _subFilterTitle(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHorizontalChipRow(subFilterChips)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextTryBanner(Record record) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPractice = record.type == SessionType.practice;

    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.45),
      child: InkWell(
        onTap: () => _openDetailPage(record),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '次回試すこと',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.nextTry,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '${formatRecordDate(record.date)} · ${isPractice ? '練習' : 'ラウンド'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: FeelShotTitle()),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (_latestNextTryRecord case final record?)
                      _buildNextTryBanner(record),
                    _buildFilterBar(),
                    Expanded(
                      child: _filteredRecords.isEmpty
                          ? const Center(
                              child: Text('該当する記録がありません'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 12, bottom: 80),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return RecordCard(
                                  record: record,
                                  onTap: () => _openDetailPage(record),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
