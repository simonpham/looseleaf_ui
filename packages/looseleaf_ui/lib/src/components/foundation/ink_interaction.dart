import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/ink_activation.dart';
import 'package:looseleaf_ui/src/components/foundation/ink_hit_area.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Builds a component from its current [InkState]s.
typedef InkStatesBuilder = Widget Function(
  BuildContext context,
  Set<InkState> states,
);

/// Turns pointer, keyboard and focus input into the [InkState]s an
/// [InkSurface] shows, the way upstream's CSS selectors read the DOM:
///
/// * `hovered` while a mouse is over it (`:hover`),
/// * `pressed` while a pointer is down on it (`:active`),
/// * `focused` only for keyboard focus (`:focus-visible`: Flutter's
///   [FocusHighlightMode.traditional]),
/// * `disabled` when not [enabled], which also drops hover, press and
///   focus, and takes it out of the tab order,
/// * plus the component's own [states] (`checked`, `invalid`, `open`, …).
///
/// Tapping it or pressing an [activation] key while it has focus calls
/// [onActivate]. Semantics (role, label, checked) are left to the
/// component.
class InkInteraction extends StatefulWidget {
  const InkInteraction({
    super.key,
    required this.builder,
    this.onActivate,
    this.enabled = true,
    this.states = const {},
    this.activation = InkActivation.button,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor = SystemMouseCursors.click,
    this.disabledMouseCursor = SystemMouseCursors.basic,
    this.hitSlop = EdgeInsets.zero,
  });

  final InkStatesBuilder builder;

  /// Called on tap and on an [activation] key.
  final VoidCallback? onActivate;

  /// False is upstream's `disabled`: no input, the `disabled` state on.
  final bool enabled;

  /// States the component sets itself, merged with the interactive ones.
  final Set<InkState> states;

  /// Which keys activate it.
  final InkActivation activation;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The cursor while [enabled].
  final MouseCursor mouseCursor;

  /// The cursor while not [enabled] (`cursor-not-allowed` is
  /// [SystemMouseCursors.forbidden]).
  final MouseCursor disabledMouseCursor;

  /// Extra hit area around the child; see [InkHitArea].
  final EdgeInsets hitSlop;

  @override
  State<InkInteraction> createState() => _InkInteractionState();
}

class _InkInteractionState extends State<InkInteraction> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusVisible = false;

  late Map<Type, Action<Intent>> _actions = widget.activation.actions(
    _onTap,
  );

  @override
  void didUpdateWidget(InkInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activation != widget.activation) {
      _actions = widget.activation.actions(_onTap);
    }
    if (widget.enabled) return;
    _hovered = false;
    _pressed = false;
    _focusVisible = false;
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _onHover(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
  }

  void _onFocusHighlight(bool visible) {
    if (_focusVisible == visible) return;
    setState(() => _focusVisible = visible);
  }

  void _onTap() => widget.onActivate?.call();

  Set<InkState> get _states => {
    ...widget.states,
    if (!widget.enabled) InkState.disabled,
    if (widget.enabled && _hovered) InkState.hovered,
    if (widget.enabled && _pressed) InkState.pressed,
    if (widget.enabled && _focusVisible) InkState.focused,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    return InkHitArea(
      slop: widget.hitSlop,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        shortcuts: widget.activation.shortcuts,
        actions: _actions,
        onShowFocusHighlight: _onFocusHighlight,
        child: MouseRegion(
          cursor: switch (enabled) {
            true => widget.mouseCursor,
            false => widget.disabledMouseCursor,
          },
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: !enabled,
            onTapDown: switch (enabled) {
              true => (_) => _setPressed(true),
              false => null,
            },
            onTapUp: switch (enabled) {
              true => (_) => _setPressed(false),
              false => null,
            },
            onTapCancel: switch (enabled) {
              true => () => _setPressed(false),
              false => null,
            },
            onTap: switch (enabled) {
              true => _onTap,
              false => null,
            },
            child: widget.builder(context, _states),
          ),
        ),
      ),
    );
  }
}
