import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ConfettiTaskDoneExample extends StatefulWidget {
  const ConfettiTaskDoneExample({super.key});

  @override
  State<ConfettiTaskDoneExample> createState() =>
      _ConfettiTaskDoneExampleState();
}

class _ConfettiTaskDoneExampleState extends State<ConfettiTaskDoneExample> {
  static const _width = Spacing.d288;
  static const _tasks = ['Write the docs', 'Draw the icons', 'Tell someone'];

  final _done = [true, true, false];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final all = _done.every((done) => done);
    final count = _done.where((done) => done).length;
    return SizedBox(
      width: _width,
      child: Confetti(
        active: all,
        options: const ConfettiOptions(spread: 90, count: 60),
        child: Paper(
          stock: StockName.card,
          tilt: false,
          padding: const EdgeInsets.all(Spacing.d20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Launch day',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 24,
                ),
              ),
              const SizedBox(height: Spacing.d12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d12,
                children: [
                  for (final (index, task) in _tasks.indexed)
                    Checkbox(
                      value: _done[index],
                      onChanged: (value) =>
                          setState(() => _done[index] = value),
                      label: Text(task),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.d16),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Spacing.d24),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    switch (all) {
                      true => 'All done. Go outside.',
                      false => '$count of ${_tasks.length} done',
                    },
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 20,
                      color: theme.colors.inkYou,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
