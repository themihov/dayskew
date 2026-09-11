import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import '../widgets/app_surface.dart';
import '../widgets/app_toast.dart';
import 'task_form_screen.dart';

/// Management list for the selected day: recurring and date-specific tasks,
/// with tap-to-edit and swipe-to-drop.
class TaskListScreen extends StatelessWidget {
  final AppController controller;

  const TaskListScreen({super.key, required this.controller});

  Future<void> _openForm(BuildContext context, {Task? initial}) async {
    final result = await Navigator.of(context).push<Task>(
      CupertinoPageRoute(
        builder: (_) => TaskFormScreen(
          initial: initial,
          preferDate: initial == null ? controller.selectedDate : null,
        ),
      ),
    );
    if (result == null || !context.mounted) return;
    try {
      if (initial == null) {
        await controller.addTask(result);
      } else {
        await controller.updateTask(result.copyWith(id: initial.id));
      }
      if (context.mounted) {
        showAppToast(context, initial == null ? 'Task created' : 'Task updated');
      }
    } catch (e) {
      if (context.mounted) showAppToast(context, 'Save failed: $e', isError: true);
    }
  }

  Future<bool> _confirmDrop(BuildContext context, Task task) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Drop "${task.name}"?'),
        content: const Text('This removes the task from your schedule.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Drop'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _drop(BuildContext context, Task task) async {
    try {
      await controller.deleteTask(task.id);
      if (context.mounted) {
        showAppToast(context, 'Dropped "${task.name}"');
      }
    } catch (e) {
      if (context.mounted) showAppToast(context, 'Delete failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayTasks = controller.tasksForSelectedDate;
    final dateLabel = TimeFormat.shortDate(controller.selectedDateIso);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tasks · $dateLabel'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
          onPressed: () => _openForm(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: dayTasks.isEmpty
            ? const _EmptyList()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                itemCount: dayTasks.length,
                itemBuilder: (context, i) {
                  final t = dayTasks[i];
                  return Dismissible(
                    key: ValueKey(t.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDrop(context, t),
                    onDismissed: (_) => _drop(context, t),
                    background: _DeleteBackground(),
                    child: _TaskTile(
                      task: t,
                      onTap: () => _openForm(context, initial: t),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.list_bullet,
            size: 48,
            color: AppColors.tertiaryLabel.rc(context),
          ),
          const SizedBox(height: 12),
          Text('No tasks yet', style: AppTheme.headline),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your day.',
            style: AppTheme.subheadline.copyWith(
              color: AppColors.secondaryLabel.rc(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(right: 20),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: AppColors.high.rc(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(CupertinoIcons.trash_fill, color: CupertinoColors.white),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tier = (task.isLocked
            ? AppColors.locked
            : AppColors.forPriority(task.priority))
        .rc(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 38,
            decoration: BoxDecoration(
              color: tier,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name, style: AppTheme.body.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(
                  '${AppColors.priorityLabel(task.priority)} priority'
                  '${task.isRecurring ? ' · Every day' : ''}',
                  style: AppTheme.footnote.copyWith(
                    color: AppColors.secondaryLabel.rc(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TimeFormat.hhmmAmPm(task.preferredStart),
                style: AppTheme.metricSmall,
              ),
              const SizedBox(height: 2),
              Text(
                TimeFormat.longDuration(task.duration),
                style: AppTheme.caption2.copyWith(
                  color: AppColors.tertiaryLabel.rc(context),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Icon(
            CupertinoIcons.chevron_forward,
            size: 15,
            color: AppColors.tertiaryLabel.rc(context),
          ),
        ],
      ),
    );
  }
}
