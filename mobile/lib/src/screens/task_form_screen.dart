import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import '../widgets/picker_sheets.dart';

/// Create/edit form for a single task. On save it pops back with a fully
/// populated [Task] (id kept for edits).
///
/// [preferDate] seeds a newly created task onto that calendar day (used when
/// the home screen is viewing a specific day); null keeps it recurring.
class TaskFormScreen extends StatefulWidget {
  final Task? initial;
  final DateTime? preferDate;

  const TaskFormScreen({super.key, this.initial, this.preferDate});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

/// Date assignment mode for a task.
enum _DateMode { recurring, today, specific }

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _duration;
  late int _preferredStart;
  late bool _isStartSensitive;
  late bool _isEndSensitive;
  late int _priority;
  late final bool _isEditing;

  late _DateMode _dateMode;
  late DateTime _specificDate;

  String? _nameError;
  String? _durationError;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _isEditing = t != null;
    _name = TextEditingController(text: t?.name ?? '');
    _duration = TextEditingController(
      text: t == null ? '60' : t.duration.toString(),
    );
    _preferredStart = t?.preferredStart ?? 9 * 60;
    _isStartSensitive = t?.isStartSensitive ?? false;
    _isEndSensitive = t?.isEndSensitive ?? false;
    _priority = t?.priority ?? 2;
    _duration.addListener(() => setState(() {}));

    if (t?.scheduledDate != null) {
      final parsed = TimeFormat.tryParseDate(t!.scheduledDate);
      _dateMode = parsed != null ? _DateMode.specific : _DateMode.recurring;
      _specificDate = parsed ?? DateTime.now();
    } else if (widget.preferDate != null) {
      _dateMode =
          TimeFormat.isoDate(widget.preferDate!) == TimeFormat.todayIso()
              ? _DateMode.today
              : _DateMode.specific;
      _specificDate = widget.preferDate!;
    } else {
      _dateMode = _DateMode.recurring;
      _specificDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    super.dispose();
  }

  int get _durationMinutes => int.tryParse(_duration.text) ?? 0;

  Future<void> _pickTime() async {
    final picked = await showTimePickerSheet(
      context,
      initialMinutes: _preferredStart,
      title: 'Preferred start',
    );
    if (picked != null) {
      setState(() => _preferredStart = picked);
    }
  }

  Future<void> _pickSpecificDate() async {
    final picked = await showDatePickerSheet(
      context,
      initial: _specificDate,
      title: 'Schedule on',
    );
    if (picked != null) {
      setState(
        () => _specificDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  /// The calendar day to persist, or null for a recurring (every-day) task.
  String? _resolveDate() {
    switch (_dateMode) {
      case _DateMode.recurring:
        return null;
      case _DateMode.today:
        return TimeFormat.todayIso();
      case _DateMode.specific:
        return TimeFormat.isoDate(_specificDate);
    }
  }

  void _save() {
    final name = _name.text.trim();
    final duration = _durationMinutes;
    final nameError = name.isEmpty ? 'Name is required' : null;
    final durationError = duration <= 0
        ? 'Enter a positive number'
        : (_preferredStart + duration > 1439 ? 'Ends after 11:59 PM' : null);

    if (nameError != null || durationError != null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _nameError = nameError;
        _durationError = durationError;
      });
      return;
    }

    final task = Task(
      id: widget.initial?.id ?? '',
      name: name,
      duration: duration,
      preferredStart: _preferredStart,
      isStartSensitive: _isStartSensitive,
      isEndSensitive: _isEndSensitive,
      priority: _priority,
      scheduledDate: _resolveDate(),
      timezone: widget.initial?.timezone ?? 'UTC',
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Task' : 'New Task'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
          onPressed: _save,
          child: Text(
            'Save',
            style: AppTheme.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.accent.rc(context),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            _section('Task', [
              CupertinoFormRow(
                error: _nameError == null ? null : Text(_nameError!),
                child: CupertinoTextField(
                  controller: _name,
                  placeholder: 'e.g. Morning run',
                  textAlign: TextAlign.left,
                  textInputAction: TextInputAction.next,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: null,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('Duration'),
                error: _durationError == null ? null : Text(_durationError!),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 64,
                      child: CupertinoTextField(
                        controller: _duration,
                        placeholder: '60',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: null,
                        onChanged: (_) {
                          if (_durationError != null) {
                            setState(() => _durationError = null);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'min',
                      style: AppTheme.body.copyWith(
                        color: AppColors.secondaryLabel.rc(context),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            _section('Schedule', [
              _TappableRow(
                label: 'Starts',
                value: TimeFormat.hhmmAmPm(_preferredStart),
                onTap: _pickTime,
              ),
              CupertinoFormRow(
                prefix: const Text('Priority'),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _priority,
                    children: const {
                      1: Text('High'),
                      2: Text('Medium'),
                      3: Text('Low'),
                    },
                    onValueChanged: (v) =>
                        setState(() => _priority = v ?? _priority),
                  ),
                ),
              ),
            ]),
            _section(
              'Repeats',
              [
                CupertinoFormRow(
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<_DateMode>(
                      groupValue: _dateMode,
                      children: const {
                        _DateMode.recurring: Text('Every Day'),
                        _DateMode.today: Text('Today'),
                        _DateMode.specific: Text('Pick a Day'),
                      },
                      onValueChanged: (v) =>
                          setState(() => _dateMode = v ?? _dateMode),
                    ),
                  ),
                ),
                if (_dateMode == _DateMode.specific)
                  _TappableRow(
                    label: 'Day',
                    value: TimeFormat.isoDate(_specificDate),
                    onTap: _pickSpecificDate,
                  ),
              ],
            ),
            _section(
              'Constraints',
              [
                CupertinoFormRow(
                  prefix: const Text('Start sensitive'),
                  child: CupertinoSwitch(
                    value: _isStartSensitive,
                    onChanged: (v) => setState(() => _isStartSensitive = v),
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('End sensitive'),
                  helper: Text(
                    'Must finish by '
                    '${TimeFormat.hhmmAmPm(_preferredStart + _durationMinutes)}',
                  ),
                  child: CupertinoSwitch(
                    value: _isEndSensitive,
                    onChanged: (v) => setState(() => _isEndSensitive = v),
                  ),
                ),
                if (_isStartSensitive && _isEndSensitive)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.lock_fill,
                          size: 14,
                          color: AppColors.locked.rc(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Both constraints on — this becomes a locked anchor '
                            'pinned exactly to its start time.',
                            style: AppTheme.footnote.copyWith(
                              color: AppColors.locked.rc(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: CupertinoButton.filled(
                onPressed: _save,
                borderRadius: BorderRadius.circular(14),
                child: Text(_isEditing ? 'Save Changes' : 'Create Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String header, List<Widget> children) {
    return CupertinoFormSection.insetGrouped(
      header: Text(header.toUpperCase()),
      children: children,
    );
  }
}

/// A form row that shows a value and opens a picker when tapped.
class _TappableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TappableRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoFormRow(
      prefix: Text(label),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTheme.body.copyWith(
                color: AppColors.accent.rc(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 14,
              color: AppColors.tertiaryLabel.rc(context),
            ),
          ],
        ),
      ),
    );
  }
}
