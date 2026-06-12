import 'package:flutter/material.dart';
import 'package:golf_record_app/constants/validation.dart';
import 'package:golf_record_app/models/record.dart';
import 'package:golf_record_app/utils/club_tag_utils.dart';

class RecordFormPage extends StatefulWidget {
  const RecordFormPage({
    required this.onSave,
    this.initialRecord,
    super.key,
  });

  final Record? initialRecord;
  final ValueChanged<Record> onSave;

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _goodFeelController = TextEditingController();
  final _missCauseController = TextEditingController();
  final _nextTryController = TextEditingController();
  final _memoController = TextEditingController();

  late DateTime _selectedDate;
  SessionType _selectedType = SessionType.practice;
  String? _primaryClub;
  int? _woodNumber;
  int? _ironNumber;
  String? _approachSelection;
  bool _mentalSelected = false;
  bool _showPrimaryClubError = false;
  bool _showWoodNumberError = false;
  bool _showIronNumberError = false;
  bool _showApproachSelectionError = false;

  bool get _isEdit => widget.initialRecord != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRecord;
    if (initial != null) {
      _selectedDate = initial.date;
      _selectedType = initial.type;
      _goodFeelController.text = initial.goodFeel;
      _missCauseController.text = initial.missCause;
      _nextTryController.text = initial.nextTry;
      _memoController.text = initial.memo;
      final parsed = parseTagsForForm(initial.tags);
      _primaryClub = parsed.primaryClub;
      _woodNumber = parsed.woodNumber;
      _ironNumber = parsed.ironNumber;
      _approachSelection = parsed.approachSelection;
      _mentalSelected = parsed.mentalSelected;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _goodFeelController.dispose();
    _missCauseController.dispose();
    _nextTryController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectPrimaryClub(String club) {
    _primaryClub = club;
    _showPrimaryClubError = false;
    _woodNumber = null;
    _ironNumber = null;
    _approachSelection = null;
    _showWoodNumberError = false;
    _showIronNumberError = false;
    _showApproachSelectionError = false;
  }

  void _submit() {
    var hasError = false;
    if (_primaryClub == null) {
      _showPrimaryClubError = true;
      hasError = true;
    }
    if (_primaryClub == kWoodTag && _woodNumber == null) {
      _showWoodNumberError = true;
      hasError = true;
    }
    if (_primaryClub == kIronTag && _ironNumber == null) {
      _showIronNumberError = true;
      hasError = true;
    }
    if (_primaryClub == kApproachTag && _approachSelection == null) {
      _showApproachSelectionError = true;
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final initial = widget.initialRecord;

    final record = Record(
      id: initial?.id ?? now.microsecondsSinceEpoch.toString(),
      date: _selectedDate,
      type: _selectedType,
      goodFeel: _goodFeelController.text.trim(),
      missCause: _missCauseController.text.trim(),
      nextTry: _nextTryController.text.trim(),
      tags: buildTagsForSave(
        primaryClub: _primaryClub,
        woodNumber: _woodNumber,
        ironNumber: _ironNumber,
        approachSelection: _approachSelection,
        mentalSelected: _mentalSelected,
      ),
      memo: _memoController.text.trim(),
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    widget.onSave(record);
    Navigator.of(context).pop();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '入力してください';
    }
    if (value.length > kMaxRequiredFieldLength) {
      return '$kMaxRequiredFieldLength文字以内で入力してください';
    }
    return null;
  }

  String? _memoValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > kMaxMemoLength) {
      return '$kMaxMemoLength文字以内で入力してください';
    }
    return null;
  }

  Widget _buildSubSelector({
    required String title,
    required List<Widget> chips,
    required bool showError,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClubSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クラブ（1つ選択）',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kPrimaryClubOptions.map((club) {
            final isSelected = _primaryClub == club;
            return ChoiceChip(
              showCheckmark: false,
              label: Text(club),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectPrimaryClub(club);
                  } else if (_primaryClub == club) {
                    _primaryClub = null;
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_showPrimaryClubError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'クラブを選択してください',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (_primaryClub == kWoodTag)
          _buildSubSelector(
            title: '番手',
            showError: _showWoodNumberError,
            errorText: '番手を選択してください',
            chips: kWoodNumbers.map((number) {
              final isSelected = _woodNumber == number;
              return ChoiceChip(
                showCheckmark: false,
                label: Text('${number}W'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _woodNumber = selected ? number : null;
                    _showWoodNumberError = false;
                  });
                },
              );
            }).toList(),
          ),
        if (_primaryClub == kIronTag)
          _buildSubSelector(
            title: '番手',
            showError: _showIronNumberError,
            errorText: '番手を選択してください',
            chips: kIronNumbers.map((number) {
              final isSelected = _ironNumber == number;
              return ChoiceChip(
                showCheckmark: false,
                label: Text('$number'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _ironNumber = selected ? number : null;
                    _showIronNumberError = false;
                  });
                },
              );
            }).toList(),
          ),
        if (_primaryClub == kApproachTag) ...[
          _buildSubSelector(
            title: 'ウェッジ',
            showError: false,
            errorText: '',
            chips: kApproachNamedTypes.map((type) {
              final isSelected = _approachSelection == type;
              return ChoiceChip(
                showCheckmark: false,
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _approachSelection = selected ? type : null;
                    _showApproachSelectionError = false;
                  });
                },
              );
            }).toList(),
          ),
          _buildSubSelector(
            title: 'ロフト角',
            showError: _showApproachSelectionError,
            errorText: 'PW / SW またはロフト角を選択してください',
            chips: kApproachLofts.map((loft) {
              final value = loft.toString();
              final isSelected = _approachSelection == value;
              return ChoiceChip(
                showCheckmark: false,
                label: Text('$loft°'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _approachSelection = selected ? value : null;
                    _showApproachSelectionError = false;
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          '追加（任意）',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        FilterChip(
          showCheckmark: false,
          label: Text(kMentalTag),
          selected: _mentalSelected,
          onSelected: (selected) {
            setState(() {
              _mentalSelected = selected;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '記録を編集' : '記録を作成')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('日付'),
              subtitle: Text(
                '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
              ),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('変更'),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SessionType>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: SessionType.practice,
                  label: Text('練習'),
                ),
                ButtonSegment(
                  value: SessionType.round,
                  label: Text('ラウンド'),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildClubSection(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goodFeelController,
              decoration: const InputDecoration(
                labelText: '良かった感覚',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: kMaxRequiredFieldLength,
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _missCauseController,
              decoration: const InputDecoration(
                labelText: 'ミスの原因',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: kMaxRequiredFieldLength,
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nextTryController,
              decoration: const InputDecoration(
                labelText: '次回試すこと',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: kMaxRequiredFieldLength,
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: kMaxMemoLength,
              maxLines: 4,
              validator: _memoValidator,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
