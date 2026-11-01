import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';

/// What a [Sketchpad] shares with its parts: the controller and the pad's
/// size, tools and flags. Parts rebuild when the controller changes.
///
/// Mirrors `SketchpadContext` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadScope extends InheritedNotifier<SketchpadController> {
  const SketchpadScope({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
    required this.tools,
    required this.readOnly,
    required this.disabled,
    required this.replay,
    required this.replaySpeed,
    required this.seed,
    required this.canvasFocusNode,
    required super.child,
  }) : super(notifier: controller);

  /// The drawing's own size; the canvas scales it to fit.
  final double width;
  final double height;

  /// The tools the toolbar offers and the letter keys pick from.
  final List<SketchTool> tools;

  final bool readOnly;
  final bool disabled;

  /// Draws the strokes on in order when shown.
  final bool replay;

  /// The replay's speed multiplier.
  final double replaySpeed;

  /// The pad's seed, for its parts' ink.
  final String seed;

  /// The canvas's node: focus returns there when a button it was on turns
  /// disabled.
  final FocusNode canvasFocusNode;

  /// The pad's state.
  final SketchpadController controller;

  /// Neither read-only nor disabled.
  bool get interactive => !readOnly && !disabled;

  /// The nearest pad. Throws outside a [Sketchpad], like upstream's
  /// `useSketchpad`.
  static SketchpadScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SketchpadScope>();
    if (scope == null) {
      throw FlutterError('Sketchpad parts must be used inside a Sketchpad.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(SketchpadScope oldWidget) =>
      super.updateShouldNotify(oldWidget) ||
      oldWidget.width != width ||
      oldWidget.height != height ||
      oldWidget.tools != tools ||
      oldWidget.readOnly != readOnly ||
      oldWidget.disabled != disabled ||
      oldWidget.replay != replay ||
      oldWidget.replaySpeed != replaySpeed ||
      oldWidget.seed != seed ||
      oldWidget.canvasFocusNode != canvasFocusNode;
}
