import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/marquee/marquee.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A ticker written on a strip of tape: [children] (usually [MarqueeItem]s)
/// run along a 44 px band of [tape] in 24 px semibold script with a paper
/// halo, faded at both ends, looping seamlessly at [speed] px a second.
///
/// It stops while a mouse is over it or focus is inside it, and while
/// [paused] (controlled) or after the [MarqueeControl] pause button
/// (uncontrolled, starting at [defaultPaused]). Where motion is reduced it
/// is a still strip with one copy of the text, centred. It fills its
/// parent's width.
///
/// ```dart
/// Marquee(
///   label: 'Shop news',
///   children: const [
///     MarqueeItem(Text('Fresh bread at seven')),
///     MarqueeItem(Text('Open late on Fridays')),
///   ],
/// )
/// ```
///
/// Mirrors `Marquee` in upstream `src/components/ui/marquee.tsx`.
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.children,
    this.label = 'Ticker',
    this.speed = 60,
    this.direction = MarqueeDirection.start,
    this.tape = TapeKind.washiStripes,
    this.color,
    this.paused,
    this.defaultPaused = false,
    this.onPausedChange,
    this.controls = true,
    this.seed,
  });

  /// Upstream's `h-11`.
  static const double height = Spacing.d44;

  /// The phrases.
  final List<Widget> children;

  /// The accessible name.
  final String label;

  /// Pixels a second; a short text never loops faster than every 4 s.
  final double speed;

  /// Toward the start of the line (mirrored in RTL) or away from it.
  final MarqueeDirection direction;

  /// The tape the band is cut from.
  final TapeKind tape;

  /// A washi tape's print colour.
  final Accent? color;

  /// Holds the ticker still when true (controlled); null leaves it to the
  /// pause button.
  final bool? paused;

  /// The pause button's first state when [paused] is null.
  final bool defaultPaused;

  /// Called with the next pause state when the pause button is pressed.
  final ValueChanged<bool>? onPausedChange;

  /// Shows the pause button at the end. Keep it for any ticker that runs
  /// more than five seconds.
  final bool controls;

  /// Pins the band's hand.
  final String? seed;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with InkSeed {
  late bool _inner = widget.defaultPaused;
  bool _hovered = false;
  bool _focused = false;

  bool get _paused => widget.paused ?? _inner;

  void _toggle() {
    final next = !_paused;
    if (widget.paused == null) setState(() => _inner = next);
    widget.onPausedChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final params = MarqueeBandParams(kind: widget.tape, color: widget.color);
    final ink = colors.ink;
    final line = ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [ink.withValues(alpha: 0), ink, ink, ink.withValues(alpha: 0)],
        stops: const [0, 0.06, 0.94, 1],
      ).createShader(bounds),
      child: DefaultTextStyle.merge(
        style: theme.typography
            .face(
              KevinSansFace.script,
              cssSize: 24,
              cssLineHeight: 1,
              fontWeight: FontWeight.w600,
              color: ink,
            )
            .copyWith(
              shadows: [
                Shadow(color: colors.slip, blurRadius: 2),
                Shadow(color: colors.slip, blurRadius: 5),
              ],
            ),
        softWrap: false,
        child: MarqueeTrack(
          speed: widget.speed,
          direction: widget.direction,
          running: !_paused && !_hovered && !_focused,
          children: widget.children,
        ),
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: MarqueeScope(
        paused: _paused,
        onToggle: _toggle,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (focused) => setState(() => _focused = focused),
            child: SizedBox(
              height: Marquee.height,
              width: double.infinity,
              child: InkSurface(
                source: RecipeInkSource(
                  marqueeBandRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(widget.seed),
                still: true,
                child: Stack(
                  children: [
                    PositionedDirectional(
                      start: Spacing.d12,
                      end: switch (widget.controls) {
                        true => Spacing.d44,
                        false => Spacing.d12,
                      },
                      top: 0,
                      bottom: 0,
                      child: Semantics(container: true, child: line),
                    ),
                    if (widget.controls)
                      const PositionedDirectional(
                        end: Spacing.d8,
                        top: 0,
                        bottom: 0,
                        child: Center(child: MarqueeControl()),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
