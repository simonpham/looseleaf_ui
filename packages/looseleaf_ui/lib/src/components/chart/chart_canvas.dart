import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Describes the data point at a target for the tooltip and the live
/// region; null when there is nothing there.
typedef ChartDescribe = ChartDescribed? Function(
  int index,
  int? series,
  ChartLayoutBase layout,
);

/// Builds a layer over the drawing (a donut's center label) from the
/// layout and the active point.
typedef ChartOverlayBuilder = Widget Function(
  BuildContext context,
  ChartLayoutBase layout,
  ChartActive? active,
);

/// The drawing every chart shares: the recipe sized to the box, its labels
/// and cursors, the tooltip, the pointer and the keys, the reveal, the
/// spoken summary, the live region and the data table.
///
/// One tab stop: left and right (or the layout's own keys) walk the
/// targets, up and down pick a series, Home and End jump, Escape closes the
/// tooltip, Enter and Space select.
///
/// Mirrors `ChartCanvas` in upstream `src/components/ui/chart.tsx`.
class ChartCanvas<S extends ChartSpec> extends StatefulWidget {
  const ChartCanvas({
    super.key,
    required this.recipe,
    required this.spec,
    required this.specJson,
    required this.state,
    required this.label,
    required this.summary,
    required this.describe,
    this.table,
    this.seriesCount = 0,
    this.interactive = true,
    this.animate = true,
    this.seed,
    this.onActiveChange,
    this.onSelect,
    this.overlay,
    this.meter,
  });

  /// The chart recipe.
  final Recipe<S> recipe;

  /// The chart.
  final S spec;

  /// [spec]'s upstream object, for the frame cache.
  final Map<String, Object?> specJson;

  /// Ready, empty or loading.
  final ChartState state;

  /// The accessible name.
  final String label;

  /// The spoken summary.
  final String summary;

  /// Describes a target.
  final ChartDescribe describe;

  /// The data table for screen readers.
  final TableModel? table;

  /// Series the up and down keys step through; 0 for none.
  final int seriesCount;

  /// Whether the pointer and keys move a cursor.
  final bool interactive;

  /// Wipes the drawing on once.
  final bool animate;

  /// Pins the hand.
  final String? seed;

  /// The active point changed.
  final ValueChanged<ChartPoint?>? onActiveChange;

  /// A point was tapped or picked with Enter or Space.
  final ValueChanged<ChartPoint>? onSelect;

  /// A layer over the drawing.
  final ChartOverlayBuilder? overlay;

  /// A gauge's reading.
  final ChartMeter? meter;

  @override
  State<ChartCanvas<S>> createState() => _ChartCanvasState<S>();
}

class _ChartCanvasState<S extends ChartSpec> extends State<ChartCanvas<S>>
    with InkSeed, SingleTickerProviderStateMixin {
  final FocusNode _focus = FocusNode(debugLabel: 'chart');
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: _draw,
    value: 1,
  );
  bool _revealed = false;
  bool _pointerFocus = false;
  ChartLayoutBase? _layout;
  (String, Size, bool)? _layoutKey;
  ChartScope? _scope;

  static const Duration _draw = Duration(milliseconds: 600);

  bool get _canMove => widget.interactive && widget.state == ChartState.ready;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = ChartScope.of(context);
    if (_revealed) return;
    _revealed = true;
    if (!widget.animate || InkMotion.reducedIn(context)) return;
    _reveal.value = 0;
    _reveal.duration = InkMotion.of(context, _draw);
    _reveal.forward();
  }

  @override
  void dispose() {
    _focus.dispose();
    _reveal.dispose();
    super.dispose();
  }

  ChartLayoutBase _layoutFor(Size size, bool calm) {
    final key = (stableStringify(widget.specJson), size, calm);
    if (_layout case final cached? when _layoutKey == key) return cached;
    final layout = widget.spec.layout(Box(size.width, size.height), calm);
    _layout = layout;
    _layoutKey = key;
    return layout;
  }

  ChartActive? _active(ChartScope scope, ChartLayoutBase layout) {
    final n = layout.targets.n;
    if (n <= 0) return null;
    if (scope.controller.active case final active?) {
      if (active.index < n) return active;
      return ChartActive(
        index: n - 1,
        series: active.series,
        source: active.source,
      );
    }
    if (scope.tooltip?.defaultIndex case final index? when index < n) {
      return ChartActive(index: index, source: ChartActiveSource.pointer);
    }
    return null;
  }

  void _activate(int index, int? series, ChartActiveSource source) {
    final layout = _layout;
    final scope = _scope;
    if (layout == null || scope == null) return;
    if (index < 0 || index >= layout.targets.n) return;
    final described = widget.describe(index, series, layout);
    if (described == null) return;
    scope.controller.activate(
      ChartActive(index: index, series: series, source: source),
      announce: switch (source) {
        ChartActiveSource.keyboard => described.announce,
        ChartActiveSource.pointer => null,
      },
    );
    widget.onActiveChange?.call((index: index, series: series));
  }

  void _clear([ChartActiveSource? only]) {
    final scope = _scope;
    final current = scope?.controller.active;
    if (scope == null || current == null) return;
    if (only != null && current.source != only) return;
    scope.controller.activate(null);
    final fallback = scope.tooltip?.defaultIndex;
    widget.onActiveChange?.call(switch (fallback) {
      null => null,
      final index => (index: index, series: null),
    });
  }

  void _track(Offset local) {
    final layout = _layout;
    if (layout == null) return;
    final index = hitIndex(layout.targets, local.dx, local.dy);
    if (index == null) {
      _clear(ChartActiveSource.pointer);
      return;
    }
    final current = _scope?.controller.active;
    if (current != null &&
        current.index == index &&
        current.source == ChartActiveSource.pointer) {
      return;
    }
    _activate(index, null, ChartActiveSource.pointer);
  }

  void _select(Offset local) {
    final layout = _layout;
    final onSelect = widget.onSelect;
    if (layout == null || onSelect == null) return;
    final index = hitIndex(layout.targets, local.dx, local.dy);
    if (index == null) return;
    onSelect((index: index, series: _scope?.controller.active?.series));
  }

  static String? _keyName(LogicalKeyboardKey key) => switch (key) {
    LogicalKeyboardKey.arrowLeft => 'ArrowLeft',
    LogicalKeyboardKey.arrowRight => 'ArrowRight',
    LogicalKeyboardKey.arrowUp => 'ArrowUp',
    LogicalKeyboardKey.arrowDown => 'ArrowDown',
    LogicalKeyboardKey.home => 'Home',
    LogicalKeyboardKey.end => 'End',
    LogicalKeyboardKey.pageUp => 'PageUp',
    LogicalKeyboardKey.pageDown => 'PageDown',
    _ => null,
  };

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final layout = _layout;
    final scope = _scope;
    if (event is KeyUpEvent || layout == null || scope == null) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isAltPressed ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final active = scope.controller.active;
    if (key == LogicalKeyboardKey.escape) {
      if (active == null) return KeyEventResult.ignored;
      scope.controller.activate(active, announce: '');
      _clear();
      return KeyEventResult.handled;
    }
    final vertical =
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown;
    if (widget.seriesCount > 0 &&
        layout.targets.mode != TargetMode.y &&
        vertical) {
      final order = <int?>[
        null,
        for (var i = 0; i < widget.seriesCount; i++) i,
      ];
      final at = order.indexOf(active?.series);
      final step = switch (key == LogicalKeyboardKey.arrowUp) {
        true => 1,
        false => -1,
      };
      final next = order[(at + step + order.length) % order.length];
      _activate(active?.index ?? 0, next, ChartActiveSource.keyboard);
      return KeyEventResult.handled;
    }
    final selecting =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space;
    if (selecting && active != null) {
      widget.onSelect?.call((index: active.index, series: active.series));
      return KeyEventResult.handled;
    }
    final name = _keyName(key);
    if (name == null) return KeyEventResult.ignored;
    final next = stepIndex(layout.targets, active?.index, name);
    if (next == null) return KeyEventResult.ignored;
    _activate(next, active?.series, ChartActiveSource.keyboard);
    return KeyEventResult.handled;
  }

  void _onFocus(bool focused) {
    if (!focused) {
      _pointerFocus = false;
      _clear(ChartActiveSource.keyboard);
      return;
    }
    if (_pointerFocus || _scope?.controller.active != null) return;
    _activate(0, null, ChartActiveSource.keyboard);
  }

  @override
  Widget build(BuildContext context) {
    final scope = ChartScope.of(context);
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final canMove = _canMove;
    final meter = widget.meter;
    final drawing = Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          if (!size.isFinite || size.isEmpty) return const SizedBox.shrink();
          final layout = _layoutFor(size, calm);
          return ListenableBuilder(
            listenable: scope.controller,
            builder: (context, _) =>
                _stack(context, scope, layout, size, canMove),
          );
        },
      ),
    );
    final interactive = switch (canMove) {
      false => drawing,
      true => _input(drawing),
    };
    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          container: true,
          label: widget.label,
          hint: widget.summary,
          value: meter?.text,
          image: !canMove && meter == null,
          child: interactive,
        ),
        Positioned(
          left: 0,
          top: 0,
          child: ChartDataTable(
            caption: widget.label,
            table: widget.table,
            announce: switch (canMove) {
              true => scope.controller,
              false => null,
            },
          ),
        ),
      ],
    );
  }

  Widget _input(Widget child) => TapRegion(
    onTapOutside: (_) => _clear(ChartActiveSource.pointer),
    child: Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      onFocusChange: _onFocus,
      child: MouseRegion(
        onHover: (event) => _track(event.localPosition),
        onExit: (_) => _clear(ChartActiveSource.pointer),
        child: Listener(
          onPointerDown: (event) {
            _pointerFocus = true;
            _focus.requestFocus();
            _track(event.localPosition);
          },
          onPointerMove: (event) {
            if (event.kind == PointerDeviceKind.mouse) return;
            _track(event.localPosition);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _select(details.localPosition),
            child: child,
          ),
        ),
      ),
    ),
  );

  Widget _stack(
    BuildContext context,
    ChartScope scope,
    ChartLayoutBase layout,
    Size size,
    bool canMove,
  ) {
    final seed = inkSeed(widget.seed);
    final active = _active(scope, layout);
    final showCursor = canMove && (scope.tooltip?.cursor ?? true);
    final cursors = switch ((showCursor, active)) {
      (true, final point?) => layout.cursorAt(point.index, point.series),
      _ => const <CursorSpec>[],
    };
    bool behind(CursorSpec c) =>
        c.kind == CursorKind.column || c.kind == CursorKind.guide;
    final described = switch (active) {
      final point? => widget.describe(point.index, point.series, layout),
      null => null,
    };
    final overlay = widget.overlay;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final c in cursors)
          if (behind(c)) ChartCursorMark(cursor: c, seed: seed),
        ClipRect(
          clipper: _Wipe(_reveal),
          child: InkSurface(
            source: RecipeInkSource(
              widget.recipe,
              widget.spec,
              json: widget.specJson,
            ),
            seed: seed,
            child: SizedBox.fromSize(size: size),
          ),
        ),
        Positioned.fill(
          child: FadeTransition(
            opacity: _reveal,
            child: ChartLabels(labels: layout.labels),
          ),
        ),
        if (overlay != null)
          Positioned.fill(
            child: IgnorePointer(child: overlay(context, layout, active)),
          ),
        for (final c in cursors)
          if (!behind(c)) ChartCursorMark(cursor: c, seed: seed),
        if ((scope.tooltip, active, described)
            case (final tooltip?, final point?, final told?) when canMove)
          Positioned.fill(
            child: ChartTooltipLayer(
              anchor: Offset(
                layout.targets.cx[point.index],
                layout.targets.cy[point.index],
              ),
              described: told,
              content: tooltip.content,
            ),
          ),
      ],
    );
  }
}

/// Upstream's `ll-wipe` from the left, run once as the chart appears.
class _Wipe extends CustomClipper<Rect> {
  _Wipe(this.progress) : super(reclip: progress);

  final Animation<double> progress;

  @override
  Rect getClip(Size size) {
    final outside = size.width * 0.04;
    final shown = (size.width + outside) * progress.value;
    return Rect.fromLTRB(
      -outside,
      -size.height * 0.1,
      switch (progress.value >= 1) {
        true => size.width + outside,
        false => -outside + shown,
      },
      size.height * 1.1,
    );
  }

  @override
  bool shouldReclip(_Wipe oldClipper) => oldClipper.progress != progress;
}
