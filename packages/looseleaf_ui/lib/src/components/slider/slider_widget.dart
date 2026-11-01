import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/slider/slider_geometry.dart';
import 'package:looseleaf_ui/src/components/slider/slider_thumb.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds the spoken text of the thumb at [index] holding [value].
typedef SliderValueText = String Function(double value, int index);

/// A pencil groove filled with marker up to a paper thumb, with optional
/// ticks below. Two values make a range with a thumb at each end.
///
/// Drag anywhere on it to move the nearest thumb. Each thumb is a Tab stop:
/// the arrow keys move it a [step] (Shift or Page Up / Page Down move ten),
/// Home and End jump to [min] and [max]. Horizontal sliders follow the
/// reading direction; [inverted] flips them.
///
/// ```dart
/// Slider(
///   values: [volume],
///   onChanged: (values) => setState(() => volume = values.first),
///   semanticLabel: 'Volume',
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/slider.tsx`.
class Slider extends StatefulWidget {
  const Slider({
    super.key,
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.ticks = false,
    this.tickCount,
    this.tone,
    this.direction = Axis.horizontal,
    this.inverted = false,
    this.disabled = false,
    this.invalid = false,
    this.valueText,
    this.seed,
    this.semanticLabel,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// One value per thumb.
  final List<double> values;

  /// Called with the new values while dragging and on each key.
  final ValueChanged<List<double>>? onChanged;

  /// Called with the values when a drag ends or a key moves a thumb.
  final ValueChanged<List<double>>? onChangeEnd;

  final double min;
  final double max;

  /// The value grid thumbs snap to.
  final double step;

  /// Draws ticks under the track, one per step when that makes 1 to 20
  /// intervals, else 10.
  final bool ticks;

  /// The number of tick intervals, overriding [ticks].
  final int? tickCount;

  /// The fill: marker (the default), highlighter or blue felt.
  final SliderTone? tone;

  /// A horizontal slider fills its width; a vertical one its height (at
  /// least 176 px), with [min] at the bottom.
  final Axis direction;

  /// Puts [min] at the other end.
  final bool inverted;

  /// Grey pencil, no input.
  final bool disabled;

  /// Red pencil (upstream `aria-invalid`).
  final bool invalid;

  /// What screen readers say for a value; the number when null.
  final SliderValueText? valueText;

  /// Pins the hand.
  final String? seed;

  /// The accessible name.
  final String? semanticLabel;

  /// Focuses the first thumb on mount.
  final bool autofocus;

  /// States every thumb shows whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> with InkSeed {
  final List<FocusNode> _nodes = [];
  final Set<int> _hovered = {};
  int? _dragging;
  bool _highlight =
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  bool get _vertical => widget.direction == Axis.vertical;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
    _syncNodes();
  }

  @override
  void didUpdateWidget(Slider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  void _syncNodes() {
    while (_nodes.length < widget.values.length) {
      _nodes.add(FocusNode()..addListener(_onFocus));
    }
    while (_nodes.length > widget.values.length) {
      _nodes.removeLast().dispose();
    }
    for (final node in _nodes) {
      node.canRequestFocus = !widget.disabled;
    }
  }

  void _onFocus() => setState(() {});

  void _onHighlightMode(FocusHighlightMode mode) =>
      setState(() => _highlight = mode == FocusHighlightMode.traditional);

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _startsLow(BuildContext context) {
    if (_vertical) return widget.inverted;
    final ltr = Directionality.of(context) == TextDirection.ltr;
    return ltr != widget.inverted;
  }

  SliderGeometry _geometry(BuildContext context, Size size) => SliderGeometry(
    length: switch (_vertical) {
      true => size.height,
      false => size.width,
    },
    min: widget.min,
    max: widget.max,
    step: widget.step,
    startsLow: _startsLow(context),
  );

  List<double> _with(int index, double value) {
    final values = [...widget.values];
    final low = switch (index) {
      0 => widget.min,
      _ => values[index - 1],
    };
    final high = switch (index == values.length - 1) {
      true => widget.max,
      false => values[index + 1],
    };
    values[index] = value.clamp(low, high);
    return values;
  }

  void _set(int index, double value, {required bool end}) {
    final values = _with(index, value);
    if (values[index] != widget.values[index]) widget.onChanged?.call(values);
    if (end) widget.onChangeEnd?.call(values);
  }

  int _nearest(SliderGeometry geometry, double offset) {
    final value = geometry.valueAt(offset);
    var best = 0;
    for (final (index, current) in widget.values.indexed) {
      final distance = (current - value).abs();
      final bestDistance = (widget.values[best] - value).abs();
      if (distance < bestDistance) best = index;
      if (distance == bestDistance && value > current) best = index;
    }
    return best;
  }

  double _along(Offset position) => switch (_vertical) {
    true => position.dy,
    false => position.dx,
  };

  void _onDragStart(SliderGeometry geometry, Offset position) {
    if (widget.values.isEmpty) return;
    final offset = _along(position);
    final index = _nearest(geometry, offset);
    _nodes[index].requestFocus();
    setState(() => _dragging = index);
    _set(index, geometry.valueAt(offset), end: false);
  }

  void _onDragUpdate(SliderGeometry geometry, Offset position) {
    final index = _dragging;
    if (index == null) return;
    _set(index, geometry.valueAt(_along(position)), end: false);
  }

  void _onDragEnd() {
    final index = _dragging;
    if (index == null) return;
    setState(() => _dragging = null);
    widget.onChangeEnd?.call(widget.values);
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final big =
        HardwareKeyboard.instance.isShiftPressed ||
        key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown;
    final stride =
        widget.step *
        switch (big) {
          true => 10,
          false => 1,
        };
    final current = widget.values[index];
    final next = switch (_direction(key)) {
      _Move.back => current - stride,
      _Move.forward => current + stride,
      _Move.home => widget.min,
      _Move.end => widget.max,
      null => null,
    };
    if (next == null) return KeyEventResult.ignored;
    _set(index, _snapped(next), end: true);
    return KeyEventResult.handled;
  }

  double _snapped(double value) => SliderGeometry(
    length: 0,
    min: widget.min,
    max: widget.max,
    step: widget.step,
    startsLow: true,
  ).snap(value);

  _Move? _direction(LogicalKeyboardKey key) {
    final fromRight =
        !_vertical &&
        (Directionality.of(context) == TextDirection.rtl) != widget.inverted;
    final fromTop = _vertical && widget.inverted;
    return switch (key) {
      LogicalKeyboardKey.home => _Move.home,
      LogicalKeyboardKey.end => _Move.end,
      LogicalKeyboardKey.pageDown => _Move.back,
      LogicalKeyboardKey.pageUp => _Move.forward,
      LogicalKeyboardKey.arrowLeft => switch (fromRight) {
        true => _Move.forward,
        false => _Move.back,
      },
      LogicalKeyboardKey.arrowRight => switch (fromRight) {
        true => _Move.back,
        false => _Move.forward,
      },
      LogicalKeyboardKey.arrowDown => switch (fromTop) {
        true => _Move.forward,
        false => _Move.back,
      },
      LogicalKeyboardKey.arrowUp => switch (fromTop) {
        true => _Move.back,
        false => _Move.forward,
      },
      _ => null,
    };
  }

  String _spoken(int index) {
    final value = widget.values[index];
    return widget.valueText?.call(value, index) ?? _number(value);
  }

  static String _number(double value) =>
      switch (value == value.roundToDouble()) {
        true => value.round().toString(),
        false => value.toString(),
      };

  @override
  Widget build(BuildContext context) {
    final slider = widget;
    final seed = inkSeed(slider.seed);
    final vertical = _vertical;
    final intervals = SliderGeometry.tickIntervals(
      ticks: slider.ticks,
      count: slider.tickCount,
      min: slider.min,
      max: slider.max,
      step: slider.step,
    );
    final invalid = slider.invalid;
    final trackParams = SliderTrackParams(
      vertical: vertical,
      ticks: intervals,
      disabled: slider.disabled,
      invalid: invalid,
    );
    final rangeParams = SliderRangeParams(
      vertical: vertical,
      tone: slider.tone ?? SliderTone.marker,
      disabled: slider.disabled,
    );
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final size = switch (vertical) {
          true => Size(
            Spacing.d24,
            math.max(_minLength, _bounded(constraints.maxHeight)),
          ),
          false => Size(_bounded(constraints.maxWidth), Spacing.d24),
        };
        final geometry = _geometry(context, size);
        final (from, to) = geometry.fill(slider.values);
        final track = InkSurface(
          source: RecipeInkSource(
            sliderTrackRecipe,
            trackParams,
            json: trackParams.toJson(),
          ),
          seed: '$seed:track',
          still: true,
          child: ClipRect(
            clipper: SliderFillClipper(
              axis: slider.direction,
              from: from,
              to: to,
            ),
            child: InkSurface(
              source: RecipeInkSource(
                sliderRangeRecipe,
                rangeParams,
                json: rangeParams.toJson(),
              ),
              seed: '$seed:range',
              still: true,
              child: switch (vertical) {
                true => SizedBox(width: Spacing.d8, height: size.height),
                false => SizedBox(width: size.width, height: Spacing.d8),
              },
            ),
          ),
        );
        return SizedBox.fromSize(
          size: size,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: switch (slider.disabled) {
              true => null,
              false => (details) => _onDragStart(
                geometry,
                details.localPosition,
              ),
            },
            onPanUpdate: switch (slider.disabled) {
              true => null,
              false => (details) => _onDragUpdate(
                geometry,
                details.localPosition,
              ),
            },
            onPanEnd: switch (slider.disabled) {
              true => null,
              false => (_) => _onDragEnd(),
            },
            onPanCancel: switch (slider.disabled) {
              true => null,
              false => _onDragEnd,
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: track),
                for (final (index, value) in slider.values.indexed)
                  _thumb(context, geometry, size, index, value, seed),
              ],
            ),
          ),
        );
      },
    );
    return Semantics(
      container: true,
      explicitChildNodes: slider.values.length > 1,
      label: switch (slider.values.length > 1) {
        true => slider.semanticLabel,
        false => null,
      },
      child: MouseRegion(
        cursor: switch (slider.disabled) {
          true => SystemMouseCursors.forbidden,
          false => MouseCursor.defer,
        },
        child: switch (vertical) {
          true => SizedBox(width: Spacing.d24, child: body),
          false => SizedBox(height: Spacing.d24, child: body),
        },
      ),
    );
  }

  static const double _minLength = Spacing.d176;

  static double _bounded(double extent) => switch (extent.isFinite) {
    true => extent,
    false => _minLength,
  };

  Widget _thumb(
    BuildContext context,
    SliderGeometry geometry,
    Size size,
    int index,
    double value,
    String seed,
  ) {
    final slider = widget;
    final enabled = !slider.disabled;
    final node = _nodes[index];
    final center = geometry.offsetOf(geometry.fraction(value));
    const half = SliderGeometry.thumb / 2;
    final states = {
      ...slider.forcedStates,
      if (!enabled) InkState.disabled,
      if (enabled && _hovered.contains(index)) InkState.hovered,
      if (enabled && _dragging == index) InkState.pressed,
      if (enabled && _highlight && node.hasFocus) InkState.focused,
    };
    final multi = slider.values.length > 1;
    final increased = _with(index, _snapped(value + slider.step))[index];
    final decreased = _with(index, _snapped(value - slider.step))[index];
    return Positioned(
      left: switch (_vertical) {
        true => (size.width - SliderGeometry.thumb) / 2,
        false => center - half,
      },
      top: switch (_vertical) {
        true => center - half,
        false => (size.height - SliderGeometry.thumb) / 2,
      },
      child: Semantics(
        container: true,
        slider: true,
        enabled: enabled,
        focusable: enabled,
        focused: node.hasFocus,
        label: switch (multi) {
          true => null,
          false => slider.semanticLabel,
        },
        value: _spoken(index),
        increasedValue:
            slider.valueText?.call(increased, index) ?? _number(increased),
        decreasedValue:
            slider.valueText?.call(decreased, index) ?? _number(decreased),
        onIncrease: switch (enabled) {
          true => () => _set(index, increased, end: true),
          false => null,
        },
        onDecrease: switch (enabled) {
          true => () => _set(index, decreased, end: true),
          false => null,
        },
        child: Focus(
          focusNode: node,
          autofocus: slider.autofocus && index == 0,
          onKeyEvent: (_, event) => _onKey(index, event),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered.add(index)),
            onExit: (_) => setState(() => _hovered.remove(index)),
            child: InkHitArea(
              slop: const EdgeInsets.all(Spacing.d6),
              child: SliderThumb(
                seed: '$seed:thumb$index',
                states: states,
                disabled: slider.disabled,
                invalid: slider.invalid,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Move { back, forward, home, end }
