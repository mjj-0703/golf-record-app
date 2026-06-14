import 'package:flutter/material.dart';
import 'package:golf_record_app/constants/tag_options.dart';
import 'package:golf_record_app/models/record.dart';
import 'package:golf_record_app/pages/record_detail_page.dart';
import 'package:golf_record_app/pages/record_form_page.dart';
import 'package:golf_record_app/services/record_storage.dart';
import 'package:golf_record_app/utils/club_tag_utils.dart';
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

  Widget _buildSubFilterChips() {
    if (_tagFilter == kWoodTag) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: kWoodNumbers.map((number) {
          final value = number.toString();
          final isSelected = _tagSubFilter == value;
          return FilterChip(
            showCheckmark: false,
            label: Text('${number}W'),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _tagSubFilter = selected ? value : null;
              });
            },
          );
        }).toList(),
      );
    }
    if (_tagFilter == kUtilityTag) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: kUtilityNumbers.map((number) {
          final value = number.toString();
          final isSelected = _tagSubFilter == value;
          return FilterChip(
            showCheckmark: false,
            label: Text('${number}UT'),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _tagSubFilter = selected ? value : null;
              });
            },
          );
        }).toList(),
      );
    }
    if (_tagFilter == kIronTag) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: kIronNumbers.map((number) {
          final value = number.toString();
          final isSelected = _tagSubFilter == value;
          return FilterChip(
            showCheckmark: false,
            label: Text('$number'),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _tagSubFilter = selected ? value : null;
              });
            },
          );
        }).toList(),
      );
    }
    if (_tagFilter == kApproachTag) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: kApproachSubFilterOptions.map((option) {
          final label =
              kApproachNamedTypes.contains(option) ? option : '$option°';
          final isSelected = _tagSubFilter == option;
          return FilterChip(
            showCheckmark: false,
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _tagSubFilter = selected ? option : null;
              });
            },
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  String _subFilterTitle() {
    if (_tagFilter == kApproachTag) {
      return 'PW / SW / ロフト';
    }
    return '番手';
  }

  Widget _buildFilterBar() {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kTagOptions.map((tag) {
                final isSelected = _tagFilter == tag;
                return FilterChip(
                  showCheckmark: false,
                  label: Text(tag),
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
              }).toList(),
            ),
            if (_tagFilter != null && tagHasSubFilter(_tagFilter!)) ...[
              const SizedBox(height: 10),
              Text(
                _subFilterTitle(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              _buildSubFilterChips(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ゴルフ感覚メモ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
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
