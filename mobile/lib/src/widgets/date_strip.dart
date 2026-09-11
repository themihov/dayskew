import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import 'picker_sheets.dart';

/// Horizontal day navigator: today plus the next two weeks, with a
/// jump-to-date action. Tapping a day loads that day's schedule.
class DateStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  const DateStrip({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    return SizedBox(
      height: 78,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        children: [
          for (var i = 0; i < 14; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DayCell(
                day: todayDay.add(Duration(days: i)),
                isToday: i == 0,
                selected: TimeFormat.isoDate(selected) ==
                    TimeFormat.isoDate(todayDay.add(Duration(days: i))),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(todayDay.add(Duration(days: i)));
                },
              ),
            ),
          _JumpCell(onSelected: onSelected),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.accent.rc(context)
        : AppColors.fill.rc(context).withValues(alpha: 0.6);
    final primary = selected
        ? CupertinoColors.white
        : AppColors.label.rc(context);
    final secondary = selected
        ? CupertinoColors.white.withValues(alpha: 0.8)
        : AppColors.secondaryLabel.rc(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 58,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? 'Today' : TimeFormat.weekdayAbbrev(TimeFormat.isoDate(day)),
              style: AppTheme.caption2.copyWith(
                fontWeight: FontWeight.w600,
                color: secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: AppTheme.title2.copyWith(color: primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpCell extends StatelessWidget {
  final ValueChanged<DateTime> onSelected;

  const _JumpCell({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final now = DateTime.now();
        final picked = await showDatePickerSheet(
          context,
          initial: now,
          title: 'Jump to a day',
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        width: 58,
        decoration: BoxDecoration(
          color: AppColors.fill.rc(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          CupertinoIcons.calendar,
          size: 22,
          color: AppColors.secondaryLabel.rc(context),
        ),
      ),
    );
  }
}

