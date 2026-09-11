import 'package:flutter/cupertino.dart';

import '../models/placed_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import 'badges.dart';

/// A placed task rendered as a floating, tier-tinted card: time column on the
/// left, a colored rail, then the task name, constraint badges, and drift.
class TimelineTaskCard extends StatelessWidget {
  final PlacedTask placed;
  final VoidCallback? onTap;

  const TimelineTaskCard({super.key, required this.placed, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = placed.task;
    final tierColor =
        (t.isLocked ? AppColors.locked : AppColors.forPriority(t.priority))
            .rc(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        decoration: BoxDecoration(
          color: AppColors.groupedSecondaryBackground.rc(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.separator.rc(context).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeFormat.hhmmAmPm(placed.computedStart),
                      style: AppTheme.metric,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TimeFormat.hhmmAmPm(placed.computedEnd),
                      style: AppTheme.metricSmall.copyWith(
                        color: AppColors.secondaryLabel.rc(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: tierColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name, style: AppTheme.headline),
                    if (t.isStartSensitive ||
                        t.isEndSensitive ||
                        t.isLocked) ...[
                      const SizedBox(height: 8),
                      SensitivityBadges(
                        isStartSensitive: t.isStartSensitive,
                        isEndSensitive: t.isEndSensitive,
                        isLocked: t.isLocked,
                        preferredStart: t.preferredStart,
                        duration: t.duration,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        MetaBadge(
                          text: 'P${t.priority} ${AppColors.priorityLabel(t.priority)}',
                          color: t.isLocked
                              ? AppColors.locked
                              : AppColors.forPriority(t.priority),
                        ),
                        MetaBadge(
                          text: TimeFormat.longDuration(t.duration),
                          color: AppColors.secondaryLabel,
                          icon: CupertinoIcons.time,
                        ),
                        DriftBadge(
                          computedStart: placed.computedStart,
                          preferredStart: t.preferredStart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  CupertinoIcons.chevron_forward,
                  size: 15,
                  color: AppColors.tertiaryLabel.rc(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
