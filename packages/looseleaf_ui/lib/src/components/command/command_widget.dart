import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/drawer/drawer.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A command palette: a [CommandInput] that filters a [CommandList] of
/// [CommandItem]s as you type, on a flat slip of paper with a cut edge
/// and the `lift` shadow. Inside a popup (a popover, hover card, select or
/// menu, anything on [PaperPopup]) or a drawer, the popup is already the
/// paper, so the palette puts its own away; [sheet] false always drops it.
///
/// Focus stays in the search box: the arrows (and Ctrl + N / P / J / K),
/// Home and End move the highlighter, Enter chooses. Rows match when the
/// letters of the search appear in order in their value or keywords;
/// [shouldFilter] false leaves filtering to the app, [filter] scores rows
/// your own way.
///
/// ```dart
/// Command(
///   children: [
///     const CommandInput(placeholder: 'Type a command or search...'),
///     CommandList(
///       children: [
///         const CommandEmpty(child: Text('No results found.')),
///         CommandGroup(
///           heading: const Text('Suggestions'),
///           children: [
///             CommandItem(onSelect: print, child: const Text('Calendar')),
///           ],
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// Mirrors `Command` in upstream `src/components/ui/command.tsx` (cmdk).
class Command extends StatefulWidget {
  const Command({
    super.key,
    required this.children,
    this.sheet = true,
    this.stock = StockName.slip,
    this.edge = const EdgeSpec.all(EdgeKind.cut),
    this.tilt = false,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.shadow = PaperShadow.lift,
    this.seed,
    this.shouldFilter = true,
    this.filter,
    this.loop = false,
    this.vimBindings = true,
    this.onValueChange,
    this.semanticLabel,
  });

  /// Usually a [CommandInput] and a [CommandList].
  final List<Widget> children;

  /// Writes the palette on paper, unless it sits on a popup's or a
  /// drawer's paper already.
  final bool sheet;

  /// The paper stock.
  final StockName stock;

  /// The edges.
  final EdgeSpec? edge;

  /// Tilts the sheet.
  final bool tilt;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// The sheet's shadow.
  final PaperShadow shadow;

  /// Pins the paper.
  final String? seed;

  /// False shows every row; the app filters.
  final bool shouldFilter;

  /// Scores a row against the search; above zero shows it.
  final CommandFilter? filter;

  /// The arrows wrap at the ends.
  final bool loop;

  /// Ctrl + N / P / J / K move the highlighter too.
  final bool vimBindings;

  /// Hears the highlighted row's value change.
  final ValueChanged<String?>? onValueChange;

  /// Names the palette for screen readers (upstream `label`).
  final String? semanticLabel;

  @override
  State<Command> createState() => _CommandState();
}

class _CommandState extends State<Command> {
  late final CommandController _controller = CommandController(
    shouldFilter: widget.shouldFilter,
    filter: widget.filter,
    loop: widget.loop,
    vimBindings: widget.vimBindings,
    onValueChange: widget.onValueChange,
  );

  @override
  void didUpdateWidget(Command oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller
      ..shouldFilter = widget.shouldFilter
      ..filter = widget.filter
      ..loop = widget.loop
      ..vimBindings = widget.vimBindings
      ..onValueChange = widget.onValueChange;
  }

  static bool _nested(BuildContext context) =>
      PaperPopup.isAround(context) ||
      context.getInheritedWidgetOfExactType<DrawerScope>() != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final column = DefaultTextStyle.merge(
      style: TextStyle(color: theme.colors.ink),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
    );
    return CommandScope(
      controller: _controller,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.semanticLabel,
        child: switch (widget.sheet && !_nested(context)) {
          true => Paper(
            stock: widget.stock,
            edge: widget.edge,
            tilt: widget.tilt,
            rules: RuleName.none,
            tape: widget.tape,
            tapeKind: widget.tapeKind,
            shadow: widget.shadow,
            seed: widget.seed,
            child: column,
          ),
          false => column,
        },
      ),
    );
  }
}
