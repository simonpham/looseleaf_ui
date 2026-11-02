import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/napkin/napkin.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A paper napkin to write on: tissue with a pinked edge and a pressed
/// border, folded in four ([NapkinFold.quarter]), in half or not at all,
/// optionally ringed by a coffee cup ([stain]). [children] ([NapkinTitle],
/// [NapkinContent], [NapkinFooter]) stack 8 px apart inside a 36 px margin
/// ([padding] replaces it), on a napkin [width] wide and at least
/// [minHeight] tall (under the padding, upstream's `min-h-0`, the content
/// sets the height). A direct [NapkinContent] child fills the space left,
/// pushing a [NapkinFooter] to the foot. The napkin and
/// its creases turn together, at most 1.2°.
///
/// ```dart
/// const Napkin(
///   stain: true,
///   tape: PaperTape.top,
///   children: [
///     NapkinTitle(Text('Specials')),
///     NapkinContent(Text('soup of the day, a very small pie')),
///     NapkinFooter(Text('until six')),
///   ],
/// )
/// ```
///
/// Mirrors `Napkin` in upstream `src/components/ui/napkin.tsx`.
class Napkin extends StatefulWidget {
  const Napkin({
    super.key,
    this.fold = NapkinFold.quarter,
    this.stain = false,
    this.width = defaultWidth,
    this.minHeight = defaultMinHeight,
    this.padding,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.children = const [],
  });

  /// Upstream's `w-72`.
  static const double defaultWidth = 288;

  /// Upstream's `min-h-56`.
  static const double defaultMinHeight = 224;

  /// The creases: one each way, one across, or none.
  final NapkinFold fold;

  /// A faint coffee ring.
  final bool stain;

  /// The napkin's width.
  final double width;

  /// The napkin's least height; content past it grows the napkin.
  final double minHeight;

  /// The space around the parts; upstream's `p-9` when null.
  final EdgeInsetsGeometry? padding;

  /// The edges; the napkin stock's pinked edge when null.
  final EdgeSpec? edge;

  /// False lays the napkin flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within 1.2° when null.
  final double? tiltDegrees;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A fastener; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The shadow.
  final PaperShadow shadow;

  /// Pins the tissue, the creases, the stain and the tilt.
  final String? seed;

  /// The parts.
  final List<Widget> children;

  @override
  State<Napkin> createState() => _NapkinState();
}

class _NapkinState extends State<Napkin> with InkSeed {
  static const double _tiltMax = 1.2;
  static const double _margin = Spacing.d36;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, _tiltMax),
    };
    final decorated = widget.fold != NapkinFold.none || widget.stain;
    final padding =
        widget.padding?.resolve(Directionality.of(context)) ??
        const EdgeInsets.all(_margin);
    final params = NapkinParams(fold: widget.fold, stain: widget.stain);
    return SizedBox(
      width: widget.width,
      child: Paper(
        stock: StockName.napkin,
        rules: RuleName.none,
        edge: widget.edge,
        tilt: widget.tilt,
        tiltDegrees: degrees,
        tape: widget.tape,
        tapeKind: widget.tapeKind,
        fastener: widget.fastener,
        fastenerTone: widget.fastenerTone,
        shadow: widget.shadow,
        seed: seed,
        padding: padding,
        decor: switch (decorated) {
          false => null,
          true => Transform.rotate(
            angle: PaperInk.tilt(context, degrees),
            child: InkSurface(
              source: RecipeInkSource(
                napkinRecipe,
                params,
                json: params.toJson(),
              ),
              seed: '$seed|decor',
              still: true,
            ),
          ),
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: math.max(0.0, widget.width - padding.horizontal),
            minHeight: math.max(0.0, widget.minHeight - padding.vertical),
          ),
          child: IntrinsicHeight(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: theme.colors.ink),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d8,
                children: [
                  for (final child in widget.children)
                    switch (child) {
                      NapkinContent() => Expanded(child: child),
                      _ => child,
                    },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
