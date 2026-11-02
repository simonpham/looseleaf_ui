import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// Builds a row from whether it is highlighted and shows the focus bar.
typedef InkMenuRowBuilder =
    Widget Function(
      BuildContext context,
      bool highlighted,
      bool focusVisible,
    );

/// The behaviour every menu row shares, like Radix's `MenuItemImpl`: it
/// joins its slip's [InkMenuLevel] (for the arrows and typeahead), is
/// highlighted while it has focus, takes focus when the pointer moves over
/// it (and gives it back to the slip when the pointer leaves), and is
/// chosen by a tap, Enter or Space: [onActivate] runs, then the whole menu
/// closes unless [closeOnActivate] is false.
///
/// Disabled rows cannot be highlighted or chosen and the arrows skip them.
class InkMenuItemHost extends StatefulWidget {
  const InkMenuItemHost({
    super.key,
    required this.builder,
    this.onActivate,
    this.closeOnActivate = true,
    this.disabled = false,
    this.textValue,
    this.focusNode,
    this.sub,
    this.onKey,
    this.onHover,
    this.onExit,
    this.role = SemanticsRole.menuItem,
    this.checked,
    this.mixed,
    this.expanded,
  });

  /// Builds the row.
  final InkMenuRowBuilder builder;

  /// Runs when the row is chosen; `viaKeys` says the keyboard chose it.
  final ValueChanged<bool>? onActivate;

  /// Whether choosing the row closes the menu.
  final bool closeOnActivate;

  /// Whether the row is disabled.
  final bool disabled;

  /// The text typeahead matches.
  final String? textValue;

  /// The row's focus node; its own when null.
  final FocusNode? focusNode;

  /// The sub-menu the row opens.
  final InkMenuSubState? sub;

  /// Keys the row handles before the slip.
  final FocusOnKeyEventCallback? onKey;

  /// Called while the pointer moves over the enabled row.
  final VoidCallback? onHover;

  /// Called when the pointer leaves the row.
  final VoidCallback? onExit;

  /// The row's role for screen readers.
  final SemanticsRole role;

  /// The checked state, for tick and radio rows.
  final bool? checked;

  /// Whether a tick row is half checked.
  final bool? mixed;

  /// Whether the row's sub-menu is open.
  final bool? expanded;

  @override
  State<InkMenuItemHost> createState() => _InkMenuItemHostState();
}

class _InkMenuItemHostState extends State<InkMenuItemHost> {
  FocusNode? _ownNode;
  late final InkMenuEntry _entry = InkMenuEntry(_node);
  InkMenuLevel? _level;

  FocusNode get _node =>
      widget.focusNode ?? (_ownNode ??= FocusNode(debugLabel: 'InkMenuItem'));

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final level = InkMenuLevelScope.maybeOf(context);
    if (identical(level, _level)) return;
    _level?.unregister(_entry);
    _level = level;
    level?.register(_entry);
  }

  void _onFocus() {
    if (_node.hasFocus) _level?.focused(_entry);
    setState(() {});
  }

  @override
  void dispose() {
    _level?.unregister(_entry);
    _node.removeListener(_onFocus);
    _ownNode?.dispose();
    super.dispose();
  }

  void _activate({required bool viaKeys}) {
    if (widget.disabled) return;
    widget.onActivate?.call(viaKeys);
    if (!widget.closeOnActivate) return;
    InkMenuRootScope.maybeOf(context)?.close();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final own = widget.onKey?.call(node, event) ?? KeyEventResult.ignored;
    if (own != KeyEventResult.ignored) return own;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final activates =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space;
    if (!activates) return KeyEventResult.ignored;
    _activate(viaKeys: true);
    return KeyEventResult.handled;
  }

  void _onHover(PointerHoverEvent event) {
    final level = _level;
    if (widget.disabled) {
      if (level != null && level.rowFocused) level.focusSelf();
      return;
    }
    if (!_node.hasFocus) {
      level?.viaKeys = false;
      _node.requestFocus();
    }
    widget.onHover?.call();
  }

  void _onExit(PointerExitEvent event) {
    widget.onExit?.call();
    if (!_node.hasFocus) return;
    if (widget.sub?.isOpen ?? false) return;
    _level?.focusSelf();
  }

  @override
  Widget build(BuildContext context) {
    _entry
      ..enabled = !widget.disabled
      ..text = widget.textValue
      ..sub = widget.sub;
    final highlighted = _node.hasFocus && !widget.disabled;
    final focusVisible = highlighted && (_level?.viaKeys ?? false);
    return Semantics(
      container: true,
      role: widget.role,
      enabled: !widget.disabled,
      checked: widget.checked,
      mixed: widget.mixed,
      expanded: widget.expanded,
      focusable: !widget.disabled,
      focused: highlighted,
      onTap: switch (widget.disabled) {
        true => null,
        false => () => _activate(viaKeys: false),
      },
      child: Focus(
        focusNode: _node,
        includeSemantics: false,
        canRequestFocus: !widget.disabled,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: MouseRegion(
          onHover: _onHover,
          onExit: _onExit,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: switch (widget.disabled) {
              true => null,
              false => () => _activate(viaKeys: false),
            },
            child: widget.builder(context, highlighted, focusVisible),
          ),
        ),
      ),
    );
  }
}
