import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// Steps back one stroke, erase or clear.
///
/// [onPressed] runs first; the button's own action follows. When the
/// action leaves the button disabled while it had focus, focus moves to the
/// canvas instead of getting lost.
///
/// Mirrors `SketchpadUndo` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadUndo extends StatefulWidget {
  const SketchpadUndo({super.key, this.child, this.onPressed, this.seed});

  /// The label; "Undo" when null.
  final Widget? child;

  /// Called before the action.
  final VoidCallback? onPressed;
  final String? seed;

  @override
  State<SketchpadUndo> createState() => _SketchpadUndoState();
}

class _SketchpadUndoState extends State<SketchpadUndo> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = SketchpadScope.of(context);
    final controller = scope.controller;
    final enabled = scope.interactive && controller.canUndo;
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      disabled: !enabled,
      focusNode: _focusNode,
      seed: widget.seed,
      onPressed: () {
        widget.onPressed?.call();
        final hadFocus = _focusNode.hasFocus;
        controller.undo();
        if (hadFocus && !(scope.interactive && controller.canUndo)) {
          scope.canvasFocusNode.requestFocus();
        }
      },
      child: widget.child ?? const Text('Undo'),
    );
  }
}
