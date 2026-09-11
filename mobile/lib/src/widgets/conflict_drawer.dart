import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import 'app_button.dart';
import 'app_surface.dart';

/// Pass 2 conflict surfacing. Unplaceable tasks appear in a distinct
/// "Needs attention" section; resolving one opens a familiar action sheet so
/// the destructive choice is deliberate and easy to cancel.
class ConflictDrawer extends StatelessWidget {
  final List<Task> conflicts;
  final Future<void> Function(Task task) onDrop;
  final void Function(Task task) onOverride;
  final void Function(Task task) onTomorrow;

  const ConflictDrawer({
    super.key,
    required this.conflicts,
    required this.onDrop,
    required this.onOverride,
    required this.onTomorrow,
  });

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        await showCupertinoDialog<void>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Action failed'),
            content: Text('$e'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _showActions(BuildContext context, Task task) async {
    HapticFeedback.selectionClick();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(task.name),
        message: const Text('This task did not fit the day. What would you like to do?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              HapticFeedback.mediumImpact();
              _run(context, () async => onTomorrow(task));
            },
            child: const Text('Move to Tomorrow'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              onOverride(task);
            },
            child: const Text('Change Time'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(sheetContext);
              HapticFeedback.mediumImpact();
              _run(context, () async => onDrop(task));
            },
            child: const Text('Drop Task'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Needs attention',
          trailing: '${conflicts.length} unplaced',
        ),
        for (final task in conflicts)
          _ConflictCard(task: task, onResolve: () => _showActions(context, task)),
      ],
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final Task task;
  final VoidCallback onResolve;

  const _ConflictCard({required this.task, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.conflict.rc(context).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 19,
              color: AppColors.conflict.rc(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name, style: AppTheme.headline),
                const SizedBox(height: 4),
                Text(
                  'Wanted ${TimeFormat.hhmmAmPm(task.preferredStart)} · '
                  '${TimeFormat.longDuration(task.duration)} · '
                  '${AppColors.priorityLabel(task.priority)} priority',
                  style: AppTheme.footnote.copyWith(
                    color: AppColors.secondaryLabel.rc(context),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    label: 'Resolve',
                    variant: AppButtonVariant.tinted,
                    tint: AppColors.conflict,
                    icon: CupertinoIcons.ellipsis_circle,
                    small: true,
                    onPressed: onResolve,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
