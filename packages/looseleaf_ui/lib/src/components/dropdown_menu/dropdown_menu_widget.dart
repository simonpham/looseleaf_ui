import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropdown_menu/dropdown_menu.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A menu written on a slip of paper that drops from a button: [content]
/// (a [DropdownMenuContent]) anchored to [child] (usually a
/// [DropdownMenuTrigger]), 6 px below it, centred.
///
/// Enter, Space and Down on the trigger open it with the first row
/// highlighted; a tap opens it with none. Up and Down move, Home and End
/// jump, typing finds a row, Right opens a sub-menu and Left closes it,
/// Enter or Space chooses, Escape closes and focus goes back to the
/// trigger. [modal] (the default) blocks the rest of the app while open.
///
/// ```dart
/// DropdownMenu(
///   content: DropdownMenuContent(
///     width: 224,
///     children: [
///       const DropdownMenuLabel(child: Text('My account')),
///       DropdownMenuItem(
///         trailing: const DropdownMenuShortcut('⇧⌘P'),
///         onSelect: openProfile,
///         child: const Text('Profile'),
///       ),
///       const DropdownMenuSeparator(),
///       DropdownMenuItem(
///         variant: InkMenuItemVariant.destructive,
///         onSelect: logOut,
///         child: const Text('Log out'),
///       ),
///     ],
///   ),
///   child: DropdownMenuTrigger.builder(
///     builder: (context, menu) => Button(
///       variant: ButtonVariant.outline,
///       onPressed: menu.toggle,
///       child: const Text('Open'),
///     ),
///   ),
/// )
/// ```
///
/// Mirrors `DropdownMenu` in upstream `src/components/ui/dropdown-menu.tsx`
/// (Radix `DropdownMenu.Root`).
class DropdownMenu extends StatefulWidget {
  const DropdownMenu({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = true,
  });

  /// The slip that drops down.
  final DropdownMenuContent content;

  /// The anchor; a [DropdownMenuTrigger] or anything reading
  /// [DropdownMenu.of].
  final Widget child;

  /// Whether it is open; the menu keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Blocks the app below while open.
  final bool modal;

  /// Upstream's `sideOffset`.
  static const double sideOffset = Spacing.d6;

  /// The nearest dropdown menu's controller.
  static DropdownMenuController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DropdownMenuScope>();
    if (scope == null) throw FlutterError('No DropdownMenu above this widget.');
    return scope.controller;
  }

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  late bool _open = widget.defaultOpen;
  bool _focusFirst = false;
  bool _pointer = false;
  final Object _group = Object();

  bool get _isOpen => widget.open ?? _open;

  void _setOpen(bool value, {bool focusFirst = false}) {
    final keyboard = focusFirst && !_pointer;
    _pointer = false;
    if (value == _isOpen) return;
    setState(() {
      _focusFirst = value && keyboard;
      if (widget.open == null) _open = value;
    });
    widget.onOpenChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = DropdownMenuController(
      open: _isOpen,
      setOpen: _setOpen,
      groupId: _group,
      pointerDown: () => _pointer = true,
    );
    return DropdownMenuScope(
      controller: controller,
      child: InkMenuPopup(
        open: _isOpen,
        onOpenChange: _setOpen,
        content: widget.content,
        groupId: _group,
        modal: widget.modal,
        focusFirst: _focusFirst,
        placement: const InkMenuPlacement(
          sideOffset: DropdownMenu.sideOffset,
        ),
        child: widget.child,
      ),
    );
  }
}
