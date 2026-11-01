import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';

/// Tells a [SelectContent] where its list landed.
class SelectContentScope extends InheritedWidget {
  const SelectContentScope({
    super.key,
    required this.position,
    required super.child,
  });

  /// The list's position, null before the first layout.
  final OverlayPosition? position;

  @override
  bool updateShouldNotify(SelectContentScope oldWidget) =>
      oldWidget.position != position;
}

/// A [Select]'s list: a slip of paper (any stock, edge, tilt or tape) at
/// least as wide as the trigger (and 128 px), lifted with the `lift`
/// shadow. Its viewport scrolls, not the paper, with a chevron at each
/// end that scrolls it while the pointer rests on it.
///
/// [position] picks where it opens: [SelectPosition.itemAligned] lays the
/// chosen row over the trigger's value; [SelectPosition.popper] opens on
/// [side] of the trigger, lined up by [align], [sideOffset] away.
///
/// Mirrors `SelectContent` in upstream `src/components/ui/select.tsx`.
class SelectContent extends StatelessWidget {
  const SelectContent({
    super.key,
    required this.children,
    this.position = SelectPosition.itemAligned,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.center,
    this.sideOffset = SelectMetrics.popperOffset,
    this.maxHeight,
    this.stock = StockName.slip,
    this.edge,
    this.tilt = true,
    this.tape,
    this.seed,
    this.semanticLabel,
  });

  /// [SelectItem]s, [SelectGroup]s, [SelectLabel]s and
  /// [SelectSeparator]s.
  final List<Widget> children;

  /// Over the trigger or beside it.
  final SelectPosition position;

  /// The side of the trigger a popper list opens on.
  final OverlaySide side;

  /// How a popper list lines up with the trigger.
  final OverlayAlign align;

  /// The gap between a popper list and the trigger.
  final double sideOffset;

  /// The tallest the list grows before it scrolls (upstream `max-h-*`).
  final double? maxHeight;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the slip flat.
  final bool tilt;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// Pins the paper.
  final String? seed;

  /// Names the list for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final select = Select.of(context);
    final position = context
        .dependOnInheritedWidgetOfExactType<SelectContentScope>()
        ?.position;
    final measuring = select.measuring;
    if (measuring) {
      SchedulerBinding.instance.addPostFrameCallback((_) => select.measure());
    }
    final placed = select.placement;
    final viewport = _SelectViewport(
      controller: select,
      children: children,
    );
    return Opacity(
      opacity: switch (measuring) {
        true => 0,
        false => 1,
      },
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        scopesRoute: true,
        namesRoute: semanticLabel != null,
        label: semanticLabel,
        child: Focus(
          onKeyEvent: (_, event) => select.onListKey(event),
          child: PaperPopup(
            seed: select.seed,
            stock: stock,
            edge: edge,
            tilt: tilt,
            tape: tape,
            position: position,
            side: side,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: math.max(
                  select.triggerWidth(),
                  SelectMetrics.contentMinWidth,
                ),
                maxHeight: maxHeight ?? double.infinity,
              ),
              child: IntrinsicWidth(
                child: SizedBox(
                  height: switch (measuring) {
                    true => null,
                    false => placed?.height,
                  },
                  child: viewport,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectViewport extends StatefulWidget {
  const _SelectViewport({required this.controller, required this.children});

  final SelectController controller;
  final List<Widget> children;

  @override
  State<_SelectViewport> createState() => _SelectViewportState();
}

class _SelectViewportState extends State<_SelectViewport> {
  bool _up = false;
  bool _down = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    if (!mounted) return;
    final scroll = widget.controller.scroll;
    if (!scroll.hasClients) return;
    final position = scroll.position;
    if (!position.hasContentDimensions) return;
    final up = position.pixels > 0.5;
    final down = position.pixels < position.maxScrollExtent - 0.5;
    if (up == _up && down == _down) return;
    if (up && !_up) _keepInPlace(scroll);
    setState(() {
      _up = up;
      _down = down;
    });
  }

  void _keepInPlace(ScrollController scroll) {
    const shift = SelectMetrics.chevron + SelectMetrics.scrollButtonPadding * 2;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scroll.hasClients) return;
      final position = scroll.position;
      scroll.jumpTo(
        math.min(position.pixels + shift, position.maxScrollExtent),
      );
    });
  }

  bool _onMetrics(Notification notification) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _sync());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final padding = SelectMetrics.viewportPadding.of(context);
    final controller = widget.controller;
    final measuring = controller.measuring;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_up && !measuring) const SelectScrollUpButton(),
        Flexible(
          key: const ValueKey('viewport'),
          child: NotificationListener<Notification>(
            onNotification: (notification) => switch (notification) {
              ScrollNotification() ||
              ScrollMetricsNotification() => _onMetrics(notification),
              _ => false,
            },
            child: SingleChildScrollView(
              controller: controller.scroll,
              child: Padding(
                key: controller.listKey,
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
                ),
              ),
            ),
          ),
        ),
        if (_down && !measuring) const SelectScrollDownButton(),
      ],
    );
  }
}
