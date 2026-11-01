import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet you draw on: a cut [paper] sheet the drawing's width, as tall
/// as the drawing's aspect ratio says, in a faint pencil box with a focus
/// ring.
///
/// Draw with a mouse, a finger or a pen. A pen's pressure swells the
/// stroke and its eraser end erases; a touch soon after a pen is taken as
/// a resting palm and ignored. From the keyboard, the arrows move a
/// crosshair (Shift: far, Alt: fine), Space or Enter puts the pen down and
/// lifts it, Escape cancels, F B P M H E pick a tool, `[` and `]` change
/// the width, and Ctrl/⌘ Z, Shift Z and Y undo and redo.
///
/// [child] sits on the paper under the ink (guides, a baseline).
/// [semanticLabel] replaces the whole accessible name, which is [label]
/// ("Drawing") and, when read-only, the stroke count.
///
/// Mirrors `SketchpadCanvas` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadCanvas extends StatefulWidget {
  const SketchpadCanvas({
    super.key,
    this.paper = SketchpadPaper.plain,
    this.stock,
    this.shadow = PaperShadow.stock,
    this.label = 'Drawing',
    this.semanticLabel,
    this.seed,
    this.forcedStates = const {},
    this.child,
  });

  final SketchpadPaper paper;

  /// A stock over [paper]'s (upstream `paperProps.stock`).
  final StockName? stock;

  /// The sheet's shadow (upstream `paperProps.shadow`).
  final PaperShadow shadow;

  /// The canvas's name.
  final String label;

  /// The whole accessible name, over [label].
  final String? semanticLabel;
  final String? seed;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  /// Drawn on the paper under the strokes.
  final Widget? child;

  @override
  State<SketchpadCanvas> createState() => _SketchpadCanvasState();
}

enum _Input { mouse, touch, pen, key }

class _Gesture {
  _Gesture({
    required this.pointer,
    required this.input,
    required this.tool,
    required this.color,
    required this.size,
    required SketchPoint start,
  }) : pts = [start];

  static const int keyPointer = -1;

  final int pointer;
  final _Input input;
  final SketchTool tool;
  final SketchColor color;
  final double size;
  final List<SketchPoint> pts;
  SketchPoint? tail;
  late final Set<String>? erase = switch (tool) {
    SketchTool.eraser => <String>{},
    _ => null,
  };
}

class _SketchpadCanvasState extends State<SketchpadCanvas>
    with SingleTickerProviderStateMixin {
  static const double _sampleGap = 0.8;
  static const int _livePoints = 480;
  static const Duration _palm = Duration(milliseconds: 1500);
  static const double _eraserRadius = 9;
  static const String _help =
      'Draw with a pointer, or use the arrow keys to move a cursor and Space '
      'to put the pen down and lift it. F, B, P, M, H and E pick a tool, the '
      'bracket keys change the width, Control Z undoes.';

  late final AnimationController _clock = AnimationController.unbounded(
    vsync: this,
  );
  _Gesture? _gesture;
  InkDocument? _liveDocument;
  bool _liveDirty = false;
  Set<String> _erasing = const {};
  Offset? _cursor;
  Duration _penSeen = const Duration(days: -1);
  bool _focusVisible = false;
  bool _endScheduled = false;
  SketchpadScope? _scope;
  int? _replayedKey;
  bool _replayStarted = false;
  Map<String, SketchReplayTiming> _timings = const {};
  Size _box = Size.zero;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = SketchpadScope.of(context);
    final previous = _scope;
    _scope = scope;
    if (!identical(previous?.canvasFocusNode, scope.canvasFocusNode)) {
      previous?.canvasFocusNode
        ?..onKeyEvent = null
        ..removeListener(_onFocus);
      scope.canvasFocusNode
        ..onKeyEvent = _onKey
        ..addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    _scope?.canvasFocusNode
      ?..onKeyEvent = null
      ..removeListener(_onFocus);
    _clock.dispose();
    super.dispose();
  }

  SketchpadScope get _pad => _scope ?? SketchpadScope.of(context);
  SketchpadController get _controller => _pad.controller;
  double get _w => _pad.width;
  double get _h => _pad.height;

  void _onHighlightMode(FocusHighlightMode mode) => _syncFocusVisible();
  void _onFocus() {
    _syncFocusVisible();
    if (_pad.canvasFocusNode.hasFocus) return;
    if (_gesture?.input == _Input.key) _end(cancel: false);
    if (_cursor != null) setState(() => _cursor = null);
  }

  void _syncFocusVisible() {
    final visible =
        _pad.canvasFocusNode.hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (visible == _focusVisible || !mounted) return;
    setState(() => _focusVisible = visible);
  }

  void _syncReplay(SketchpadScope scope) {
    final key = scope.controller.replayKey;
    final replaying = scope.replay || key > 0;
    if (!replaying) {
      _replayStarted = false;
      _timings = const {};
      return;
    }
    if (_replayStarted && _replayedKey == key) return;
    _replayStarted = true;
    _replayedKey = key;
    final tier = SketchInk.tier(LooseleafTheme.of(context));
    var t = 0.2;
    final timings = <String, SketchReplayTiming>{};
    for (final stroke in scope.controller.strokes) {
      final length = strokeMarkup(stroke, tier: tier).length;
      final duration = (length / (420 * scope.replaySpeed)).clamp(0.14, 2.4);
      timings[stroke.id] = (delay: t, duration: duration);
      t += duration + 0.08;
    }
    _timings = timings;
    if (InkMotion.reducedIn(context)) {
      _clock.value = t;
      return;
    }
    _clock.value = 0;
    _clock.animateTo(
      t,
      duration: Duration(milliseconds: (t * 1000).round()),
    );
  }

  SketchPoint _project(Offset local) {
    final box = _box;
    final sx = switch (box.width > 0) {
      true => _w / box.width,
      false => 1.0,
    };
    final sy = switch (box.height > 0) {
      true => _h / box.height,
      false => 1.0,
    };
    return (
      _round1((local.dx * sx).clamp(0, _w)),
      _round1((local.dy * sy).clamp(0, _h)),
      null,
    );
  }

  static double _round1(num v) => (v * 10).round() / 10;
  static double _round2(double v) => (v * 100).round() / 100;

  static SketchStroke _liveOf(_Gesture g) => SketchStroke(
    id: 'live',
    tool: g.tool.draw ?? DrawTool.felt,
    color: g.color,
    size: g.size,
    pts: _preview(g.pts),
  );

  static List<SketchPoint> _preview(List<SketchPoint> pts) {
    if (pts.length <= _livePoints) return List.of(pts);
    var k = 2;
    while (pts.length / k > _livePoints) {
      k *= 2;
    }
    final out = [for (var i = 0; i < pts.length; i += k) pts[i]];
    final tail = pts.last;
    if (!identical(out.last, tail)) out.add(tail);
    return out;
  }

  static List<SketchPoint> _thin(List<SketchPoint> pts) {
    final out = <SketchPoint>[];
    for (final p in pts) {
      final last = out.lastOrNull;
      if (last == null || _dist(p, last) >= 1.5) out.add(p);
    }
    final tail = pts.last;
    if (out.length > 1 && !identical(out.last, tail)) out.add(tail);
    return out;
  }

  static double _dist(SketchPoint a, SketchPoint b) =>
      math.sqrt(math.pow(a.$1 - b.$1, 2) + math.pow(a.$2 - b.$2, 2));

  void _showLive(_Gesture g) => setState(() => _liveDirty = true);

  InkDocument? _liveOfFrame(LooseleafThemeData theme) {
    final g = _gesture;
    if (g == null || g.erase != null) return null;
    if (!_liveDirty) return _liveDocument;
    _liveDirty = false;
    final markup = strokeMarkup(
      _liveOf(g),
      tier: SketchInk.tier(theme),
      live: true,
    );
    return _liveDocument = InkDocument.parse(markup.svg);
  }

  void _eraseAt(_Gesture g, SketchPoint p) {
    final erase = g.erase;
    if (erase == null) return;
    var changed = false;
    for (final stroke in _controller.strokes) {
      if (erase.contains(stroke.id)) continue;
      if (!strokeHit(stroke, p.$1, p.$2, _eraserRadius)) continue;
      erase.add(stroke.id);
      changed = true;
    }
    if (changed) setState(() => _erasing = {...erase});
  }

  void _begin(int pointer, _Input input, SketchPoint start, bool eraser) {
    final controller = _controller;
    final g = _Gesture(
      pointer: pointer,
      input: input,
      tool: switch (eraser) {
        true => SketchTool.eraser,
        false => controller.tool,
      },
      color: controller.color,
      size: controller.size,
      start: start,
    );
    _gesture = g;
    if (g.erase != null) {
      _eraseAt(g, start);
      return;
    }
    _showLive(g);
  }

  void _extend(SketchPoint p) {
    final g = _gesture;
    if (g == null) return;
    if (_dist(p, g.pts.last) < _sampleGap) {
      g.tail = p;
      return;
    }
    g
      ..tail = null
      ..pts.add(p);
    if (g.erase != null) {
      _eraseAt(g, p);
      return;
    }
    _showLive(g);
  }

  void _end({required bool cancel}) {
    final g = _gesture;
    if (g == null) return;
    _gesture = null;
    if (mounted) {
      setState(() {
        _liveDocument = null;
        _erasing = const {};
      });
    }
    final controller = _controller;
    if (g.erase case final gone?) {
      if (cancel || gone.isEmpty) return;
      controller.commit([
        for (final stroke in controller.strokes)
          if (!gone.contains(stroke.id)) stroke,
      ], 'Erased ${strokeCount(gone.length)}.');
      return;
    }
    final tool = g.tool.draw;
    if (cancel || tool == null) return;
    if (g.tail case final tail?) {
      final held = g.pts.last.$3;
      g.pts.add(switch ((held, tail.$3)) {
        (final double pressure, null) => (tail.$1, tail.$2, pressure),
        _ => tail,
      });
    }
    controller.commit([
      ...controller.strokes,
      SketchStroke(
        id: controller.nextId(),
        tool: tool,
        color: g.color,
        size: g.size,
        pts: _thin(g.pts),
      ),
    ], 'Stroke added.');
  }

  static _Input _inputOf(PointerDeviceKind kind) => switch (kind) {
    PointerDeviceKind.stylus || PointerDeviceKind.invertedStylus => _Input.pen,
    PointerDeviceKind.touch => _Input.touch,
    _ => _Input.mouse,
  };

  static double? _pressure(PointerEvent event) {
    if (_inputOf(event.kind) != _Input.pen || event.pressure <= 0) return null;
    final range = event.pressureMax - event.pressureMin;
    final normal = switch (range > 0) {
      true => (event.pressure - event.pressureMin) / range,
      false => event.pressure,
    };
    return _round2(normal.clamp(0, 1));
  }

  SketchPoint _pointOf(PointerEvent event) {
    final (x, y, _) = _project(event.localPosition);
    return (x, y, _pressure(event));
  }

  void _onDown(PointerDownEvent event) {
    if (!_pad.interactive) return;
    final input = _inputOf(event.kind);
    if (input == _Input.mouse && event.buttons & kPrimaryMouseButton == 0) {
      return;
    }
    if (input == _Input.pen) {
      _penSeen = event.timeStamp;
      if (_gesture?.input == _Input.touch) _end(cancel: true);
    }
    if (input == _Input.touch && event.timeStamp - _penSeen < _palm) return;
    if (_gesture != null) return;
    _pad.canvasFocusNode.requestFocus();
    if (_cursor != null) setState(() => _cursor = null);
    final eraser =
        event.kind == PointerDeviceKind.invertedStylus ||
        _controller.tool == SketchTool.eraser;
    _begin(event.pointer, input, _pointOf(event), eraser);
  }

  void _onMove(PointerMoveEvent event) {
    if (_inputOf(event.kind) == _Input.pen) _penSeen = event.timeStamp;
    if (_gesture?.pointer != event.pointer) return;
    _extend(_pointOf(event));
  }

  void _onUp(PointerUpEvent event) {
    if (_inputOf(event.kind) == _Input.pen) _penSeen = event.timeStamp;
    final g = _gesture;
    if (g == null || g.pointer != event.pointer) return;
    final (x, y, pressure) = _pointOf(event);
    final held = g.pts.last.$3;
    final p = switch ((g.input, held)) {
      (_Input.pen, final double h) => (x, y, h),
      _ => (x, y, pressure),
    };
    final moved = g.pts.length > 1 || _dist(p, g.pts.first) > 1;
    if (moved) _extend(p);
    _end(cancel: false);
  }

  void _onCancel(PointerCancelEvent event) {
    if (_gesture?.pointer != event.pointer) return;
    _end(cancel: true);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    final mod = keyboard.isMetaPressed || keyboard.isControlPressed;
    final key = event.logicalKey;
    final controller = _controller;
    if (mod && key == LogicalKeyboardKey.keyZ) {
      switch (keyboard.isShiftPressed) {
        case true:
          controller.redo();
        case false:
          controller.undo();
      }
      return KeyEventResult.handled;
    }
    if (mod && key == LogicalKeyboardKey.keyY) {
      controller.redo();
      return KeyEventResult.handled;
    }
    final arrow = _arrows.contains(key);
    final skip =
        !_pad.interactive ||
        mod ||
        (keyboard.isAltPressed && !arrow) ||
        !node.hasPrimaryFocus;
    if (skip) return KeyEventResult.ignored;
    if (arrow) return _nudge(key, keyboard);
    if (event is KeyRepeatEvent) return KeyEventResult.ignored;
    if (_toolKey(key) case final tool?) {
      if (!_pad.tools.contains(tool)) return KeyEventResult.ignored;
      controller
        ..selectTool(tool)
        ..say('${tool.label}.');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.bracketLeft) return _step(-1);
    if (key == LogicalKeyboardKey.bracketRight) return _step(1);
    if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      return _penKey();
    }
    if (key == LogicalKeyboardKey.escape) return _escape();
    return KeyEventResult.ignored;
  }

  static final Set<LogicalKeyboardKey> _arrows = {
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
  };

  static SketchTool? _toolKey(LogicalKeyboardKey key) {
    final label = key.keyLabel.toLowerCase();
    for (final tool in SketchTool.values) {
      if (tool.key == label) return tool;
    }
    return null;
  }

  KeyEventResult _step(int direction) {
    final controller = _controller;
    const steps = SketchSizeName.values;
    var best = 0;
    for (var i = 0; i < steps.length; i++) {
      final closer =
          (steps[i].size - controller.size).abs() <
          (steps[best].size - controller.size).abs();
      if (closer) best = i;
    }
    final next = steps[(best + direction).clamp(0, steps.length - 1)];
    controller
      ..size = next.size
      ..say('${next.label} line.');
    return KeyEventResult.handled;
  }

  KeyEventResult _nudge(LogicalKeyboardKey key, HardwareKeyboard keyboard) {
    final d = switch ((keyboard.isShiftPressed, keyboard.isAltPressed)) {
      (true, _) => SketchpadMetrics.nudgeFar,
      (false, true) => SketchpadMetrics.nudgeFine,
      (false, false) => SketchpadMetrics.nudge,
    };
    final at = _cursor ?? Offset(_w / 2, _h / 2);
    final dx = switch (key) {
      LogicalKeyboardKey.arrowRight => d,
      LogicalKeyboardKey.arrowLeft => -d,
      _ => 0.0,
    };
    final dy = switch (key) {
      LogicalKeyboardKey.arrowDown => d,
      LogicalKeyboardKey.arrowUp => -d,
      _ => 0.0,
    };
    final next = Offset(
      _round1((at.dx + dx).clamp(0, _w)),
      _round1((at.dy + dy).clamp(0, _h)),
    );
    setState(() => _cursor = next);
    if (_gesture?.input == _Input.key) _extend((next.dx, next.dy, null));
    return KeyEventResult.handled;
  }

  KeyEventResult _penKey() {
    final at = _cursor ?? Offset(_w / 2, _h / 2);
    setState(() => _cursor = at);
    final g = _gesture;
    if (g?.input == _Input.key) {
      _end(cancel: false);
      return KeyEventResult.handled;
    }
    if (g != null) return KeyEventResult.handled;
    final eraser = _controller.tool == SketchTool.eraser;
    _begin(_Gesture.keyPointer, _Input.key, (at.dx, at.dy, null), eraser);
    _controller.say(switch (eraser) {
      true => 'Eraser down.',
      false => 'Pen down.',
    });
    return KeyEventResult.handled;
  }

  KeyEventResult _escape() {
    if (_gesture?.input == _Input.key) {
      _end(cancel: true);
      _controller.say('Stroke canceled.');
      return KeyEventResult.handled;
    }
    if (_cursor == null) return KeyEventResult.ignored;
    setState(() => _cursor = null);
    return KeyEventResult.handled;
  }

  void _dropGestureIfLocked(SketchpadScope pad) {
    if (pad.interactive || _gesture == null || _endScheduled) return;
    _endScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _endScheduled = false;
      if (mounted && !_pad.interactive) _end(cancel: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = SketchpadScope.of(context);
    _dropGestureIfLocked(pad);
    _syncReplay(pad);
    final interactive = pad.interactive;
    final controller = pad.controller;
    final strokes = controller.strokes;
    final semanticLabel = switch (interactive) {
      true => widget.semanticLabel ?? widget.label,
      false =>
        widget.semanticLabel ??
            '${widget.label}, ${strokeCount(strokes.length)}',
    };
    return Semantics(
      container: true,
      label: semanticLabel,
      hint: switch (interactive) {
        true => _help,
        false => null,
      },
      image: !interactive,
      child: Focus(
        focusNode: pad.canvasFocusNode,
        canRequestFocus: interactive,
        skipTraversal: !interactive,
        child: MouseRegion(
          cursor: switch ((interactive, controller.tool)) {
            (false, _) => SystemMouseCursors.basic,
            (true, SketchTool.eraser) => SystemMouseCursors.cell,
            (true, _) => SystemMouseCursors.precise,
          },
          child: LayoutBuilder(
            builder: (context, constraints) =>
                _sheet(context, pad, constraints),
          ),
        ),
      ),
    );
  }

  Widget _sheet(
    BuildContext context,
    SketchpadScope pad,
    BoxConstraints constraints,
  ) {
    final width = switch (constraints.hasBoundedWidth) {
      true => constraints.maxWidth,
      false => pad.width,
    };
    final box = Size(width, width * pad.height / pad.width);
    _box = box;
    final theme = LooseleafTheme.of(context);
    final controller = pad.controller;
    final paper = Paper(
      stock: widget.stock ?? widget.paper.stock,
      rules: widget.paper.rules,
      edge: const EdgeSpec(),
      tilt: false,
      shadow: widget.shadow,
      seed: widget.seed,
      child: SizedBox.fromSize(
        size: box,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ?widget.child,
            RepaintBoundary(
              child: CustomPaint(
                painter: SketchStrokesPainter(
                  strokes: controller.strokes,
                  width: pad.width,
                  height: pad.height,
                  theme: theme,
                  dimmed: _erasing,
                  timings: _timings,
                  clock: _clock,
                ),
              ),
            ),
            CustomPaint(
              painter: SketchLivePainter(
                live: _liveOfFrame(theme),
                cursor: switch (_cursor) {
                  final at? => (
                    document: SketchInk.cursor(pad.seed),
                    at: at,
                  ),
                  null => null,
                },
                width: pad.width,
                height: pad.height,
                theme: theme,
              ),
            ),
            _Announcer(message: controller.announcement),
          ],
        ),
      ),
    );
    final framed = InkSurface(
      source: RecipeInkSource(canvasFrameRecipe, const NoParams()),
      seed: '${pad.seed}|canvas${widget.seed ?? ''}',
      states: {
        ...widget.forcedStates,
        if (_focusVisible && pad.interactive) InkState.focused,
      },
      still: true,
      child: paper,
    );
    if (!pad.interactive) return framed;
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        EagerGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
              EagerGestureRecognizer.new,
              (_) {},
            ),
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onDown,
        onPointerMove: _onMove,
        onPointerUp: _onUp,
        onPointerCancel: _onCancel,
        child: framed,
      ),
    );
  }
}

class _Announcer extends StatelessWidget {
  const _Announcer({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: message,
    child: const SizedBox.shrink(),
  );
}
