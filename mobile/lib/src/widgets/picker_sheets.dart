import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Presents an iOS-style time picker in a modal sheet. Returns the picked
/// "minutes since midnight", or null if cancelled.
Future<int?> showTimePickerSheet(
  BuildContext context, {
  required int initialMinutes,
  String title = 'Choose a time',
}) {
  return showCupertinoModalPopup<int>(
    context: context,
    builder: (context) => _TimeSheet(
      title: title,
      initialMinutes: initialMinutes,
    ),
  );
}

/// Presents an iOS-style date picker in a modal sheet. Returns the picked
/// calendar day, or null if cancelled.
Future<DateTime?> showDatePickerSheet(
  BuildContext context, {
  required DateTime initial,
  String title = 'Choose a day',
}) {
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => _DateSheet(
      title: title,
      initial: initial,
    ),
  );
}

class _SheetChrome extends StatelessWidget {
  final String title;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final Widget child;

  const _SheetChrome({
    required this.title,
    required this.onCancel,
    required this.onDone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: AppColors.background.rc(context),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground.rc(context),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.separator.rc(context).withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                Text(title, style: AppTheme.headline),
                CupertinoButton(onPressed: onDone, child: const Text('Done')),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TimeSheet extends StatefulWidget {
  final String title;
  final int initialMinutes;

  const _TimeSheet({required this.title, required this.initialMinutes});

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return _SheetChrome(
      title: widget.title,
      onCancel: () => Navigator.pop(context),
      onDone: () => Navigator.pop(context, _minutes),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: DateTime(2000, 1, 1, _minutes ~/ 60, _minutes % 60),
        use24hFormat: false,
        onDateTimeChanged: (d) => _minutes = d.hour * 60 + d.minute,
      ),
    );
  }
}

class _DateSheet extends StatefulWidget {
  final String title;
  final DateTime initial;

  const _DateSheet({required this.title, required this.initial});

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initial.year, widget.initial.month, widget.initial.day);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetChrome(
      title: widget.title,
      onCancel: () => Navigator.pop(context),
      onDone: () => Navigator.pop(context, _date),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _date,
        onDateTimeChanged: (d) => _date = DateTime(d.year, d.month, d.day),
      ),
    );
  }
}
