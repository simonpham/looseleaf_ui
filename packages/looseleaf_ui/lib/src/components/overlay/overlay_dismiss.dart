import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Why a popup was asked to close.
enum OverlayDismissReason {
  /// Escape was pressed while it was the topmost dismissible layer.
  escape,

  /// A pointer went down outside it (and outside its tap region group).
  outside,

  /// Focus moved somewhere outside it.
  focusOutside,
}

/// Makes [child] a dismissible layer, like Radix's `DismissableLayer`:
/// Escape closes the layer holding focus, or else the topmost open layer, and a pointer down outside
/// [child] (and outside every `TapRegion` of [groupId], such as the
/// trigger) closes it too. [onDismiss] decides; nothing closes by itself.
///
/// Layers stack in mount order, so a submenu's Escape closes the submenu
/// before its menu.
class OverlayDismiss extends StatefulWidget {
  const OverlayDismiss({
    super.key,
    required this.onDismiss,
    required this.child,
    this.groupId,
    this.escape = true,
    this.outside = true,
  });

  /// Called with the reason a dismissal was asked for.
  final ValueChanged<OverlayDismissReason> onDismiss;

  /// The popup.
  final Widget child;

  /// The `TapRegion` group the popup shares with its trigger.
  final Object? groupId;

  /// Whether Escape dismisses.
  final bool escape;

  /// Whether a pointer down outside dismisses.
  final bool outside;

  /// Whether any dismissible layer is open.
  static bool get anyOpen => _layers.isNotEmpty;

  static final List<_OverlayDismissState> _layers = [];

  static bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.escape) return false;
    for (final layer in _layers.reversed) {
      if (!layer.widget.escape) continue;
      layer.widget.onDismiss(OverlayDismissReason.escape);
      return true;
    }
    return false;
  }

  @override
  State<OverlayDismiss> createState() => _OverlayDismissState();
}

class _OverlayDismissState extends State<OverlayDismiss> {
  @override
  void initState() {
    super.initState();
    if (OverlayDismiss._layers.isEmpty) {
      HardwareKeyboard.instance.addHandler(OverlayDismiss._onKey);
    }
    OverlayDismiss._layers.add(this);
  }

  @override
  void dispose() {
    OverlayDismiss._layers.remove(this);
    if (OverlayDismiss._layers.isEmpty) {
      HardwareKeyboard.instance.removeHandler(OverlayDismiss._onKey);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Actions(
    actions: {
      DismissIntent: CallbackAction<DismissIntent>(
        onInvoke: (_) {
          if (!widget.escape) return null;
          widget.onDismiss(OverlayDismissReason.escape);
          return null;
        },
      ),
    },
    child: TapRegion(
      groupId: widget.groupId,
      onTapOutside: switch (widget.outside) {
        true => (_) => widget.onDismiss(OverlayDismissReason.outside),
        false => null,
      },
      child: widget.child,
    ),
  );
}
