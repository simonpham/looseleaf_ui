import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StrikeTodoExample extends StatefulWidget {
  const StrikeTodoExample({super.key});

  @override
  State<StrikeTodoExample> createState() => _StrikeTodoExampleState();
}

class _StrikeTodoExampleState extends State<StrikeTodoExample> {
  static const _tasks = [
    'Buy oat milk',
    'Book the train',
    'Reply to Sam',
    'Water the ferns',
  ];
  static const _maxWidth = 320.0;

  final _done = <String>{'Buy oat milk'};

  void _toggle(String task, bool checked) => setState(() {
    if (checked) {
      _done.add(task);
      return;
    }
    _done.remove(task);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d12,
        children: [
          for (final task in _tasks)
            Row(
              spacing: Spacing.d10,
              children: [
                Checkbox(
                  value: _done.contains(task),
                  onChanged: (checked) => _toggle(task, checked),
                  semanticLabel: task,
                ),
                Label(
                  onPressed: () => _toggle(task, !_done.contains(task)),
                  child: Strike(
                    animate: true,
                    show: _done.contains(task),
                    child: Text(
                      task,
                      style: theme.typography.interface(
                        cssSize: 16,
                        color: switch (_done.contains(task)) {
                          true => theme.colors.inkMuted,
                          false => null,
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
