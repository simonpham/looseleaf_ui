import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A command palette in a [Dialog]: a napkin with the search box and the
/// list on it, 12 px padding (10 compact, 8 calm), no close mark. The
/// [title] and [description] are for screen readers only. Focus goes into
/// the search box on open and back where it was on close; Escape and a
/// tap outside close it.
///
/// [child] is the anchor (a trigger), or nothing when a shortcut opens it
/// through [open].
///
/// Mirrors `CommandDialog` in upstream `src/components/ui/command.tsx`.
class CommandDialog extends StatelessWidget {
  const CommandDialog({
    super.key,
    required this.children,
    this.child = const SizedBox.shrink(),
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.title = 'Command Palette',
    this.description = 'Search for a command to run...',
    this.showCloseButton = false,
    this.stock = StockName.napkin,
    this.edge,
    this.tape,
    this.tilt = true,
    this.seed,
    this.shouldFilter = true,
    this.filter,
    this.loop = false,
  });

  /// Usually a [CommandInput] and a [CommandList].
  final List<Widget> children;

  /// The anchor.
  final Widget child;

  /// Whether it is open; the dialog keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// The dialog's name for screen readers.
  final String title;

  /// The dialog's description for screen readers.
  final String description;

  /// Shows the dialog's close mark.
  final bool showCloseButton;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// False lays the napkin flat.
  final bool tilt;

  /// Pins the paper.
  final String? seed;

  /// See [Command.shouldFilter].
  final bool shouldFilter;

  /// See [Command.filter].
  final CommandFilter? filter;

  /// See [Command.loop].
  final bool loop;

  static const ByDensity<double> _padding = ByDensity(
    comfortable: Spacing.d12,
    compact: Spacing.d10,
    calm: Spacing.d8,
  );

  @override
  Widget build(BuildContext context) => Dialog(
    open: open,
    defaultOpen: defaultOpen,
    onOpenChange: onOpenChange,
    placement: PopupPlacement.top,
    content: Builder(
      builder: (context) => DialogContent(
        showCloseButton: showCloseButton,
        stock: stock,
        edge: edge,
        tape: tape,
        tilt: tilt,
        seed: seed,
        padding: EdgeInsets.all(_padding.of(context)),
        gap: 0,
        semanticLabel: title,
        children: [
          Semantics(
            hint: description,
            child: Command(
              sheet: false,
              shouldFilter: shouldFilter,
              filter: filter,
              loop: loop,
              children: children,
            ),
          ),
        ],
      ),
    ),
    child: child,
  );
}
