import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';

/// The palette's rows, scrolling past 300 px with 4 px around them. A
/// [CommandEmpty] or [CommandLoading] among [children] is shown under the
/// scrolling rows, not inside them.
///
/// Mirrors `CommandList` in upstream `src/components/ui/command.tsx`.
class CommandList extends StatelessWidget {
  const CommandList({
    super.key,
    required this.children,
    this.maxHeight = CommandMetrics.listMaxHeight,
  });

  /// [CommandGroup]s, [CommandItem]s, [CommandSeparator]s, and the
  /// status rows.
  final List<Widget> children;

  /// The tallest the rows grow before they scroll.
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final child in children)
        if (child is! CommandEmpty && child is! CommandLoading) child,
    ];
    final status = [
      for (final child in children)
        if (child is CommandEmpty || child is CommandLoading) child,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CommandMetrics.inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        ),
        ...status,
      ],
    );
  }
}
