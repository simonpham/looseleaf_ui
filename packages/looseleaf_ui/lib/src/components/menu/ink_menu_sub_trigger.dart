import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// The row that opens an [InkMenuSub], ending in a hand-drawn chevron. It
/// keeps the highlighter while its sub-menu is open.
///
/// Mirrors the `*MenuSubTrigger` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuSubTrigger extends StatefulWidget {
  const InkMenuSubTrigger({
    super.key,
    required this.child,
    this.leading,
    this.inset = false,
    this.disabled = false,
    this.textValue,
  });

  /// The row's text.
  final Widget child;

  /// An icon before the text.
  final Widget? leading;

  /// Lines the text up with ticked rows.
  final bool inset;

  /// Pencil-gray, skipped by the arrows, cannot open.
  final bool disabled;

  /// The text typeahead matches; [child]'s when it is a [Text].
  final String? textValue;

  /// How long the pointer rests on the row before the sub-menu opens.
  static const Duration openDelay = Duration(milliseconds: 100);

  @override
  State<InkMenuSubTrigger> createState() => _InkMenuSubTriggerState();
}

class _InkMenuSubTriggerState extends State<InkMenuSubTrigger> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  KeyEventResult _onKey(InkMenuSubState sub, KeyEvent event) {
    if (event is! KeyDownEvent || widget.disabled) {
      return KeyEventResult.ignored;
    }
    final forward = switch (Directionality.of(context)) {
      TextDirection.rtl => LogicalKeyboardKey.arrowLeft,
      TextDirection.ltr => LogicalKeyboardKey.arrowRight,
    };
    if (event.logicalKey != forward) return KeyEventResult.ignored;
    sub.show(focusFirst: true);
    return KeyEventResult.handled;
  }

  void _hover(InkMenuSubState sub) {
    if (sub.isOpen || _timer != null) return;
    _timer = Timer(InkMenuSubTrigger.openDelay, () {
      _timer = null;
      if (mounted) sub.show();
    });
  }

  void _leave() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final sub = InkMenuSubScope.of(context);
    final open = sub.isOpen;
    return InkMenuItemHost(
      disabled: widget.disabled,
      textValue: widget.textValue ?? InkMenuEntry.textOf(widget.child),
      focusNode: sub.triggerNode,
      sub: sub,
      closeOnActivate: false,
      expanded: open,
      onActivate: (viaKeys) => sub.show(focusFirst: viaKeys),
      onKey: (node, event) => _onKey(sub, event),
      onHover: () => _hover(sub),
      onExit: _leave,
      builder: (context, highlighted, focusVisible) => InkMenuRow(
        highlighted: highlighted || (open && !widget.disabled),
        focusVisible: focusVisible,
        disabled: widget.disabled,
        inset: widget.inset,
        leading: widget.leading,
        trailing: const InkIcon('chevron-right', size: 16),
        child: widget.child,
      ),
    );
  }
}
