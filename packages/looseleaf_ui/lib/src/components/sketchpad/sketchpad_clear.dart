import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// Removes every stroke, as one step undo brings back.
///
/// [onPressed] runs first; the button's own action follows. When the
/// action leaves the button disabled while it had focus, focus moves to the
/// canvas instead of getting lost.
///
/// Mirrors `SketchpadClear` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadClear extends StatefulWidget {
  const SketchpadClear({super.key, this.child, this.onPressed, this.seed});

  /// The label; "Clear" when null.
  final Widget? child;

  /// Called before the action.
  final VoidCallback? onPressed;
  final String? seed;

  @override
  State<SketchpadClear> createState() => _SketchpadClearState();
}

class _SketchpadClearState extends State<SketchpadClear> {
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
    final enabled = scope.interactive && controller.strokes.isNotEmpty;
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      disabled: !enabled,
      focusNode: _focusNode,
      seed: widget.seed,
      onPressed: () {
        widget.onPressed?.call();
        final hadFocus = _focusNode.hasFocus;
        controller.clear();
        if (hadFocus && !(scope.interactive && controller.strokes.isNotEmpty)) {
          scope.canvasFocusNode.requestFocus();
        }
      },
      child: widget.child ?? const Text('Clear'),
    );
  }
}
