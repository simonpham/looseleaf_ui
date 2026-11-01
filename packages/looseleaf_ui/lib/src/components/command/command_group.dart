import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A run of [CommandItem]s under a typewriter [heading]; it hides when
/// none of its rows match the search.
///
/// Mirrors `CommandGroup` in upstream `src/components/ui/command.tsx`.
class CommandGroup extends StatefulWidget {
  const CommandGroup({super.key, required this.children, this.heading});

  /// The rows.
  final List<Widget> children;

  /// The kicker above them, usually a [Text].
  final Widget? heading;

  @override
  State<CommandGroup> createState() => _CommandGroupState();
}

class _CommandGroupState extends State<CommandGroup> {
  final Object _group = Object();

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    final shown = controller.groupVisible(_group);
    final theme = LooseleafTheme.of(context);
    final heading = widget.heading;
    return CommandGroupScope(
      group: _group,
      child: Offstage(
        offstage: !shown,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Padding(
            padding: const EdgeInsets.all(CommandMetrics.inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (heading != null)
                  Padding(
                    padding: CommandMetrics.heading,
                    child: DefaultTextStyle.merge(
                      style: CommandMetrics.headingStyle(theme),
                      child: Semantics(header: true, child: heading),
                    ),
                  ),
                ...widget.children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
