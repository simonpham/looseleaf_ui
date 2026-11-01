import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// Steps forward again after [SketchpadUndo].
///
/// [onPressed] runs first; the button's own action follows. When the
/// action leaves the button disabled while it had focus, focus moves to the
/// canvas instead of getting lost.
///
/// Mirrors `SketchpadRedo` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadRedo extends StatefulWidget {
  const SketchpadRedo({super.key, this.child, this.onPressed, this.seed});

  /// The label; "Redo" when null.
  final Widget? child;

  /// Called before the action.
  final VoidCallback? onPressed;
  final String? seed;

  @override
  State<SketchpadRedo> createState() => _SketchpadRedoState();
}

class _SketchpadRedoState extends State<SketchpadRedo> {
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
    final enabled = scope.interactive && controller.canRedo;
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      disabled: !enabled,
      focusNode: _focusNode,
      seed: widget.seed,
      onPressed: () {
        widget.onPressed?.call();
        final hadFocus = _focusNode.hasFocus;
        controller.redo();
        if (hadFocus && !(scope.interactive && controller.canRedo)) {
          scope.canvasFocusNode.requestFocus();
        }
      },
      child: widget.child ?? const Text('Redo'),
    );
  }
}
