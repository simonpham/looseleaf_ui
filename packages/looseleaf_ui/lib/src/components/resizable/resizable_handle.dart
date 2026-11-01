import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/resizable/resizable.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The seam between two [ResizablePanel]s, stitched by hand; [withHandle]
/// adds a paper tab with a grip. Drag it, or focus it and use the arrow
/// keys (5% a press; Home and End jump to the limits). Hover darkens the
/// stitches, dragging makes them one line, keyboard focus rings it.
///
/// Mirrors `ResizableHandle` in upstream `src/components/ui/resizable.tsx`.
class ResizableHandle extends StatefulWidget {
  const ResizableHandle({
    super.key,
    this.withHandle = false,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// Draws the paper tab with a grip.
  final bool withHandle;
  final bool disabled;

  /// Pins the hand: the same seed always draws the same stitches.
  final String? seed;

  final FocusNode? focusNode;

  /// What the seam resizes, such as "Resize the first panel".
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  /// How far an arrow key moves the seam, in percent.
  static const double keyStep = 5;

  @override
  State<ResizableHandle> createState() => _ResizableHandleState();
}

class _ResizableHandleState extends State<ResizableHandle> with InkSeed {
  bool _dragging = false;

  Map<ShortcutActivator, VoidCallback> _keys(ResizableScope scope) {
    void by(double step) => scope.moveTo(scope.size + step);
    return switch (scope.axis) {
      Axis.horizontal => {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            by(-ResizableHandle.keyStep),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            by(ResizableHandle.keyStep),
        const SingleActivator(LogicalKeyboardKey.home): () =>
            scope.moveTo(scope.min),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            scope.moveTo(scope.max),
      },
      Axis.vertical => {
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            by(-ResizableHandle.keyStep),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            by(ResizableHandle.keyStep),
        const SingleActivator(LogicalKeyboardKey.home): () =>
            scope.moveTo(scope.min),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            scope.moveTo(scope.max),
      },
    };
  }

  void _setDragging(bool dragging) {
    if (_dragging == dragging) return;
    setState(() => _dragging = dragging);
  }

  @override
  Widget build(BuildContext context) {
    final scope = ResizableScope.maybeOf(context);
    final axis = scope?.axis ?? Axis.horizontal;
    final disabled = widget.disabled || (scope?.disabled ?? false);
    final line = switch (axis) {
      Axis.horizontal => ResizableLine.vertical,
      Axis.vertical => ResizableLine.horizontal,
    };
    final params = ResizableParams(
      line: line,
      grip: widget.withHandle,
      disabled: disabled,
    );
    final source = RecipeInkSource(
      resizableRecipe,
      params,
      json: params.toJson(),
    );
    final size = scope?.size ?? 0;
    return Semantics(
      container: true,
      slider: true,
      enabled: !disabled,
      label: widget.semanticLabel,
      value: '${size.round()}',
      increasedValue: '${(size + ResizableHandle.keyStep).round()}',
      decreasedValue: '${(size - ResizableHandle.keyStep).round()}',
      onIncrease: switch ((scope, disabled)) {
        (final ResizableScope live?, false) => () => live.moveTo(
          live.size + ResizableHandle.keyStep,
        ),
        _ => null,
      },
      onDecrease: switch ((scope, disabled)) {
        (final ResizableScope live?, false) => () => live.moveTo(
          live.size - ResizableHandle.keyStep,
        ),
        _ => null,
      },
      child: CallbackShortcuts(
        bindings: switch ((scope, disabled)) {
          (final ResizableScope live?, false) => _keys(live),
          _ => const {},
        },
        child: InkInteraction(
          enabled: !disabled,
          focusNode: widget.focusNode,
          states: {...widget.forcedStates, if (_dragging) InkState.pressed},
          mouseCursor: switch (axis) {
            Axis.horizontal => SystemMouseCursors.resizeColumn,
            Axis.vertical => SystemMouseCursors.resizeRow,
          },
          builder: (context, states) => GestureDetector(
            excludeFromSemantics: true,
            dragStartBehavior: DragStartBehavior.down,
            onHorizontalDragStart: _drag(
              axis == Axis.horizontal,
              disabled,
              (_) => _setDragging(true),
            ),
            onHorizontalDragUpdate: _drag(
              axis == Axis.horizontal,
              disabled,
              (DragUpdateDetails details) => scope?.moveBy(details.delta.dx),
            ),
            onHorizontalDragEnd: _drag(
              axis == Axis.horizontal,
              disabled,
              (_) => _setDragging(false),
            ),
            onVerticalDragStart: _drag(
              axis == Axis.vertical,
              disabled,
              (_) => _setDragging(true),
            ),
            onVerticalDragUpdate: _drag(
              axis == Axis.vertical,
              disabled,
              (DragUpdateDetails details) => scope?.moveBy(details.delta.dy),
            ),
            onVerticalDragEnd: _drag(
              axis == Axis.vertical,
              disabled,
              (_) => _setDragging(false),
            ),
            child: InkSurface(
              source: source,
              seed: inkSeed(widget.seed),
              states: states,
              still: true,
              child: SizedBox(
                width: switch (axis) {
                  Axis.horizontal => ResizablePanelGroup.seam,
                  Axis.vertical => null,
                },
                height: switch (axis) {
                  Axis.horizontal => null,
                  Axis.vertical => ResizablePanelGroup.seam,
                },
                child: switch (widget.withHandle) {
                  true => OverflowBox(
                    minWidth: 0,
                    minHeight: 0,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: RotatedBox(
                      quarterTurns: switch (axis) {
                        Axis.horizontal => 0,
                        Axis.vertical => 1,
                      },
                      child: const InkIcon('grip-vertical', size: Spacing.d14),
                    ),
                  ),
                  false => null,
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// [handler] when dragging along [along] is allowed, else null.
  T? _drag<T>(bool along, bool disabled, T handler) =>
      switch (along && !disabled) {
        true => handler,
        false => null,
      };
}
