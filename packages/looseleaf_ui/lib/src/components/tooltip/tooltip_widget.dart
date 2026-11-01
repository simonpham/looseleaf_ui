import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/tooltip/tooltip.dart';

/// A sticky note that names [child] (the trigger) while it is hovered or
/// focused from the keyboard: [content] (a [TooltipContent]) pops up beside
/// it after the [TooltipProvider]'s delay (none by default).
///
/// It stays while the pointer moves onto the note, closes when the pointer
/// leaves both, on blur, on Escape, or when the trigger is pressed. Open
/// state can be yours with [open] and [onOpenChange]. The trigger carries
/// the note's text as its tooltip for screen readers.
///
/// ```dart
/// Tooltip(
///   content: const TooltipContent(child: Text('Add to library')),
///   child: Button(onPressed: add, child: const InkIcon('plus')),
/// )
/// ```
///
/// Mirrors `Tooltip`, `TooltipTrigger` and `TooltipContent` in upstream
/// `src/components/ui/tooltip.tsx` (Radix `Tooltip`).
class Tooltip extends StatefulWidget {
  const Tooltip({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.delay,
    this.disabled = false,
  });

  /// The note.
  final TooltipContent content;

  /// The trigger.
  final Widget child;

  /// Whether it is open; the tooltip keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// The hover delay; the provider's (or none) when null.
  final Duration? delay;

  /// Never opens.
  final bool disabled;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  static const Duration _grace = Duration(milliseconds: 100);

  late bool _open = widget.defaultOpen;
  final Object _group = Object();
  Timer? _timer;
  bool _overTrigger = false;
  bool _overContent = false;
  bool _pressed = false;

  bool get _isOpen => !widget.disabled && (widget.open ?? _open);

  void _set(bool value) {
    _timer?.cancel();
    if (value == _isOpen) return;
    final provider = TooltipProvider.maybeOf(context);
    switch (value) {
      case true:
        provider?.opened();
      case false:
        provider?.closed();
    }
    if (widget.open == null) setState(() => _open = value);
    widget.onOpenChange?.call(value);
  }

  void _openSoon() {
    if (widget.disabled || _pressed) return;
    final delay =
        widget.delay ??
        TooltipProvider.maybeOf(context)?.openDelay ??
        Duration.zero;
    _timer?.cancel();
    if (delay == Duration.zero) {
      _set(true);
      return;
    }
    _timer = Timer(delay, () => _set(true));
  }

  void _closeSoon() {
    _timer?.cancel();
    _timer = Timer(_grace, () {
      if (_overTrigger || _overContent) return;
      _set(false);
    });
  }

  void _onEnter(PointerEnterEvent event) {
    _overTrigger = true;
    _openSoon();
  }

  void _onExit(PointerExitEvent event) {
    _overTrigger = false;
    _pressed = false;
    _closeSoon();
  }

  void _onFocus(bool focused) {
    if (!focused) {
      _set(false);
      return;
    }
    if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {
      return;
    }
    _openSoon();
  }

  void _onDown(PointerDownEvent event) {
    _pressed = true;
    _set(false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final trigger = Semantics(
      container: true,
      tooltip: content.description,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: _onFocus,
        child: MouseRegion(
          onEnter: _onEnter,
          onExit: _onExit,
          child: Listener(onPointerDown: _onDown, child: widget.child),
        ),
      ),
    );
    return InkPopup(
      open: _isOpen,
      onOpenChange: _set,
      side: content.side,
      align: content.align,
      sideOffset: content.sideOffset + content.pointerReach,
      alignOffset: content.alignOffset,
      collisionPadding: content.collisionPadding,
      avoidCollisions: content.avoidCollisions,
      motion: PopupMotionStyle.pop,
      autofocus: false,
      restoreFocus: false,
      groupId: _group,
      popupBuilder: (context, position) => ExcludeSemantics(
        child: MouseRegion(
          onEnter: (_) => _overContent = true,
          onExit: (_) {
            _overContent = false;
            _closeSoon();
          },
          child: TooltipContentScope(position: position, child: content),
        ),
      ),
      child: TapRegion(groupId: _group, child: trigger),
    );
  }
}
