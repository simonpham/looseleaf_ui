import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/hover_card/hover_card.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// A polaroid that lands beside [child] (the trigger, usually a link) when
/// the pointer rests on it for [openDelay], or when it takes keyboard
/// focus: [content] (a [HoverCardContent]). It stays while the pointer is
/// on the trigger or the card and closes [closeDelay] after it leaves both,
/// on blur, on Escape or on a tap elsewhere.
///
/// The card is a bonus for the pointer: the trigger must work without it.
/// Touch never opens it. Open state can be yours with [open] and
/// [onOpenChange].
///
/// ```dart
/// HoverCard(
///   content: const HoverCardContent(
///     child: Column(children: [
///       HoverCardMedia(child: Doodle('flower', size: 88)),
///       HoverCardCaption(Text('@looseleaf')),
///     ]),
///   ),
///   child: Button(variant: ButtonVariant.link, onPressed: visit,
///       child: const Text('@looseleaf')),
/// )
/// ```
///
/// Mirrors `HoverCard`, `HoverCardTrigger` and `HoverCardContent` in
/// upstream `src/components/ui/hover-card.tsx` (Radix `HoverCard`).
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.openDelay = defaultOpenDelay,
    this.closeDelay = defaultCloseDelay,
  });

  /// Radix's `openDelay`: a card on every pass of the pointer is noise.
  static const Duration defaultOpenDelay = Duration(milliseconds: 700);

  /// Radix's `closeDelay`.
  static const Duration defaultCloseDelay = Duration(milliseconds: 300);

  /// The card.
  final HoverCardContent content;

  /// The trigger.
  final Widget child;

  /// Whether it is open; the card keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// How long the pointer rests on the trigger before it opens.
  final Duration openDelay;

  /// How long after the pointer leaves before it closes.
  final Duration closeDelay;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  late bool _open = widget.defaultOpen;
  final Object _group = Object();
  Timer? _timer;
  bool _overTrigger = false;
  bool _overContent = false;

  bool get _isOpen => widget.open ?? _open;

  void _set(bool value) {
    _timer?.cancel();
    if (value == _isOpen) return;
    if (widget.open == null) setState(() => _open = value);
    widget.onOpenChange?.call(value);
  }

  void _after(Duration delay, VoidCallback action) {
    _timer?.cancel();
    if (delay == Duration.zero) {
      action();
      return;
    }
    _timer = Timer(delay, action);
  }

  void _openSoon() => _after(widget.openDelay, () => _set(true));

  void _closeSoon() => _after(widget.closeDelay, () {
    if (_overTrigger || _overContent) return;
    _set(false);
  });

  void _onEnter(PointerEnterEvent event) {
    if (event.kind == PointerDeviceKind.touch) return;
    _overTrigger = true;
    _openSoon();
  }

  void _onExit(PointerExitEvent event) {
    _overTrigger = false;
    _closeSoon();
  }

  void _onFocus(bool focused) {
    if (!focused) {
      _closeSoon();
      return;
    }
    if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {
      return;
    }
    _openSoon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final trigger = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _onFocus,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: widget.child,
      ),
    );
    return InkPopup(
      open: _isOpen,
      onOpenChange: _set,
      side: content.side,
      align: content.align,
      sideOffset: content.sideOffset,
      alignOffset: content.alignOffset,
      collisionPadding: content.collisionPadding,
      avoidCollisions: content.avoidCollisions,
      autofocus: false,
      restoreFocus: false,
      groupId: _group,
      popupBuilder: (context, position) => MouseRegion(
        onEnter: (_) {
          _overContent = true;
          _timer?.cancel();
        },
        onExit: (_) {
          _overContent = false;
          _closeSoon();
        },
        child: HoverCardContentScope(position: position, child: content),
      ),
      child: TapRegion(groupId: _group, child: trigger),
    );
  }
}
