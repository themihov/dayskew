import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayskew/src/models/placed_task.dart';
import 'package:dayskew/src/models/schedule_result.dart';
import 'package:dayskew/src/models/task.dart';
import 'package:dayskew/src/screens/home_screen.dart';
import 'package:dayskew/src/services/api_client.dart';
import 'package:dayskew/src/state/app_controller.dart';
import 'package:dayskew/src/theme/app_theme.dart';
import 'package:dayskew/src/widgets/conflict_drawer.dart';
import 'package:dayskew/src/widgets/date_strip.dart';
import 'package:dayskew/src/widgets/reflow_hero.dart';
import 'package:dayskew/src/widgets/timeline_task_card.dart';

Widget _host(Widget child) => CupertinoApp(
      theme: AppTheme.cupertino,
      home: CupertinoPageScaffold(
        child: Center(child: SingleChildScrollView(child: child)),
      ),
    );

class _FakeApi extends ApiClient {
  final List<Task> tasks;

  _FakeApi(this.tasks);

  @override
  Future<List<Task>> listTasks() async => tasks;

  @override
  Future<ScheduleResult> schedule(int currentTime, {String? date}) async {
    final timeline = tasks
        .map((t) => PlacedTask(
              task: t,
              computedStart: t.preferredStart,
              computedEnd: t.preferredStart + t.duration,
            ))
        .toList();
    return ScheduleResult(timeline: timeline, conflicts: const []);
  }
}

void main() {
  const task = Task(
    id: 't1',
    name: 'Deep work',
    duration: 90,
    preferredStart: 540,
    isStartSensitive: true,
    isEndSensitive: false,
    priority: 1,
  );

  testWidgets('reflow hero renders wake time and trigger', (tester) async {
    await tester.pumpWidget(_host(ReflowHero(
      wakeTime: 585,
      isReflowing: false,
      onJustWokeUp: () {},
      onTimeTap: () {},
    )));
    expect(find.text('9:45 AM'), findsOneWidget);
    expect(find.text('Just Woke Up'), findsOneWidget);
  });

  testWidgets('timeline card renders placed task details', (tester) async {
    await tester.pumpWidget(_host(TimelineTaskCard(
      placed: const PlacedTask(task: task, computedStart: 600, computedEnd: 690),
    )));
    expect(find.text('Deep work'), findsOneWidget);
    expect(find.text('10:00 AM'), findsOneWidget);
    expect(find.text('Starts 9:00 AM'), findsOneWidget);
  });

  testWidgets('conflict drawer lists unplaceable tasks', (tester) async {
    await tester.pumpWidget(_host(ConflictDrawer(
      conflicts: const [task],
      onDrop: (_) async {},
      onOverride: (_) {},
      onTomorrow: (_) {},
    )));
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Resolve'), findsOneWidget);
  });

  testWidgets('date strip highlights the selected day', (tester) async {
    final today = DateTime.now();
    await tester.pumpWidget(_host(DateStrip(
      selected: today,
      onSelected: (_) {},
    )));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('${today.day}'), findsWidgets);
  });

  testWidgets('home screen renders the full tree and opens the form',
      (tester) async {
    final controller = AppController(api: _FakeApi(const [task]));
    addTearDown(controller.dispose);

    await tester.pumpWidget(CupertinoApp(
      theme: AppTheme.cupertino,
      home: AnimatedBuilder(
        animation: controller,
        builder: (_, _) => HomeScreen(controller: controller),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Just Woke Up'), findsOneWidget);
    expect(find.text('Deep work'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Every Day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
