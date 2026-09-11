import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import '../widgets/app_surface.dart';
import '../widgets/app_toast.dart';
import '../widgets/conflict_drawer.dart';
import '../widgets/date_strip.dart';
import '../widgets/picker_sheets.dart';
import '../widgets/reflow_hero.dart';
import '../widgets/timeline_task_card.dart';
import 'task_form_screen.dart';

/// DaySkew home: the reflow hero, a day navigator, the computed timeline, and
/// the unresolved-conflict section.
class HomeScreen extends StatefulWidget {
  final AppController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _dismissedConflicts = {};
  bool _saving = false;

  AppController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.loadTasks().then((_) => c.reflow());
    });
  }

  String get _navTitle {
    final now = DateTime.now();
    final d = c.selectedDate;
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'Today';
    return '${TimeFormat.weekdayLong(c.selectedDateIso)}, ${TimeFormat.shortDate(c.selectedDateIso)}';
  }

  Future<void> _pickWakeTime() async {
    final picked = await showTimePickerSheet(
      context,
      initialMinutes: c.wakeTime,
      title: 'Actual wake-up',
    );
    if (picked == null) return;
    c.setWakeTime(picked);
    await c.reflow();
  }

  Future<void> _openForm({Task? initial}) async {
    final result = await Navigator.of(context).push<Task>(
      CupertinoPageRoute(
        builder: (_) => TaskFormScreen(
          initial: initial,
          preferDate: initial == null ? c.selectedDate : null,
        ),
      ),
    );
    if (result == null || !mounted) return;
    try {
      if (initial == null) {
        await c.addTask(result);
      } else {
        await c.updateTask(result.copyWith(id: initial.id));
      }
      if (mounted) {
        showAppToast(context, initial == null ? 'Task created' : 'Task updated');
      }
    } catch (e) {
      if (mounted) showAppToast(context, 'Save failed: $e', isError: true);
    }
  }

  Future<void> _seedSampleDay() async {
    try {
      await c.seedSampleDay();
      if (mounted) showAppToast(context, 'Sample day loaded');
    } catch (e) {
      if (mounted) showAppToast(context, 'Seeding failed: $e', isError: true);
    }
  }

  Future<void> _justWokeUp() async {
    await c.justWokeUp();
    if (mounted) {
      showAppToast(context, 'Wake time set to now — day reflowed.');
    }
  }

  Future<void> _saveDayToCalendar() async {
    if (_saving) return;
    if (c.timeline.isEmpty) {
      showAppToast(context, 'Reflow the day first — nothing to save.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await c.saveDayToGoogleCalendar();
      if (!mounted) return;
      final msg = result.failed == 0
          ? 'Saved ${result.created} event${result.created == 1 ? '' : 's'} to Google Calendar.'
          : 'Saved ${result.created}, ${result.failed} failed.';
      showAppToast(context, msg, isError: result.failed != 0);
    } catch (e) {
      if (mounted) showAppToast(context, 'Google Calendar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleConflicts =
        c.conflicts.where((t) => !_dismissedConflicts.contains(t.id)).toList();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(_navTitle),
            border: Border(
              bottom: BorderSide(color: AppColors.separator.rc(context)),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
              onPressed: () {
                HapticFeedback.lightImpact();
                _openForm();
              },
              child: const Icon(CupertinoIcons.add),
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () => c.refresh(),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
              sliver: SliverList.list(
                children: [
                  ReflowHero(
                    wakeTime: c.wakeTime,
                    isReflowing: c.reflowing,
                    onJustWokeUp: _justWokeUp,
                    onTimeTap: _pickWakeTime,
                  ),
                  const SizedBox(height: 16),
                  DateStrip(
                    selected: c.selectedDate,
                    onSelected: (d) => c.selectDate(d),
                  ),
                  const SizedBox(height: 16),
                  _SaveDayCard(
                    enabled: c.timeline.isNotEmpty,
                    busy: _saving,
                    onSave: _saveDayToCalendar,
                  ),
                  if (c.error != null) _ErrorCard(message: c.error!),
                  SectionHeader(
                    title: 'Timeline',
                    trailing:
                        '${TimeFormat.hhmm(c.wakeTime)} woke · ${TimeFormat.shortDate(c.selectedDateIso)}',
                  ),
                  ..._buildTimeline(context, visibleConflicts),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeline(BuildContext context, List<Task> visibleConflicts) {
    if (c.loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    }
    if (c.tasks.isEmpty) {
      return [
        _EmptyState(
          icon: CupertinoIcons.sun_max,
          title: 'No tasks yet',
          message:
              'Load a sample day to see the constraint reflow in action, or add your own tasks.',
          actionLabel: 'Load Sample Day',
          onAction: _seedSampleDay,
        ),
      ];
    }
    if (c.tasksForSelectedDate.isEmpty) {
      return [
        _EmptyState(
          icon: CupertinoIcons.calendar,
          title: 'Nothing planned for ${TimeFormat.shortDate(c.selectedDateIso)}',
          message:
              'Recurring tasks on other days don\'t apply here. Add a task for this day.',
          actionLabel: 'Add a Task',
          onAction: () => _openForm(),
        ),
      ];
    }
    if (c.timeline.isEmpty && visibleConflicts.isEmpty) {
      return [
        _EmptyState(
          icon: CupertinoIcons.hourglass,
          title: 'Nothing fits after ${TimeFormat.hhmmAmPm(c.wakeTime)}',
          message:
              'Every task bumped out of the day. Resolve them below or loosen their constraints.',
          actionLabel: 'Add a Task',
          onAction: () => _openForm(),
        ),
      ];
    }
    return [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Column(
          key: ValueKey('timeline-${c.scheduleVersion}'),
          children: [
            for (final placed in c.timeline)
              TimelineTaskCard(
                placed: placed,
                onTap: () => _openForm(initial: placed.task),
              ),
            if (visibleConflicts.isNotEmpty)
              ConflictDrawer(
                conflicts: visibleConflicts,
                onDrop: (t) async {
                  _dismissedConflicts.add(t.id);
                  setState(() {});
                  await c.dropConflict(t);
                },
                onOverride: (t) => _openForm(initial: t),
                onTomorrow: (t) {
                  setState(() => _dismissedConflicts.add(t.id));
                },
              ),
          ],
        ),
      ),
    ];
  }
}

class _SaveDayCard extends StatelessWidget {
  final bool enabled;
  final bool busy;
  final VoidCallback onSave;

  const _SaveDayCard({
    required this.enabled,
    required this.busy,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        (enabled ? AppColors.low : AppColors.tertiaryLabel).rc(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: enabled && !busy ? onSave : null,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save to Google Calendar',
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  busy
                      ? 'Saving…'
                      : enabled
                          ? 'Write this timeline into your DaySkew calendar'
                          : 'Reflow the day first — nothing to save',
                  style: AppTheme.footnote.copyWith(
                    color: AppColors.secondaryLabel.rc(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (busy)
            const CupertinoActivityIndicator()
          else
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: AppColors.tertiaryLabel.rc(context),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTheme.headline, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.subheadline.copyWith(
              color: AppColors.secondaryLabel.rc(context),
            ),
          ),
          const SizedBox(height: 18),
          CupertinoButton.filled(
            onPressed: onAction,
            borderRadius: BorderRadius.circular(14),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.high.rc(context);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.exclamationmark_circle_fill, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Couldn\'t reach the scheduler.\n$message',
              style: AppTheme.footnote.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
