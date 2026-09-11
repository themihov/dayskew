import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';

/// A small, Apple-style capsule badge. Tinted by default; pass
/// [emphasized] for a solid fill (used for the locked anchor token).
class MetaBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool emphasized;

  const MetaBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = color.rc(context);
    final background = emphasized ? resolved : resolved.withValues(alpha: 0.15);
    final foreground = emphasized ? CupertinoColors.white : resolved;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: AppTheme.caption2.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge trio decorating a task: locked / start / end sensitivity.
class SensitivityBadges extends StatelessWidget {
  final bool isStartSensitive;
  final bool isEndSensitive;
  final bool isLocked;
  final int preferredStart;
  final int duration;

  const SensitivityBadges({
    super.key,
    required this.isStartSensitive,
    required this.isEndSensitive,
    required this.isLocked,
    required this.preferredStart,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (isLocked)
          const MetaBadge(
            text: 'Locked',
            color: AppColors.locked,
            icon: CupertinoIcons.lock_fill,
            emphasized: true,
          ),
        if (isStartSensitive)
          MetaBadge(
            text: 'Starts ${TimeFormat.hhmmAmPm(preferredStart)}',
            color: AppColors.high,
            icon: CupertinoIcons.arrow_right,
          ),
        if (isEndSensitive)
          MetaBadge(
            text: 'Ends by ${TimeFormat.hhmmAmPm(preferredStart + duration)}',
            color: AppColors.medium,
            icon: CupertinoIcons.arrow_left,
          ),
      ],
    );
  }
}

/// Delta badge showing how far a task drifted from its preferred slot.
class DriftBadge extends StatelessWidget {
  final int computedStart;
  final int preferredStart;

  const DriftBadge({
    super.key,
    required this.computedStart,
    required this.preferredStart,
  });

  @override
  Widget build(BuildContext context) {
    final delta = computedStart - preferredStart;
    final onTime = delta == 0;
    final color = onTime
        ? AppColors.secondaryLabel
        : (delta > 0 ? AppColors.medium : AppColors.low);
    final icon = onTime
        ? CupertinoIcons.checkmark
        : (delta > 0 ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up);

    return MetaBadge(
      text: TimeFormat.drift(computedStart, preferredStart),
      color: color,
      icon: icon,
    );
  }
}
