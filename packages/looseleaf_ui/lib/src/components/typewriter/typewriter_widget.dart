import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show CaretShape, Rng, TypingMode, TypingOptions, typingPlan;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/typewriter/typewriter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Text typed out key by key on a typewriter face, with an inked caret
/// that blinks while it waits. Punctuation holds longer and every key
/// jitters, like a person typing; [TypingMode.cycle] types and backspaces
/// each phrase in turn.
///
/// Screen readers get the whole text at once (as a live region unless it
/// loops); reduced motion shows it typed.
///
/// ```dart
/// Typewriter('Dear diary, today I shipped it.')
/// ```
///
/// Mirrors upstream `src/components/ui/typewriter.tsx`. Upstream waits
/// until it scrolls into view; this starts typing when first built.
class Typewriter extends StatefulWidget {
  /// Types one [text].
  Typewriter(
    String text, {
    super.key,
    this.mode = TypingMode.lines,
    this.speed = 22,
    this.delay = const Duration(milliseconds: 300),
    this.pause = const Duration(milliseconds: 1400),
    this.loop = false,
    this.cursor = CaretShape.bar,
    this.reserve = false,
    this.onDone,
    this.seed,
    this.style,
  }) : phrases = [text];

  /// Types [phrases]: one per line, or in turn with [TypingMode.cycle].
  const Typewriter.phrases(
    this.phrases, {
    super.key,
    this.mode = TypingMode.lines,
    this.speed = 22,
    this.delay = const Duration(milliseconds: 300),
    this.pause = const Duration(milliseconds: 1400),
    this.loop = false,
    this.cursor = CaretShape.bar,
    this.reserve = false,
    this.onDone,
    this.seed,
    this.style,
  });

  final List<String> phrases;
  final TypingMode mode;

  /// Keys per second.
  final double speed;

  /// The wait before the first key.
  final Duration delay;

  /// The pause between phrases.
  final Duration pause;

  /// Start over once done.
  final bool loop;

  /// The caret, or null for none.
  final CaretShape? cursor;

  /// Keep the room of the longest text from the start, so nothing around
  /// it moves while it types.
  final bool reserve;

  /// Called once the last key is typed (not when looping).
  final VoidCallback? onDone;

  /// Pins the rhythm and the jitter.
  final String? seed;

  /// Overrides the typewriter face.
  final TextStyle? style;

  @override
  State<Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<Typewriter> with InkSeed {
  String _shown = '';
  bool _typing = false;
  bool _started = false;
  Timer? _timer;
  Timer? _rest;

  String get _final => switch (widget.mode) {
    TypingMode.cycle => widget.phrases.lastOrNull ?? '',
    TypingMode.lines => widget.phrases.join('\n'),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void didUpdateWidget(Typewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    final same =
        oldWidget.phrases.join('\u0000') == widget.phrases.join('\u0000') &&
        oldWidget.mode == widget.mode &&
        oldWidget.speed == widget.speed &&
        oldWidget.pause == widget.pause &&
        oldWidget.delay == widget.delay &&
        oldWidget.loop == widget.loop &&
        oldWidget.seed == widget.seed;
    if (!same) _play();
  }

  void _play() {
    _timer?.cancel();
    _rest?.cancel();
    _typing = false;
    if (InkMotion.reducedIn(context)) {
      _shown = _final;
      return;
    }
    _shown = '';
    final steps = typingPlan(
      widget.phrases,
      TypingOptions(
        speed: widget.speed,
        pause: widget.pause.inMilliseconds.toDouble(),
        mode: widget.mode,
        loop: widget.loop,
        seed: inkSeed(widget.seed),
      ),
    ).steps;
    void at(int index) {
      if (!mounted) return;
      setState(() {
        _shown = steps[index].text;
        _typing = true;
      });
      _rest?.cancel();
      _rest = Timer(const Duration(milliseconds: 260), () {
        if (mounted) setState(() => _typing = false);
      });
      if (index + 1 < steps.length) {
        final wait = steps[index + 1].at - steps[index].at;
        _timer = Timer(Duration(milliseconds: wait), () => at(index + 1));
        return;
      }
      if (widget.loop) {
        _timer = Timer(const Duration(milliseconds: 120), () => at(0));
        return;
      }
      widget.onDone?.call();
    }

    _timer = Timer(widget.delay, () => at(0));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rest?.cancel();
    super.dispose();
  }

  TextStyle _style(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final ambient = DefaultTextStyle.of(context).style;
    final cssSize =
        (ambient.fontSize ?? theme.typography.bodySize) /
        KevinSansFace.hand.sizeAdjust;
    final face = theme.typography.face(
      KevinSansFace.type,
      cssSize: cssSize,
      color: ambient.color,
    );
    return face.merge(widget.style);
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(context);
    final theme = LooseleafTheme.of(context);
    final jitter = switch (theme.density == LooseleafDensity.calm ||
        InkMotion.reducedIn(context)) {
      true => 0.0,
      false => 1.0,
    };
    final seed = inkSeed(widget.seed);
    final cursor = widget.cursor;
    final fontSize = style.fontSize ?? theme.typography.bodySize;
    final typed = Text.rich(
      TextSpan(
        children: [
          ..._words(_shown, seed, style, jitter),
          if (cursor != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.bottom,
              child: TypewriterCaret(
                shape: cursor,
                seed: '$seed|caret',
                fontSize: fontSize,
                blinking: !_typing,
              ),
            ),
        ],
      ),
      style: style,
    );
    final announced = switch (widget.mode) {
      TypingMode.cycle => widget.phrases.join('. '),
      TypingMode.lines => _final,
    };
    return Semantics(
      container: true,
      liveRegion: !(widget.loop || widget.mode == TypingMode.cycle),
      label: announced,
      child: ExcludeSemantics(
        child: switch (widget.reserve) {
          true => _reserved(typed, style, cursor, fontSize),
          false => typed,
        },
      ),
    );
  }

  Widget _reserved(
    Widget typed,
    TextStyle style,
    CaretShape? cursor,
    double fontSize,
  ) {
    final room = switch (widget.mode) {
      TypingMode.cycle => widget.phrases.fold(
        '',
        (longest, phrase) => switch (phrase.length > longest.length) {
          true => phrase,
          false => longest,
        },
      ),
      TypingMode.lines => _final,
    };
    return Stack(
      children: [
        Visibility.maintain(
          visible: false,
          child: Text.rich(
            TextSpan(
              text: room,
              children: [
                if (cursor != null)
                  WidgetSpan(
                    child: SizedBox(
                      width: TypewriterCaret.reserveEms(cursor) * fontSize,
                    ),
                  ),
              ],
            ),
            style: style,
          ),
        ),
        Positioned.fill(child: typed),
      ],
    );
  }

  /// [text] split like JS `split(/(\s+)/)`, each word jittered by its own
  /// fork of `type-words|seed`.
  static List<InlineSpan> _words(
    String text,
    String seed,
    TextStyle style,
    double jitter,
  ) {
    final parts = <String>[];
    var last = 0;
    for (final space in RegExp(r'\s+').allMatches(text)) {
      parts
        ..add(text.substring(last, space.start))
        ..add(space.group(0) ?? '');
      last = space.end;
    }
    parts.add(text.substring(last));
    final rng = Rng('type-words|$seed');
    final color = style.color;
    return [
      for (final (index, part) in parts.indexed)
        if (part.isNotEmpty)
          switch (RegExp(r'^\s+$').hasMatch(part)) {
            true => TextSpan(text: part),
            false => _word(part, rng.fork(index), style, color, jitter),
          },
    ];
  }

  static InlineSpan _word(
    String word,
    Rng rng,
    TextStyle style,
    Color? color,
    double jitter,
  ) {
    final dy = double.parse((rng() * 1.6 - 0.8).toStringAsFixed(2));
    final fade = double.parse((0.9 + rng() * 0.1).toStringAsFixed(2));
    final opacity = 1 - (1 - fade) * jitter;
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Transform.translate(
        offset: Offset(0, dy * jitter),
        child: Text(
          word,
          style: style.copyWith(
            color: color?.withValues(alpha: color.a * opacity),
          ),
        ),
      ),
    );
  }
}
