import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/stepper/stepper_button.dart';
import 'package:looseleaf_ui/src/components/stepper/stepper_metrics.dart';
import 'package:looseleaf_ui/src/components/stepper/stepper_number.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Formats a [Stepper]'s value for the box.
typedef StepperFormat = String Function(double value);

/// Reads a typed [Stepper] value; null rejects the text.
typedef StepperParse = double? Function(String text);

/// A number field with − and + cells in a pencil box: the number in blue
/// felt script, ticking up or down as it changes, the box rattling when a
/// bound stops it.
///
/// The number is editable text; ArrowUp / ArrowDown step (Shift steps
/// [largeStep]), Page Up / Page Down step [largeStep], Home and End jump to
/// [min] and [max], Enter or leaving the field commits typed text, Escape
/// drops it. Holding a button repeats after a pause, faster after a while.
/// With [wheel] the mouse wheel steps while the number has focus.
///
/// ```dart
/// Stepper(
///   value: quantity,
///   min: 0,
///   max: 10,
///   onChanged: (value) => setState(() => quantity = value),
///   semanticLabel: 'Quantity',
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/stepper.tsx`.
class Stepper extends StatefulWidget {
  const Stepper({
    super.key,
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.largeStep,
    this.snap = false,
    this.precision,
    this.format,
    this.parse,
    this.wheel = false,
    this.required = false,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.width,
    this.decrementLabel = 'Decrease',
    this.incrementLabel = 'Increase',
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The number, or null for an empty field.
  final double? value;

  /// Called with the next number (null when cleared).
  final ValueChanged<double?>? onChanged;

  final double? min;
  final double? max;

  /// What the buttons and arrows add; 1 when not positive.
  final double step;

  /// What Shift-arrows and the Page keys add; ten steps when null.
  final double? largeStep;

  /// Snaps every value to the step grid from [min] (or 0).
  final bool snap;

  /// Decimal places, for rounding and the default format.
  final int? precision;

  /// The box's text for a value.
  final StepperFormat? format;

  /// Reads typed text; the default understands `.` and `,` decimals.
  final StepperParse? parse;

  /// The mouse wheel steps while the number has focus.
  final bool wheel;

  /// Clearing the text is refused instead of emptying the value.
  final bool required;

  /// The dashed box, graphite number, no input.
  final bool disabled;

  /// Focusable and selectable, but nothing changes it.
  final bool readOnly;

  /// The red-pencil box.
  final bool invalid;

  /// A fixed width (like upstream's `w-44`); fits its content when null.
  final double? width;

  /// The − button's name.
  final String decrementLabel;

  /// The + button's name.
  final String incrementLabel;

  /// Pins the hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The number's accessible name.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Stepper> createState() => _StepperState();
}

class _StepperState extends State<Stepper>
    with InkSeed, TickerProviderStateMixin {
  final TextEditingController _text = TextEditingController();
  late final AnimationController _tick;
  late final AnimationController _rattle;
  FocusNode? _ownFocusNode;
  double? _latest;
  int _direction = 1;
  int _holding = 0;
  Timer? _wait;
  Timer? _repeat;
  int _repeats = 0;
  bool _hovered = false;
  bool _draft = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  double get _stepSize => switch (widget.step.isFinite && widget.step > 0) {
    true => widget.step,
    false => 1,
  };

  double get _large => widget.largeStep ?? _stepSize * 10;

  int get _places =>
      widget.precision ??
      math.max(
        StepperNumber.decimals(_stepSize),
        StepperNumber.decimals(widget.min),
      );

  @override
  void initState() {
    super.initState();
    _tick = AnimationController(
      vsync: this,
      duration: InkMotion.pop,
      value: 1,
    );
    _rattle = AnimationController(
      vsync: this,
      duration: StepperMetrics.rattle,
      value: 1,
    );
    _latest = _finite(widget.value);
    _text.text = _shown;
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(Stepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.focusNode ?? _ownFocusNode;
    if (old != _focusNode) {
      old?.removeListener(_onFocus);
      _focusNode.addListener(_onFocus);
    }
    _latest = _finite(widget.value);
    if (!_draft) _text.text = _shown;
  }

  @override
  void dispose() {
    _wait?.cancel();
    _repeat?.cancel();
    _focusNode.removeListener(_onFocus);
    _ownFocusNode?.dispose();
    _text.dispose();
    _tick.dispose();
    _rattle.dispose();
    super.dispose();
  }

  static double? _finite(double? value) => switch (value) {
    final number? when number.isFinite => number,
    _ => null,
  };

  String _format(double value) =>
      widget.format?.call(value) ??
      switch (widget.precision) {
        final places? => value.toStringAsFixed(places),
        null => StepperNumber.plain(value),
      };

  String get _shown => switch (_latest) {
    final value? => _format(value),
    null => '',
  };

  void _onFocus() {
    if (!_focusNode.hasFocus) {
      _commit();
      _stopHold();
    }
    setState(() {});
  }

  bool get _locked => widget.disabled || widget.readOnly;

  double _clamp(double n) => math.min(
    widget.max ?? double.infinity,
    math.max(widget.min ?? -double.infinity, n),
  );

  double _snapTo(double n) {
    if (!widget.snap) return n;
    final origin = widget.min ?? 0;
    return origin + ((n - origin) / _stepSize).round() * _stepSize;
  }

  void _set(double? next) {
    _latest = next;
    _draft = false;
    _text.text = _shown;
    widget.onChanged?.call(next);
  }

  void _animate(int direction) {
    _direction = direction;
    if (InkMotion.reducedIn(context)) return;
    _tick.forward(from: 0);
  }

  void _nudge() {
    if (InkMotion.reducedIn(context)) return;
    _rattle.forward(from: 0);
  }

  void _adjust(double delta) {
    if (_locked) return;
    final from = _latest;
    final next = _clamp(
      StepperNumber.round(
        _snapTo((from ?? 0) + delta),
        math.max(_places, StepperNumber.decimals(from)),
      ),
    );
    if (next == from) {
      if (delta != 0) _nudge();
      return;
    }
    _animate(switch (delta > 0) {
      true => 1,
      false => -1,
    });
    setState(() => _set(next));
  }

  void _jump(double? to) {
    if (_locked || to == null || to == _latest) return;
    final from = _latest;
    _animate(switch (from == null || to > from) {
      true => 1,
      false => -1,
    });
    setState(() => _set(to));
  }

  void _commit() {
    if (!_draft) return;
    final text = _text.text;
    _draft = false;
    if (text.trim().isEmpty) {
      if (widget.required) return setState(() => _text.text = _shown);
      return setState(() => _set(null));
    }
    final parsed = widget.parse?.call(text) ?? StepperNumber.parse(text);
    if (parsed == null || !parsed.isFinite) {
      return setState(() => _text.text = _shown);
    }
    final next = _clamp(
      double.parse(_snapTo(parsed).toStringAsPrecision(12)),
    );
    setState(() {
      if (next != _latest) return _set(next);
      _text.text = _shown;
    });
  }

  void _startHold(int direction) {
    _stopHold();
    if (_locked) return;
    _adjust(direction * _stepSize);
    setState(() => _holding = direction);
    _wait = Timer(StepperMetrics.holdDelay, () {
      _repeat = Timer.periodic(StepperMetrics.holdEvery, (_) {
        final before = _latest;
        final factor = switch (_repeats > StepperMetrics.holdSpeedUp) {
          true => 5,
          false => 1,
        };
        _adjust(direction * _stepSize * factor);
        _repeats++;
        if (_latest == before) _stopHold();
      });
    });
  }

  void _stopHold() {
    _wait?.cancel();
    _repeat?.cancel();
    _wait = null;
    _repeat = null;
    _repeats = 0;
    if (_holding != 0 && mounted) setState(() => _holding = 0);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.disabled) return KeyEventResult.ignored;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final big = switch (shift) {
      true => _large,
      false => _stepSize,
    };
    void step(double delta) {
      _draft = false;
      _adjust(delta);
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        step(big);
      case LogicalKeyboardKey.arrowDown:
        step(-big);
      case LogicalKeyboardKey.pageUp:
        step(_large);
      case LogicalKeyboardKey.pageDown:
        step(-_large);
      case LogicalKeyboardKey.home when widget.min != null:
        _draft = false;
        _jump(widget.min);
      case LogicalKeyboardKey.end when widget.max != null:
        _draft = false;
        _jump(widget.max);
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter:
        _commit();
        return KeyEventResult.ignored;
      case LogicalKeyboardKey.escape when _draft:
        setState(() {
          _draft = false;
          _text.text = _shown;
        });
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _onWheel(PointerSignalEvent event) {
    if (!widget.wheel || widget.disabled || !_focusNode.hasFocus) return;
    if (event is! PointerScrollEvent || event.scrollDelta.dy == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _adjust(switch (event.scrollDelta.dy < 0) {
        true => _stepSize,
        false => -_stepSize,
      });
    });
  }

  double _inputWidth(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final ch = painter.width;
    painter.dispose();
    final chars = math.max(3, _text.text.length) + 1;
    return math.max(StepperMetrics.inputWidth, ch * chars) +
        StepperMetrics.inputPadding.horizontal;
  }

  static const _rattleAngles = [0.0, -1.6, 1.3, -0.7, 0.0];
  static const _rattleStops = [0.0, 0.2, 0.45, 0.7, 1.0];

  double _rattleAngle(double t) {
    for (var i = 1; i < _rattleStops.length; i++) {
      if (t > _rattleStops[i]) continue;
      final span = _rattleStops[i] - _rattleStops[i - 1];
      final local = (t - _rattleStops[i - 1]) / span;
      final degrees =
          _rattleAngles[i - 1] +
          (_rattleAngles[i] - _rattleAngles[i - 1]) * local;
      return degrees * math.pi / 180;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final stepper = widget;
    final value = _latest;
    final atMin = switch ((value, stepper.min)) {
      (final current?, final min?) => current <= min,
      _ => false,
    };
    final atMax = switch ((value, stepper.max)) {
      (final current?, final max?) => current >= max,
      _ => false,
    };
    final enabled = !stepper.disabled;
    final params = StepperParams(
      disabled: stepper.disabled,
      invalid: stepper.invalid && !stepper.disabled,
      plain: false,
    );
    final style = theme.typography.face(
      KevinSansFace.script,
      cssSize: StepperMetrics.cssFontSize.resolve(theme.density),
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
      color: switch (stepper.disabled) {
        true => theme.colors.pencilText,
        false => theme.colors.inputInk,
      },
    );
    final margin = StepperMetrics.buttonMargin.resolve(theme.density);
    final height = StepperMetrics.height.resolve(theme.density);
    final number = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        label: stepper.semanticLabel,
        value: _shown,
        increasedValue: switch (value) {
          final current? => _format(_clamp(current + _stepSize)),
          null => null,
        },
        decreasedValue: switch (value) {
          final current? => _format(_clamp(current - _stepSize)),
          null => null,
        },
        onIncrease: switch (_locked || atMax) {
          true => null,
          false => () => _adjust(_stepSize),
        },
        onDecrease: switch (_locked || atMin) {
          true => null,
          false => () => _adjust(-_stepSize),
        },
        child: AnimatedBuilder(
          animation: _tick,
          builder: (context, child) {
            final t = _tick.value;
            final eased = InkMotion.settle.transform(t);
            return Opacity(
              opacity:
                  StepperMetrics.tickOpacity +
                  (1 - StepperMetrics.tickOpacity) * t,
              child: FractionalTranslation(
                translation: Offset(
                  0,
                  _direction * StepperMetrics.tickSlide * (1 - eased),
                ),
                child: child,
              ),
            );
          },
          child: DefaultTextStyle.merge(
            style: style,
            child: InputControl(
              controller: _text,
              focusNode: _focusNode,
              disabled: stepper.disabled,
              readOnly: stepper.readOnly,
              autofocus: stepper.autofocus,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              padding: StepperMetrics.inputPadding,
              alignment: Alignment.center,
              onChanged: (_) => setState(() => _draft = true),
            ),
          ),
        ),
      ),
    );
    Widget button(int direction) => Padding(
      padding: EdgeInsets.all(margin),
      child: StepperButton(
        semanticLabel: switch (direction) {
          1 => stepper.incrementLabel,
          _ => stepper.decrementLabel,
        },
        exhausted:
            stepper.readOnly ||
            switch (direction) {
              1 => atMax,
              _ => atMin,
            },
        disabled: stepper.disabled,
        holding: _holding == direction,
        onHold: () => _startHold(direction),
        onRelease: _stopHold,
        onStep: () => _adjust(direction * _stepSize),
        onBlocked: switch (stepper.readOnly) {
          true => null,
          false => _nudge,
        },
        child: InkIcon(switch (direction) {
          1 => 'plus',
          _ => 'minus',
        }, size: StepperMetrics.icon),
      ),
    );
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button(-1),
        switch (stepper.width) {
          null => SizedBox(
            width: _inputWidth(style),
            child: ClipRect(child: number),
          ),
          _ => Expanded(child: ClipRect(child: number)),
        },
        button(1),
      ],
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Listener(
        onPointerSignal: _onWheel,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedBuilder(
            animation: _rattle,
            builder: (context, child) => Transform.rotate(
              angle: _rattleAngle(Curves.easeOut.transform(_rattle.value)),
              child: child,
            ),
            child: InkSurface(
              source: RecipeInkSource(
                stepperRecipe,
                params,
                json: params.toJson(),
              ),
              seed: inkSeed(stepper.seed),
              states: {
                ...stepper.forcedStates,
                if (!enabled) InkState.disabled,
                if (stepper.invalid) InkState.invalid,
                if (enabled && _hovered) InkState.hovered,
                if (enabled && _focusNode.hasFocus) InkState.focused,
              },
              still: true,
              child: SizedBox(
                width: stepper.width,
                height: height,
                child: row,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
