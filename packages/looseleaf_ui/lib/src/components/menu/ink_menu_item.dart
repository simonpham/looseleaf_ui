import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// The two looks of a menu row.
enum InkMenuItemVariant {
  /// Ink, with the highlighter.
  normal,

  /// Red, with a red pencil hatch when highlighted.
  destructive,
}

/// A menu row: [child] (its text), an optional [leading] icon and a
/// [trailing] part (usually an [InkMenuShortcut]). Choosing it (a tap,
/// Enter or Space) calls [onSelect] and closes the menu, unless
/// [closeOnSelect] is false (upstream's `event.preventDefault()`).
///
/// Mirrors the `*MenuItem` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuItem extends StatelessWidget {
  const InkMenuItem({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onSelect,
    this.closeOnSelect = true,
    this.variant = InkMenuItemVariant.normal,
    this.inset = false,
    this.disabled = false,
    this.textValue,
    this.focusNode,
  });

  /// The row's text.
  final Widget child;

  /// An icon before the text.
  final Widget? leading;

  /// What sits at the end, like a shortcut.
  final Widget? trailing;

  /// Runs when the row is chosen.
  final VoidCallback? onSelect;

  /// Whether choosing it closes the menu.
  final bool closeOnSelect;

  /// Normal or destructive.
  final InkMenuItemVariant variant;

  /// Lines the text up with ticked rows.
  final bool inset;

  /// Pencil-gray, skipped by the arrows, cannot be chosen.
  final bool disabled;

  /// The text typeahead matches; [child]'s when it is a [Text].
  final String? textValue;

  /// The row's focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => InkMenuItemHost(
    disabled: disabled,
    textValue: textValue ?? InkMenuEntry.textOf(child),
    focusNode: focusNode,
    closeOnActivate: closeOnSelect,
    onActivate: (_) => onSelect?.call(),
    builder: (context, highlighted, focusVisible) => InkMenuRow(
      highlighted: highlighted,
      focusVisible: focusVisible,
      disabled: disabled,
      destructive: variant == InkMenuItemVariant.destructive,
      inset: inset,
      leading: leading,
      trailing: trailing,
      child: child,
    ),
  );
}
