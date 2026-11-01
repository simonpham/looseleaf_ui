import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/rating/rating_item.dart';
import 'package:looseleaf_ui/src/components/rating/rating_scope.dart';
import 'package:looseleaf_ui/src/components/rating/rating_size.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row of hand-drawn stars (or hearts, or suns) you rate with: hover
/// previews, a tap chooses, a marker blob fills the chosen glyphs.
///
/// It is a radio group: Tab lands on the chosen glyph (the first when none
/// is), the arrows, Home and End change the value as they move (left and
/// right swap in right-to-left), Enter and Space press the focused glyph.
/// [allowHalf] steps by 0.5 with a radio over each half. [clearable] lets
/// a tap on the chosen glyph clear it. A [readOnly] rating is an image
/// named "Rated 4.5 out of 5".
///
/// The value is [value] with [onChanged] (controlled), or kept here
/// starting from [initialValue].
///
/// ```dart
/// Rating(
///   value: stars,
///   onChanged: (next) => setState(() => stars = next),
///   semanticLabel: 'Rate this notebook',
/// )
/// ```
///
/// Mirrors `Rating` in upstream `src/components/ui/rating.tsx`.
class Rating extends StatefulWidget {
  const Rating({
    super.key,
    this.value,
    this.initialValue = 0,
    this.onChanged,
    this.max = 5,
    this.allowHalf = false,
    this.readOnly = false,
    this.disabled = false,
    this.invalid = false,
    this.icon = RatingIcon.star,
    this.size = RatingSize.regular,
    this.clearable = false,
    this.labelBuilder,
    this.seed,
    this.semanticLabel,
    this.children,
  });

  /// The chosen value, when the parent owns it.
  final double? value;

  /// The first value when [value] is null.
  final double initialValue;

  /// Called with each new value.
  final ValueChanged<double>? onChanged;

  /// How many glyphs.
  final int max;

  /// Steps by 0.5 instead of 1.
  final bool allowHalf;

  /// Shows the value; no input, an image to screen readers.
  final bool readOnly;

  /// Pencil glyphs, no input, out of the tab order.
  final bool disabled;

  /// Empty glyphs in red pencil (upstream `aria-invalid`).
  final bool invalid;
  final RatingIcon icon;
  final RatingSize size;

  /// A tap on the chosen glyph clears the rating to 0.
  final bool clearable;

  /// Names each radio; "3 of 5" by default (upstream `getLabel`).
  final String Function(double value, int max)? labelBuilder;

  /// Pins the hand; each glyph draws with `seed:index`.
  final String? seed;

  /// Names the group (upstream `aria-label`).
  final String? semanticLabel;

  /// Custom [RatingItem]s instead of one per step.
  final List<Widget>? children;

  /// [value] as upstream prints numbers: `3`, `3.5`.
  static String format(double value) => JsMath.numberToString(value);

  static String _defaultLabel(double value, int max) =>
      '${format(value)} of $max';

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> with InkSeed {
  late double _inner = _snap(widget.initialValue);
  double? _hover;
  double? _sent;
  final Map<double, FocusNode> _nodes = {};

  double get _step => switch (widget.allowHalf) {
    true => 0.5,
    false => 1,
  };

  double _snap(double value) =>
      ((value / _step).round() * _step).clamp(0.0, widget.max.toDouble());

  double get _current => _snap(widget.value ?? _inner);

  bool get _interactive => !widget.readOnly && !widget.disabled;

  FocusNode _nodeFor(double value) => _nodes.putIfAbsent(
    value,
    () => FocusNode(debugLabel: 'Rating ${Rating.format(value)}'),
  );

  @override
  void didUpdateWidget(Rating oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sent = null;
  }

  void _set(double value) {
    final next = _snap(value);
    final current = _sent ?? _current;
    _sent = next;
    if (widget.value == null) setState(() => _inner = next);
    if (next != current) widget.onChanged?.call(next);
  }

  void _select(double value) {
    setState(() => _hover = null);
    final clear = widget.clearable && value == _current;
    _set(switch (clear) {
      true => 0,
      false => value,
    });
  }

  void _preview(double? value) {
    if (_hover == value) return;
    setState(() => _hover = value);
  }

  void _move(double Function(double current, double step) next) {
    if (!_interactive) return;
    final target = next(
      _sent ?? _current,
      _step,
    ).clamp(_step, widget.max.toDouble());
    _set(target);
    _nodeFor(_snap(target)).requestFocus();
  }

  Map<ShortcutActivator, VoidCallback> _bindings(bool rtl) {
    final sign = switch (rtl) {
      true => -1,
      false => 1,
    };
    return {
      const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
          _move((current, step) => current + sign * step),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
          _move((current, step) => current - sign * step),
      const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
          _move((current, step) => current + step),
      const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
          _move((current, step) => current - step),
      const SingleActivator(LogicalKeyboardKey.home): () =>
          _move((current, step) => step),
      const SingleActivator(LogicalKeyboardKey.end): () =>
          _move((current, step) => widget.max.toDouble()),
    };
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final tabStop = switch (current > 0) {
      true => current,
      false => _step,
    };
    for (final MapEntry(key: value, value: node) in _nodes.entries) {
      node.skipTraversal = value != tabStop;
    }
    final shown = switch ((_interactive, _hover)) {
      (true, final hover?) => hover,
      _ => current,
    };
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children:
          widget.children ??
          [for (var i = 1; i <= widget.max; i++) RatingItem(index: i)],
    );
    final scope = RatingScope(
      max: widget.max,
      allowHalf: widget.allowHalf,
      icon: widget.icon,
      size: widget.size,
      shown: shown,
      current: current,
      interactive: _interactive,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      invalid: widget.invalid,
      tabStop: tabStop,
      seed: inkSeed(widget.seed),
      label: widget.labelBuilder ?? Rating._defaultLabel,
      select: _select,
      preview: _preview,
      focusNodeFor: (value) {
        final node = _nodeFor(value);
        node.skipTraversal = value != tabStop;
        return node;
      },
      child: row,
    );
    if (widget.readOnly) {
      return Semantics(
        container: true,
        image: true,
        label:
            widget.semanticLabel ??
            'Rated ${Rating.format(current)} out of ${widget.max}',
        child: ExcludeSemantics(child: scope),
      );
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      container: true,
      role: SemanticsRole.radioGroup,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      child: CallbackShortcuts(
        bindings: _bindings(rtl),
        child: MouseRegion(
          onExit: (_) => _preview(null),
          child: FocusTraversalGroup(child: scope),
        ),
      ),
    );
  }
}
