import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One word of a [MessageText]: nudged [dy] px off the line, its ink at
/// [ink] strength, and with [soak] it soaks in once (`animate-soak`: wet
/// dark ink, blurred and faint, drying to the text color).
class MessageWord extends StatefulWidget {
  const MessageWord({
    super.key,
    required this.word,
    this.dy = 0,
    this.ink = 1,
    this.soak = false,
  });

  final String word;

  /// The vertical nudge in px.
  final double dy;

  /// How much of the ink color shows, 0 to 1.
  final double ink;

  /// Whether the word soaks in when it appears.
  final bool soak;

  /// `--ll-dur-soak`.
  static const Duration soakDuration = Duration(milliseconds: 520);

  @override
  State<MessageWord> createState() => _MessageWordState();
}

class _MessageWordState extends State<MessageWord>
    with SingleTickerProviderStateMixin {
  static const double _mid = 0.55;

  AnimationController? _soak;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.soak || _soak != null) return;
    final duration = InkMotion.of(context, MessageWord.soakDuration);
    if (duration == Duration.zero) return;
    _soak = AnimationController(vsync: this, duration: duration)..forward();
  }

  @override
  void dispose() {
    _soak?.dispose();
    super.dispose();
  }

  Widget _word(BuildContext context, double t) {
    final style = DefaultTextStyle.of(context).style;
    final dry = style.color ?? LooseleafTheme.of(context).colors.ink;
    final wet = LooseleafTheme.of(context).colors.wetInkFrom;
    final color = Color.lerp(wet, dry, InkMotion.easeOut.transform(t)) ?? dry;
    final wetPart = t < _mid;
    final local = InkMotion.easeOut.transform(switch (wetPart) {
      true => t / _mid,
      false => (t - _mid) / (1 - _mid),
    });
    final opacity = switch (wetPart) {
      true => 0.15 + 0.75 * local,
      false => 0.9 + 0.1 * local,
    };
    final blur = switch (wetPart) {
      true => 1.4 - 0.8 * local,
      false => 0.6 * (1 - local),
    };
    final halo = switch (wetPart) {
      true => 0.55 - 0.25 * local,
      false => 0.3 * (1 - local),
    };
    return Transform.translate(
      offset: Offset(0, widget.dy),
      child: Text(
        widget.word,
        style: TextStyle(
          color: color.withValues(alpha: color.a * widget.ink * opacity),
          shadows: [
            if (t < 1)
              Shadow(
                color: wet.withValues(alpha: halo),
                blurRadius: blur,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soak = _soak;
    if (soak == null) return _word(context, 1);
    return AnimatedBuilder(
      animation: soak,
      builder: (context, _) => _word(context, soak.value),
    );
  }
}
